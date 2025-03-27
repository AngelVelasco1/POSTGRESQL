CREATE OR REPLACE FUNCTION fun_update_cargos(pid_cargo tab_cargos.id_cargo%TYPE, new_cargo tab_cargos.nom_cargo%TYPE) RETURNS BOOLEAN AS
$$
	BEGIN
		UPDATE tab_cargos SET nom_cargo = new_cargo WHERE id_cargo = pid_cargo;
		IF FOUND THEN
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
	END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_update_cargos_by_name(pnom_cargo tab_cargos.nom_cargo%TYPE, new_cargo tab_cargos.nom_cargo%TYPE) RETURNS BOOLEAN AS
$$
	BEGIN
		UPDATE tab_cargos SET nom_cargo = new_cargo WHERE nom_cargo = pnom_cargo;
		IF FOUND THEN
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
	END;
$$
LANGUAGE PLPGSQL;



SELECT * FROM tab_cargos;
SELECT fun_update_cargos_by_name('Gerente de algo', 'Gerente de algo nuevo');
SELECT fun_update_cargos(1, 'Gerente de ....');