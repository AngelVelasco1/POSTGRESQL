-- Active: 1743100572938@@127.0.0.1@5432@nomina_adso
CREATE OR REPLACE FUNCTION generate_nomina (pano_nomina tab_nomina.ano_nomina%TYPE, pmes_nomina tab_nomina.mes_nomina%TYPE, pper_nomina tab_nomina.per_nomina%TYPE) RETURNS BOOLEAN AS
$$  
DECLARE 
    cur_emplea REFCURSOR;
    cur_concep REFCURSOR;
    cur_noved REFCURSOR;
    rec_pmetros RECORD;
    rec_emplea RECORD;
    rec_concep RECORD;
    rec_noved RECORD;
    query_emplea VARCHAR;
    query_concep VARCHAR;
    sum_devengado  tab_nomina.val_nomina%TYPE;
    sum_deducido   tab_nomina.val_nomina%TYPE;
    val_neto_pagado tab_nomina.val_nomina%TYPE;
    val_dias       tab_pmtros.num_diasmes%TYPE;
    val_salario    tab_nomina.val_nomina%TYPE;
    val_trans      tab_nomina.val_nomina%TYPE;
    val_concepto   tab_nomina.val_nomina%TYPE;

    BEGIN
        -- Datos de parametros
        SELECT id_empresa, nom_empresa, ind_perio_pago, val_smlv, val_auxtrans, ind_num_trans, ano_nomina, mes_nomina, num_diasmeas, id_concep_sb, id_concep_at 
        INTO reg_pmtros FROM tab_pmtros;
        RAISE NOTICE '% % % % % % % % %', rec_pmtros.id_empresa, rec_pmtros.nom_empresa, rec_pmtros.ind_perio_pago, rec_pmtros.val_smlv, rec_pmtros.val_auxtrans, rec_pmtros.ind_num_trans, rec_pmtros.ano_nomina, rec_pmtros.mes_nomina, rec_pmtros.num_diasmeas;

        -- Validaciones
        IF pno_nomina <> rec_pmtros.ano_nomina THEN 
            RAISE EXCEPTION USING ERRCODE = 22008;
        END IF;

         IF pmes_nomina <> rec_pmtros.mes_nomina THEN 
            RAISE EXCEPTION USING ERRCODE = 22008;
        END IF;

         IF pper_nomina > 2 THEN 
            RAISE EXCEPTION USING ERRCODE = 22008;
        END IF;

         IF rec_pmtros.ind_per_pago = 'Q' THEN 
            val_dias = rec_pmtros.num_diasmes / 2;
         ELSE 
            val_dias = rec_pmtros.num_diasmes;
        END IF;

        query_emplea = 'SELECT id_emplea, nom_emplea, ape_emplea, val_sal_basico FROM tab_emplea';
        query_concep = 'SELECT id_concepto, nom_concepto, ind_operacion, val_porcent, val_fijo FROM tab_conceptos 
                        WHERE neto_pagado = FALSE AND ind_legal = TRUE';

        -- Recorremos todos los empleados con su cursor
        OPEN cur_emplea FOR EXECUTE query_emplea;
            FETCH cur_emplea INTO rec_emplea;
            WHILE FOUND LOOP
                RAISE NOTICE '% % % %', rec_emplea.id_emplea, rec_emplea.nom_emplea, rec_emplea.ape_emplea, rec_emplea.val_sal_basico;
            -- Recorremos todos los conceptos para liquidar la nomina de los empleados
            sum_devengado = 0;
            sum_deducido = 0;
            val_neto_pagado = 0;
            OPEN cur_concep FOR EXECUTE query_concep;
                FETCH cur_concep INTO rec_concep;
                WHILE FOUND LOOP
                    RAISE NOTICE '% % % % %', rec_concep.id_concepto, rec_concep.nom_concepto, rec_concep.ind_operacion, rec_concep.val_porcent, rec_concep.val_fijo;
                    IF rec_pmetros.ind_per_pago = "Q" THEN 
                        val_salario = rec_emplea.val_sal_basico / 2;
                    ELSE 
                        val_salario = rec_emplea.val_sal_basico;
                    END IF;
                    
                    IF rec_concep.ind_operacion = TRUE THEN
                        IF rec_concep.id_concepto = rec_pmetros.id_concep_sb THEN
                            sum_devengado += ((val_salario / rec_pmetros.num_diasmes) * val_dias);
                            RAISE NOTICE 'Los Dias a pagar son % y el devengado va en: %', val_dias, sum_devengado;
                            INSERT INTO tab_nomina VALUES(pano_nomina, pmes_nomina, pper_nomina, rec_emplea.id_emplea, rec_emplea.id_concepto, val_dias, val_salario);
                            IF NOT FOUND THEN
			                  		    RAISE EXCEPTION USING ERRCODE = 'P0001';
		                    END IF; 
                        END IF;
                         IF rec_concep.id_concepto = rec_pmetros.id_concep_at THEN
                                IF rec_emplea.val_sal_basico <= (rec_pmetros.val_smlv * rec_pmetros.ind_num_trans) THEN
                                    IF rec_pmetros.ind_perio_pago = 'Q' THEN
                                        val_trans = rec_pmetros.val_auxtrans / 2;
                                    ELSE
                                        val_trans = rec_pmetros.val_auxtrans;
                                    END IF;
                                    RAISE NOTICE 'Empleado: % Dias a pagar es %, Aux. Transp es % y el devengado va en: %',
                                                  rec_emplea.id_emplea,wval_dias,wval_trans,wsum_devengado;
                                    INSERT INTO tab_nomina VALUES(pano_nomina, pmes_nomina, pper_nomina, rec_emplea.id_emplea, rec_concep.id_concepto, val_dias,val_trans);
                                    IF NOT FOUND THEN
			                  		    RAISE EXCEPTION USING ERRCODE = 'P0001';
		                            END IF;  
                                END IF;
                            END IF; 
                        END IF;
