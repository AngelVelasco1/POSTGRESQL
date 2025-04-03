CREATE OR REPLACE FUNCTION sp_insert_mes(
    pid_mes tab_meses.id_mes%TYPE,
    pnom_mes tab_meses.nom_mes%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    INSERT INTO tab_meses (id_mes, nom_mes) VALUES (pid_mes, pnom_mes);
    RAISE NOTICE 'Mes % (%), insertado correctamente.', pid_mes, pnom_mes;
    RETURN TRUE;

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Error! El mes con ID % ya existe.', pid_mes;
    WHEN check_violation THEN
        RAISE EXCEPTION 'Error! El ID del mes debe estar entre 1 y 12, y el nombre debe tener al menos 4 caracteres.';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al insertar el mes: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
