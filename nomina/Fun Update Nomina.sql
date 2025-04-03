CREATE OR REPLACE FUNCTION sp_update_nomina(
    pano_nomina tab_nomina.ano_nomina%TYPE,
    pmes_nomina tab_nomina.mes_nomina%TYPE,
    pper_nomina tab_nomina.per_nomina%TYPE,
    pid_emplea tab_nomina.id_emplea%TYPE,
    pid_concepto tab_nomina.id_concepto%TYPE,
    pval_dias_trab tab_nomina.val_dias_trab%TYPE DEFAULT NULL,
    pval_nomina tab_nomina.val_nomina%TYPE DEFAULT NULL
) RETURNS BOOLEAN AS
$$
DECLARE
    v_exist_nomina BOOLEAN;
BEGIN
    -- Validar si la nómina existe
    SELECT EXISTS(
        SELECT 1 FROM tab_nomina 
        WHERE ano_nomina = pano_nomina
          AND mes_nomina = pmes_nomina
          AND per_nomina = pper_nomina
          AND id_emplea = pid_emplea
          AND id_concepto = pid_concepto
    ) INTO v_exist_nomina;

    IF NOT v_exist_nomina THEN
        RAISE EXCEPTION 'Error: La nómina no existe para el empleado %, concepto %, período %, mes %, año %', 
        pid_emplea, pid_concepto, pper_nomina, pmes_nomina, pano_nomina;
    END IF;

    -- Actualizar la nómina con los valores nuevos, si se proporcionan
    UPDATE tab_nomina SET 
        val_dias_trab = COALESCE(pval_dias_trab, val_dias_trab),
        val_nomina = COALESCE(pval_nomina, val_nomina)
    WHERE ano_nomina = pano_nomina
      AND mes_nomina = pmes_nomina
      AND per_nomina = pper_nomina
      AND id_emplea = pid_emplea
      AND id_concepto = pid_concepto;

    RAISE NOTICE 'Nómina actualizada correctamente para el empleado %, concepto %, período %, mes %, año %',
        pid_emplea, pid_concepto, pper_nomina, pmes_nomina, pano_nomina;

    RETURN TRUE;

EXCEPTION
    WHEN check_violation THEN
        RAISE EXCEPTION 'Error: Verifica los valores de días trabajados (1-30) y valor de nómina (>=0).';
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error: Alguna clave foránea no es válida.';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al actualizar la nómina: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
