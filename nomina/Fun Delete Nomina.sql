CREATE OR REPLACE FUNCTION sp_delete_nomina(
    pano_nomina tab_nomina.ano_nomina%TYPE,
    pmes_nomina tab_nomina.mes_nomina%TYPE,
    pper_nomina tab_nomina.per_nomina%TYPE,
    pid_emplea tab_nomina.id_emplea%TYPE,
    pid_concepto tab_nomina.id_concepto%TYPE
) RETURNS BOOLEAN AS
$$
DECLARE
    v_exist_nomina BOOLEAN;
BEGIN
    -- Verificar si la nómina existe
    SELECT EXISTS(
        SELECT 1 FROM tab_nomina 
        WHERE ano_nomina = pano_nomina
          AND mes_nomina = pmes_nomina
          AND per_nomina = pper_nomina
          AND id_emplea = pid_emplea
          AND id_concepto = pid_concepto
    ) INTO v_exist_nomina;

    IF NOT v_exist_nomina THEN
        RAISE EXCEPTION 'Error: No se encontró la nómina para el empleado %, concepto %, período %, mes %, año %', 
        pid_emplea, pid_concepto, pper_nomina, pmes_nomina, pano_nomina;
    END IF;

    -- Eliminar la nómina
    DELETE FROM tab_nomina 
    WHERE ano_nomina = pano_nomina
      AND mes_nomina = pmes_nomina
      AND per_nomina = pper_nomina
      AND id_emplea = pid_emplea
      AND id_concepto = pid_concepto;

    RAISE NOTICE 'Nómina eliminada correctamente para el empleado %, concepto %, período %, mes %, año %',
        pid_emplea, pid_concepto, pper_nomina, pmes_nomina, pano_nomina;

    RETURN TRUE;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error: No se puede eliminar la nómina porque tiene dependencias en otras tablas.';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al eliminar la nómina: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
