CREATE OR REPLACE FUNCTION fun_gen_nomina(wano_nomina tab_nomina.ano_nomina%TYPE,wmes_nomina tab_nomina.mes_nomina%TYPE,
                                          wper_nomina tab_nomina.per_nomina%TYPE) RETURNS BOOLEAN AS
$$
    DECLARE wreg_pmtros    	RECORD;
    DECLARE wcur_emplea    	REFCURSOR;
    DECLARE wreg_emplea    	RECORD;
    DECLARE wcur_concep    	REFCURSOR;
    DECLARE wreg_concep    	RECORD;
    DECLARE wcur_noveda    	REFCURSOR;
    DECLARE wreg_noveda    	RECORD;
    DECLARE wquery_empl    	VARCHAR;
    DECLARE wquery_conc    	VARCHAR;
	DECLARE wquery_nove	   	VARCHAR;
    DECLARE wsum_devengado 	tab_nomina.val_nomina%TYPE;
    DECLARE wsum_deducido  	tab_nomina.val_nomina%TYPE;
    DECLARE wval_netopagado	tab_nomina.val_nomina%TYPE;
    DECLARE wval_dias     	tab_pmtros.num_diasmes%TYPE;
    DECLARE wval_salario   	tab_nomina.val_nomina%TYPE;
    DECLARE wval_trans     	tab_nomina.val_nomina%TYPE;
    DECLARE wval_concepto  	tab_nomina.val_nomina%TYPE;
	DECLARE wval_horas_dia	tab_nomina.val_nomina%TYPE;
	
    BEGIN
-- TRAEMOS LA DATA DE LA TABLA DE PARÁMETROS
        SELECT a.id_empresa,a.nom_empresa,a.ind_perio_pago,a.val_smlv,a.val_auxtrans,a.ind_num_trans,a.ano_nomina,
               a.mes_nomina,a.num_diasmes,a.id_concep_sb,a.id_concep_at INTO wreg_pmtros FROM tab_pmtros a;
        RAISE NOTICE '% % % % % % % % %',wreg_pmtros.id_empresa,wreg_pmtros.nom_empresa,wreg_pmtros.ind_perio_pago,
                                         wreg_pmtros.val_smlv,wreg_pmtros.val_auxtrans,wreg_pmtros.ind_num_trans,
                                         wreg_pmtros.ano_nomina,wreg_pmtros.mes_nomina,wreg_pmtros.num_diasmes;

-- Validaciones
		IF wano_nomina <> wreg_pmtros.ano_nomina THEN
            RAISE EXCEPTION USING ERRCODE = 22008;
        END IF;
		IF wmes_nomina <> wreg_pmtros.mes_nomina THEN
            RAISE EXCEPTION USING ERRCODE = 22008;
        END IF;
		IF wper_nomina > 2 THEN
            RAISE EXCEPTION USING ERRCODE = 22008;
        END IF;

        IF wreg_pmtros.ind_perio_pago = 'Q' THEN
            wval_dias = wreg_pmtros.num_diasmes / 2;
        ELSE
            wval_dias = wreg_pmtros.num_diasmes;
        END IF;

		wval_horas_dia = 8; -- Promerio de horas de trabajo por dia

-- EMPIEZA EL BAILE ACÁ
		--Query de todos los empleados
        wquery_empl = 'SELECT a.id_emplea,a.nom_emplea,a.ape_emplea,a.val_sal_basico FROM tab_emplea a';
		--Query de conceptos obligatorios
        wquery_conc = 'SELECT a.id_concepto,a.nom_concepto,a.ind_operacion,a.val_porcent,a.val_fijo, a.ind_legal FROM tab_conceptos a WHERE a.neto_pagado = FALSE';
		--Query de novedades
		wquery_nove = 'SELECT a.ano_nomina, a.mes_nomina, a.per_nomina, a.id_emplea, a.id_concepto, a.val_dias_trab, a.val_horas_trab FROM tab_novedades a';
