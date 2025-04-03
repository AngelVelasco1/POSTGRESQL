CREATE OR REPLACE FUNCTION sp_update_novedades(
    pano_nomina tab_novedades.ano_nomina%TYPE,
    pmes_nomina tab_novedades.mes_nomina%TYPE,
    pper_nomina tab_novedades.per_nomina%TYPE,
    pid_emplea tab_novedades.id_emplea%TYPE,
    pid_concepto tab_novedades.id_concepto%TYPE,
    pval_dias_trab tab_novedades.val_dias_trab%TYPE,
    pval_horas_trab tab_novedades.val_horas_trab%TYPE
) RETURNS BOOLEAN AS
$$
DECLARE
    v_exist BOOLEAN;
BEGIN
    -- Verificar si existe la novedad antes de actualizar
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

    -- Actualizar la novedad
    UPDATE tab_novedades 
    SET val_dias_trab = pval_dias_trab, 
        val_horas_trab = pval_horas_trab
    WHERE ano_nomina = pano_nomina
      AND mes_nomina = pmes_nomina
      AND per_nomina = pper_nomina
      AND id_emplea = pid_emplea
      AND id_concepto = pid_concepto;

    RAISE NOTICE 'Novedad actualizada correctamente para el empleado %, concepto %, período %, mes %, año %',
        pid_emplea, pid_concepto, pper_nomina, pmes_nomina, pano_nomina;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al actualizar la novedad: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
