CREATE OR REPLACE FUNCTION fun_delete_cargos(pid_cargo tab_cargos.id_cargo%TYPE) RETURNS BOOLEAN AS
$$
	BEGIN
		DELETE FROM tab_cargos WHERE id_cargo = pid_cargo;
		IF FOUND THEN
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
	END;
$$
LANGUAGE PLPGSQL;