-- ACÁ VA EL RESTO DE CONCEPTOS QUE SUMAN Y NO SON OBLIGATORIOS (VIENEN DE NOVEDADES)...

                    ELSE 
 
                            IF (tab_conceptos.ind_legal = FALSE) AND (tab_conceptos.ind_operacion) = TRUE THEN
                                    SELECT 
                                        tab_novedades.ano_nomina,
                                        tab_novedades.mes_nomina,
                                        tab_novedades.per_nomina,
                                        tab_novedades.id_emplea,
                                        tab_novedades.id_concepto,
                                        tab_novedades.val_dias_trab,
                                        tab_novedades.val_horas_trab
                                    INTO
                                        wreg_pmtros
                                    FROM 
                                        tab_novedades;

                                    RAISE NOTICE '%, %, %, %, %, %, %', 
                                        wreg_pmtros.ano_nomina, 
                                        wreg_pmtros.mes_nomina, 
                                        wreg_pmtros.per_nomina, 
                                        wreg_pmtros.id_emplea, 
                                        wreg_pmtros.id_concepto,
                                        wreg_pmtros.val_dias_trab,
                                        wreg_pmtros.val_horas_trab;

                                    INSERT INTO tab_nomina VALUES(
                                                                ano_nomina, 
                                                                mes_nomina, 
                                                                per_nomina, 
                                                                id_emplea, 
                                                                id_concepto,
                                                                val_dias_trab,
                                                                val_horas_trab
                                                                 );
                            ELSE 
                                RAISE EXCEPTION USING ERRCODE = '42P01';
                            END IF;
-- ACÁ VAN LOS CONCEPTOS QUE RESTAN A LA NÓMINA (DEDUCIDOS)
                            IF wreg_concep.val_porcent <> 0 THEN
                                wval_concepto = (wreg_emplea.val_sal_basico * wreg_concep.val_porcent) / 100;
                                IF wreg_pmtros.ind_perio_pago = 'Q' THEN
                                    wval_concepto = wval_concepto / 2;
                                END IF;
                                INSERT INTO tab_nomina VALUES(wano_nomina,wmes_nomina,wper_nomina,wreg_emplea.id_emplea,
                                                              wreg_concep.id_concepto,wval_dias,wval_concepto);
                                IF NOT FOUND THEN
		                  		    RAISE EXCEPTION USING ERRCODE = 'P0001';
	                            END IF;
                                wsum_deducido = wsum_deducido + wval_concepto;
                            END IF;
                            IF wreg_concep.val_fijo <> 0 THEN
                                wval_concepto = (wreg_emplea.val_sal_basico + wreg_concep.val_fijo);
                                IF wreg_pmtros.ind_perio_pago = 'Q' THEN
                                    wval_concepto = wval_concepto / 2;
                                END IF;
                                INSERT INTO tab_nomina VALUES(wano_nomina,wmes_nomina,wper_nomina,wreg_emplea.id_emplea,
                                                              wreg_concep.id_concepto,wval_dias,wval_concepto);
                                IF NOT FOUND THEN
		                  		    RAISE EXCEPTION USING ERRCODE = 'P0001';
	                            END IF;
                                wsum_deducido = wsum_deducido + wval_concepto;
                            END IF;
