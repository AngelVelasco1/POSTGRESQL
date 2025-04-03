CREATE OR REPLACE FUNCTION sp_delete_novedades(
    pano_nomina tab_novedades.ano_nomina%TYPE,
    pmes_nomina tab_novedades.mes_nomina%TYPE,
    pper_nomina tab_novedades.per_nomina%TYPE,
    pid_emplea tab_novedades.id_emplea%TYPE,
    pid_concepto tab_novedades.id_concepto%TYPE
) RETURNS BOOLEAN AS
$$
DECLARE
    v_exist BOOLEAN;
BEGIN
    -- Verificar si la novedad existe antes de eliminar
    SELECT EXISTS(
        SELECT 1 FROM tab_novedades 
        WHERE ano_nomina = pano_nomina
          AND mes_nomina = pmes_nomina
          AND per_nomina = pper_nomina
          AND id_emplea = pid_emplea
          AND id_concepto = pid_concepto
    ) INTO v_exist;

    IF NOT v_exist THEN
        RAISE EXCEPTION 'Error: No se encontró la novedad para el empleado %, concepto %, período %, mes %, año %',
        pid_emplea, pid_concepto, pper_nomina, pmes_nomina, pano_nomina;
    END IF;

    -- Eliminar la novedad
    DELETE FROM tab_novedades 
    WHERE ano_nomina = pano_nomina
      AND mes_nomina = pmes_nomina
      AND per_nomina = pper_nomina
      AND id_emplea = pid_emplea
      AND id_concepto = pid_concepto;

    RAISE NOTICE 'Novedad eliminada correctamente para el empleado %, concepto %, período %, mes %, año %',
        pid_emplea, pid_concepto, pper_nomina, pmes_nomina, pano_nomina;

    RETURN TRUE;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error: No se puede eliminar la novedad porque tiene dependencias en otras tablas.';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al eliminar la novedad: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
