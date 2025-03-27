CREATE OR REPLACE FUNCTION fun_insert_empleados(
	pid_emplea tab_emplea.id_emplea%TYPE,
    pnom_emplea tab_emplea.nom_emplea%TYPE,
    pape_emplea tab_emplea.ape_emplea%TYPE,
    pind_genero tab_emplea.ind_genero%TYPE,
    pdir_emplea tab_emplea.dir_emplea%TYPE,
    ptel_emplea tab_emplea.tel_emplea%TYPE,
    pind_estrato tab_emplea.ind_estrato%TYPE,
    pind_est_civil tab_emplea.ind_est_civil%TYPE,
    pnum_hijos tab_emplea.num_hijos%TYPE,
    pval_tipo_sangre tab_emplea.val_tipo_sangre%TYPE,
    pval_edad tab_emplea.val_edad%TYPE,
    pid_cargo tab_emplea.id_cargo%TYPE,
    pval_sal_basico tab_emplea.val_sal_basico%TYPE,
    pfec_ingreso tab_emplea.fec_ingreso%TYPE
) RETURNS VARCHAR AS
$$
	DECLARE empleado_exists TEXT;
    BEGIN
		SELECT COALESCE(nom_emplea, '') INTO empleado_exists FROM tab_emplea WHERE id_emplea = pid_emplea;
		IF empleado_exists <> '' THEN 
			RAISE NOTICE 'The employee already exists';
			RETURN FALSE;
		END IF;
		
		IF(LENGTH(pnom_emplea) < 2 OR LENGTH(pape_emplea) < 2) THEN
			RAISE NOTICE 'The name and lastname must be greather than 2 char';
			RETURN FALSE;
		END IF;
		
		IF(pind_estrato NOT BETWEEN 1 AND 6) THEN
			RAISE NOTICE 'The estrato must be between 1 and 6';
			RETURN FALSE;
		END IF;
		
		IF(pind_est_civil NOT BETWEEN 1 AND 4) THEN
			RAISE NOTICE 'The estado civil must be between 1 and 4';
			RETURN FALSE;
		END IF;
		
		IF(TRIM(pval_tipo_sangre) NOT IN('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')) THEN
			RAISE NOTICE 'The tipo de sangre must be a proper blood type';
			RETURN FALSE;
		END IF;
		
		IF(pval_edad < 16) THEN
			RAISE NOTICE 'Edad must be greather or equal than 16';
			RETURN FALSE;
		END IF;
				
        INSERT INTO tab_emplea VALUES(pid_emplea, pnom_emplea, pape_emplea, pind_genero, pdir_emplea, ptel_emplea, 
                                      pind_estrato, pind_est_civil, pnum_hijos, pval_tipo_sangre, pval_edad, pid_cargo, 
                                      pval_sal_basico, pfec_ingreso);        
		IF FOUND THEN
            RAISE NOTICE 'Ya inserte el empleado';
            RETURN TRUE;
        END IF;
		
		EXCEPTION 
			WHEN not_null_violation THEN
			RAISE NOTICE 'Existe un valor nulo no valido';
			RETURN FALSE;
		
	END;
$$
LANGUAGE PLPGSQL;


SELECT fun_insert_empleados(20012, 'hFFFF', 'fddddd', TRUE, 'Calle 123', 3001234567, 3, 1, 2, 'A+K', 30, 5, 2500000.00, '2025-03-25');
SELECT * FROM tab_emplea;