--a.val_porcent,a.val_fijo
                        END IF;
                        FETCH wcur_concep INTO wreg_concep;
                    END LOOP;
                CLOSE wcur_concep;
-- HASTA ACÁ EMPEZAMOS VA EL RECORRIDO DE CONCEPTOS...
			    FETCH wcur_emplea INTO wreg_emplea;
            END LOOP;
		CLOSE wcur_emplea;
        RETURN TRUE;

-- VALIDACIÓN DE LAS EXCEPCIONES. VIENE DE LAS CONDICIONES DE ARRIBA
		EXCEPTION
            WHEN SQLSTATE '22008' THEN
                RAISE NOTICE 'El año, o el mes, o el período no corresponden al de PMTROS... Arréglelo Bestia';
				RETURN FALSE;

            WHEN SQLSTATE '23502' THEN
                RAISE NOTICE 'Está mandando un NULO en el ID... Sea serio';
				RETURN FALSE;

			WHEN SQLSTATE '23503' THEN  
                RAISE NOTICE 'El Cargo no existe... Créelo y vuelva, o ni se aparezca más por acá';
				RETURN FALSE;

			WHEN SQLSTATE '23505' THEN  
               RAISE NOTICE 'El registro ya existe.. Trabaje bien o ábrase llaveee';
				RETURN FALSE;

            WHEN SQLSTATE '22001' THEN  
                RAISE NOTICE 'El nombre es muy corto.. Es de su abuelita?';
				RETURN FALSE;

			WHEN SQLSTATE 'P0001' THEN
				ROLLBACK;

--			WHEN OTHERS THEN
--					RAISE NOTICE 'Esta vaina se totió.. Y no fue de la risa.. Déjeme trabajar';
--					RETURN FALSE;
    
        END LOOP;
    END;
$$

CREATE OR REPLACE FUNCTION generate_nomina(
    pano_nomina tab_nomina.ano_nomina%TYPE,
    pmes_nomina tab_nomina.mes_nomina%TYPE,
    pper_nomina tab_nomina.per_nomina%TYPE
) RETURNS BOOLEAN AS
$$  
DECLARE 
    cur_emplea REFCURSOR;
    cur_concep REFCURSOR;
    cur_noved REFCURSOR;
    rec_pmtros RECORD;
    rec_emplea RECORD;
    rec_concep RECORD;
    rec_noved RECORD;
    query_emplea VARCHAR;
    query_concep VARCHAR;
    sum_devengado  tab_nomina.val_nomina%TYPE := 0;
    sum_deducido   tab_nomina.val_nomina%TYPE := 0;
    val_neto_pagado tab_nomina.val_nomina%TYPE := 0;
    val_dias       tab_pmtros.num_diasmes%TYPE;
    val_salario    tab_nomina.val_nomina%TYPE;
    val_trans      tab_nomina.val_nomina%TYPE;
    val_concepto   tab_nomina.val_nomina%TYPE;