-- BORRAMOS LA NÓMINA DEL PERÍODO QUE SE VA A EJECUTAR;
        DELETE FROM tab_nomina
        WHERE ano_nomina = wano_nomina AND
              mes_nomina = wmes_nomina AND
              per_nomina = wper_nomina;
        IF NOT FOUND THEN
	        RAISE Notice 'No hay registros en el periodo seleccionado... Seguimos en la fiesta';
        END IF;                   
        OPEN wcur_emplea FOR EXECUTE wquery_empl;
			FETCH wcur_emplea INTO wreg_emplea;
            WHILE FOUND LOOP
--			    RAISE NOTICE '% % % %',wreg_emplea.id_emplea,wreg_emplea.nom_emplea,wreg_emplea.ape_emplea,wreg_emplea.val_sal_basico;
-- ACÁ EMPEZAMOS A RECORRER LA TABLA DE CONCEPTOS PARA LIQUIDAR LA NÓMINA, UNO A UNO...
                wsum_devengado  = 0;
                wsum_deducido   = 0;
                wval_netopagado = 0;
             OPEN wcur_concep FOR EXECUTE wquery_conc;
                    FETCH wcur_concep INTO wreg_concep;
                    WHILE FOUND LOOP
--                      RAISE NOTICE '% % % % %',wreg_concep.id_concepto,wreg_concep.nom_concepto,wreg_concep.ind_operacion,
--                                          wreg_concep.val_porcent,wreg_concep.val_fijo;
-- ACÁ EMPIEZAN LOS CÁLCULOS CHIMENGUENCHONES
                        IF wreg_pmtros.ind_perio_pago = 'Q' THEN
                            wval_salario = wreg_emplea.val_sal_basico / 2;
                        ELSE
                            wval_salario = wreg_emplea.val_sal_basico;
                        END IF;

                        IF wreg_concep.ind_operacion = TRUE THEN
                            IF wreg_concep.id_concepto = wreg_pmtros.id_concep_sb THEN
                                wsum_devengado = wsum_devengado + ((wval_salario / wreg_pmtros.num_diasmes) * wval_dias);
                                RAISE NOTICE 'Empleado: %, Dias a pagar son: % y el devengado va en: %',wreg_emplea.id_emplea,wval_dias,wsum_devengado;
                                INSERT INTO tab_nomina VALUES(wano_nomina,wmes_nomina,wper_nomina,wreg_emplea.id_emplea,
                                                              wreg_concep.id_concepto,wval_dias,wval_salario);
                                IF NOT FOUND THEN
			                  		RAISE EXCEPTION USING ERRCODE = 'P0001';
		                        END IF;
                            END IF;
                            IF wreg_concep.id_concepto = wreg_pmtros.id_concep_at THEN
                                IF wreg_emplea.val_sal_basico <= (wreg_pmtros.val_smlv * wreg_pmtros.ind_num_trans) THEN
                                    IF wreg_pmtros.ind_perio_pago = 'Q' THEN
                                        wval_trans = wreg_pmtros.val_auxtrans / 2;
                                    ELSE
                                        wval_trans = wreg_pmtros.val_auxtrans;
                                    END IF;
									 wsum_devengado = wsum_devengado + wval_trans;	
                                    RAISE NOTICE 'Empleado: %, concepto: % y el devengado va en: %',wreg_emplea.id_emplea,wreg_concep.id_concepto,wsum_devengado;
                                    INSERT INTO tab_nomina VALUES(wano_nomina,wmes_nomina,wper_nomina,wreg_emplea.id_emplea,
                                                                  wreg_concep.id_concepto,wval_dias,wval_trans);
                                    IF NOT FOUND THEN
			                  		    RAISE EXCEPTION USING ERRCODE = 'P0001';
		                            END IF;  
                                END IF;
							END IF;
