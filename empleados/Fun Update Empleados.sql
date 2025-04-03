CREATE OR REPLACE FUNCTION fun_update_empleados(
	pid_emplea tab_emplea.id_cargo%TYPE,
    pnom_emplea tab_emplea.nom_emplea%TYPE,
    pape_emplea tab_emplea.ape_emplea%TYPE,
    pind_genero tab_emplea.ind_genero%TYPE,
    pdir_emplea tab_emplea.dir_emplea%TYPE,
    ptel_emplea tab_emplea.tel_emplea%TYPE,
    pind_estrato tab_emplea.ind_estrato%TYPE,
    pind_est_civil tab_emplea.ind_est_civil%TYPE,
    pnum_hijos tab_emplea.num_hijos%TYPE,
    pval_tipo_sangre tab_emplea.val_tipo_sangre%TYPE,
    pval_edad tab_emplea.val_edad%TYPE
) RETURNS BOOLEAN AS
$$
	DECLARE 
		error_code TEXT;
	BEGIN
		UPDATE tab_emplea SET 
		nom_emplea = COALESCE(pnom_emplea, nom_emplea), 
		ape_emplea = COALESCE(pape_emplea, ape_emplea), 
		ind_genero = COALESCE(pind_genero, ind_genero), 
		dir_emplea = COALESCE(pdir_emplea, dir_emplea),
		tel_emplea = COALESCE(ptel_emplea, tel_emplea), 
		ind_estrato = COALESCE(pind_estrato, ind_estrato), 
		ind_est_civil = COALESCE(pind_est_civil, ind_est_civil), 
		num_hijos = COALESCE(pnum_hijos, num_hijos), 
		val_tipo_sangre = COALESCE(pval_tipo_sangre, val_tipo_sangre), 
		val_edad = COALESCE(pval_edad, val_edad) 
		WHERE id_emplea = pid_emplea;
		IF FOUND THEN
			RAISE NOTICE 'Empleado Actualizado';
			RETURN TRUE;
		ELSE
			RAISE NOTICE 'Empleado no encontrado';
			RETURN FALSE;
		END IF;
		
		EXCEPTION
			WHEN not_null_violation THEN
				RAISE EXCEPTION 'Error! No se pueden insertar valores NULL';
			WHEN OTHERS THEN
				error_code := SQLSTATE;
				RETURN 'Error al actualizar empleado: %', error_code;
	END;
$$
LANGUAGE PLPGSQL;