BEGIN
    -- Obtener datos de parámetros
    SELECT id_empresa, nom_empresa, ind_perio_pago, val_smlv, val_auxtrans, ind_num_trans, 
           ano_nomina, mes_nomina, num_diasmes, id_concep_sb, id_concep_at
    INTO rec_pmtros 
    FROM tab_pmtros;

    -- Validaciones
    IF pano_nomina <> rec_pmtros.ano_nomina THEN 
        RAISE EXCEPTION 'El año de nómina no coincide con los parámetros';
    END IF;

    IF pmes_nomina <> rec_pmtros.mes_nomina THEN 
        RAISE EXCEPTION 'El mes de nómina no coincide con los parámetros';
    END IF;

    IF pper_nomina > 2 THEN 
        RAISE EXCEPTION 'El período de nómina es inválido';
    END IF;

    -- Determinar los días a pagar
    IF rec_pmtros.ind_perio_pago = 'Q' THEN 
        val_dias := rec_pmtros.num_diasmes / 2;
    ELSE 
        val_dias := rec_pmtros.num_diasmes;
    END IF;

    -- Consultas para obtener empleados y conceptos
    query_emplea := 'SELECT id_emplea, nom_emplea, ape_emplea, val_sal_basico FROM tab_emplea';
    query_concep := 'SELECT id_concepto, nom_concepto, ind_operacion, val_porcent, val_fijo 
                     FROM tab_conceptos WHERE neto_pagado = FALSE AND ind_legal = TRUE';

    -- Recorrer empleados
    OPEN cur_emplea FOR EXECUTE query_emplea;
    LOOP
        FETCH cur_emplea INTO rec_emplea;
        EXIT WHEN NOT FOUND;

        -- Inicializar sumas
        sum_devengado := 0;
        sum_deducido := 0;
        val_neto_pagado := 0;

        -- Calcular salario del empleado
        IF rec_pmtros.ind_perio_pago = 'Q' THEN 
            val_salario := rec_emplea.val_sal_basico / 2;
        ELSE 
            val_salario := rec_emplea.val_sal_basico;
        END IF;

        -- Recorrer conceptos
        OPEN cur_concep FOR EXECUTE query_concep;
        LOOP
            FETCH cur_concep INTO rec_concep;
            EXIT WHEN NOT FOUND;

            -- Procesar conceptos de devengados
            IF rec_concep.ind_operacion = TRUE THEN
                IF rec_concep.id_concepto = rec_pmtros.id_concep_sb THEN
                    sum_devengado := sum_devengado + ((val_salario / rec_pmtros.num_diasmes) * val_dias);
                    INSERT INTO tab_nomina (ano_nomina, mes_nomina, per_nomina, id_emplea, id_concepto, val_dias, val_salario)
                    VALUES (pano_nomina, pmes_nomina, pper_nomina, rec_emplea.id_emplea, rec_concep.id_concepto, val_dias, val_salario);
                END IF;

                -- Auxilio de transporte
                IF rec_concep.id_concepto = rec_pmtros.id_concep_at THEN
                    IF rec_emplea.val_sal_basico <= (rec_pmtros.val_smlv * rec_pmtros.ind_num_trans) THEN
                        IF rec_pmtros.ind_perio_pago = 'Q' THEN
                            val_trans := rec_pmtros.val_auxtrans / 2;
                        ELSE
                            val_trans := rec_pmtros.val_auxtrans;
                        END IF;

                        INSERT INTO tab_nomina (ano_nomina, mes_nomina, per_nomina, id_emplea, id_concepto, val_dias, val_trans)
                        VALUES (pano_nomina, pmes_nomina, pper_nomina, rec_emplea.id_emplea, rec_concep.id_concepto, val_dias, val_trans);
                    END IF;
                END IF;
            ELSE
                -- Procesar deducciones
                IF rec_concep.val_porcent <> 0 THEN
                    val_concepto := (rec_emplea.val_sal_basico * rec_concep.val_porcent) / 100;
                    IF rec_pmtros.ind_perio_pago = 'Q' THEN
                        val_concepto := val_concepto / 2;
                    END IF;
                    sum_deducido := sum_deducido + val_concepto;

                    INSERT INTO tab_nomina (ano_nomina, mes_nomina, per_nomina, id_emplea, id_concepto, val_dias, val_concepto)
                    VALUES (pano_nomina, pmes_nomina, pper_nomina, rec_emplea.id_emplea, rec_concep.id_concepto, val_dias, val_concepto);
                END IF;
            END IF;
        END LOOP;
        CLOSE cur_concep;
    END LOOP;
    CLOSE cur_emplea;

    RETURN TRUE;

    EXCEPTION
            WHEN SQLSTATE '22008' THEN
                RAISE NOTICE 'El año, o el mes, o el período no corresponden al de PMTROS... Arréglelo Bestia';
				RETURN FALSE;

            WHEN SQLSTATE '23502' THEN
                RAISE NOTICE 'Está mandando un NULO en el ID... Sea serio';
				RETURN FALSE;

			WHEN SQLSTATE '23503' THEN  
                RAISE NOTICE 'El Cargo no existe... Créelo y vuelva, o ni se aparezca más por acá';
				RETURN FALSE;

			WHEN SQLSTATE '23505' THEN  
               RAISE NOTICE 'El registro ya existe.. Trabaje bien o ábrase llaveee';
				RETURN FALSE;

            WHEN SQLSTATE '22001' THEN  
                RAISE NOTICE 'El nombre es muy corto.. Es de su abuelita?';
				RETURN FALSE;

			WHEN SQLSTATE 'P0001' THEN
				ROLLBACK;

            WHEN OTHERS THEN
                RAISE NOTICE 'Esta vaina se totió.. Y no fue de la risa.. Déjeme trabajar';
                RETURN FALSE;
END;
$$ 
LANGUAGE plpgsql;