-- ACÁ VA EL RESTO DE CONCEPTOS QUE SUMAN Y NO SON OBLIGATORIOS (VIENEN DE NOVEDADES)
							IF wreg_concep.ind_legal = FALSE THEN
							--Se abre el cursor de novedades con la query de la tabla novedades(wquery_nove)
									OPEN wcur_noveda FOR EXECUTE wquery_nove;
									FETCH wcur_noveda INTO wreg_noveda;
									WHILE FOUND LOOP
									--Al encontrar una coincidencia con la tabla de novedades la funcion entra en la clausula if
										IF wreg_noveda.ano_nomina 	= wano_nomina AND
											wreg_noveda.mes_nomina 	= wmes_nomina AND
											wreg_noveda.per_nomina 	= wper_nomina AND
											wreg_noveda.id_emplea  	= wreg_emplea.id_emplea AND 
											wreg_noveda.id_concepto	= wreg_concep.id_concepto THEN
											   --Verificacion si es un valor porcentual, se calcula el valor del concepto y la suma de devengados
											  	IF wreg_concep.val_porcent <> 0 THEN
													IF wreg_noveda.val_horas_trab = 0 THEN
											   			wval_concepto = (wval_salario * wreg_concep.val_porcent) / 100;
														wsum_devengado = wsum_devengado + wval_concepto;
														--INSERT a la tabla nomina
														INSERT INTO tab_nomina VALUES(wano_nomina,wmes_nomina,wper_nomina,wreg_emplea.id_emplea,	                                                                  			  
														wreg_concep.id_concepto,wreg_noveda.val_dias_trab,wval_concepto); 
														RAISE NOTICE 'Empleado: %, concepto: % y el devengado va en: %',wreg_emplea.id_emplea,wreg_concep.id_concepto,wsum_devengado;
														IF NOT FOUND THEN
				                  		    				RAISE EXCEPTION USING ERRCODE = 'P0001';
											    		END IF;
													ELSE --Si son horas extras(egg pain)
														wval_concepto = (((wval_salario / wval_dias) / wval_horas_dia) * (wreg_concep.val_porcent / 100)) * wreg_noveda.val_horas_trab;
														wsum_devengado = wsum_devengado + wval_concepto;
														RAISE NOTICE 'Empleado: %, concepto: % y el devengado va en: %',wreg_emplea.id_emplea,wreg_concep.id_concepto,wsum_devengado;
														INSERT INTO tab_nomina VALUES(wano_nomina,wmes_nomina,wper_nomina,wreg_emplea.id_emplea,
	                                                                  			  wreg_concep.id_concepto,wreg_noveda.val_dias_trab,wval_concepto);
														IF NOT FOUND THEN
				                  		    				RAISE EXCEPTION USING ERRCODE = 'P0001';
														END IF;
													END IF;
												END IF;
												--Verificacion si es un valor fijo, se calcula el valor del concepto y la suma de devengados
												IF wreg_concep.val_fijo <> 0  THEN
													wval_concepto = wreg_concep.val_fijo;
													wsum_devengado = wsum_devengado + wval_concepto;
													RAISE NOTICE 'Empleado: %, concepto: % y el devengado va en: %',wreg_emplea.id_emplea,wreg_concep.id_concepto,wsum_devengado;
													INSERT INTO tab_nomina VALUES(wano_nomina,wmes_nomina,wper_nomina,wreg_emplea.id_emplea,
	                                                                  			  wreg_concep.id_concepto,wreg_noveda.val_dias_trab,wval_concepto);
													IF NOT FOUND THEN
				                  		    			RAISE EXCEPTION USING ERRCODE = 'P0001';
											    	END IF;
												END IF;
										END IF;
									FETCH wcur_noveda INTO wreg_noveda;
									END LOOP;
									-- Se cierra el cursor
									CLOSE wcur_noveda;
	                        END IF;
							ELSE
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

            WHEN OTHERS THEN
				RAISE NOTICE 'Esta vaina se totió.. Y no fue de la risa.. Déjeme trabajar';
	            RETURN FALSE;
END;
$$
LANGUAGE PLPGSQL;