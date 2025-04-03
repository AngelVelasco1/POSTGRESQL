CREATE OR REPLACE FUNCTION sp_get_mes(
    pid_mes tab_meses.id_mes%TYPE
) RETURNS TABLE (id_mes DECIMAL, nom_mes VARCHAR) AS
$$
BEGIN
    RETURN QUERY SELECT * FROM tab_meses WHERE id_mes = pid_mes;

    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró el mes con ID %', pid_mes;
    END IF;
END;
$$ LANGUAGE plpgsql;
