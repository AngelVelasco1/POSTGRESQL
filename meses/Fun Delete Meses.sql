CREATE OR REPLACE FUNCTION sp_update_mes(
    pid_mes tab_meses.id_mes%TYPE,
    pnom_mes tab_meses.nom_mes%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    UPDATE tab_meses SET nom_mes = COALESCE(pnom_mes, nom_mes) WHERE id_mes = pid_mes;

    IF FOUND THEN
        RAISE NOTICE 'Mes con ID % actualizado correctamente.', pid_mes;
        RETURN TRUE;
    ELSE
        RAISE NOTICE 'Error: No se encontró un mes con ID %', pid_mes;
        RETURN FALSE;
    END IF;

EXCEPTION
    WHEN check_violation THEN
        RAISE EXCEPTION 'Error! El nombre del mes debe tener al menos 4 caracteres.';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al actualizar el mes: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
