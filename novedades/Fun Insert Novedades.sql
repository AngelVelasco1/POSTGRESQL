CREATE OR REPLACE FUNCTION sp_insert_novedades(
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
    -- Verificar si ya existe el registro
    SELECT EXISTS(
        SELECT 1 FROM tab_novedades 
        WHERE ano_nomina = pano_nomina
          AND mes_nomina = pmes_nomina
          AND per_nomina = pper_nomina
          AND id_emplea = pid_emplea
          AND id_concepto = pid_concepto
    ) INTO v_exist;

    IF v_exist THEN
        RAISE EXCEPTION 'Error: La novedad ya existe para el empleado %, concepto %, período %, mes %, año %', 
        pid_emplea, pid_concepto, pper_nomina, pmes_nomina, pano_nomina;
    END IF;

    -- Insertar la novedad
    INSERT INTO tab_novedades (ano_nomina, mes_nomina, per_nomina, id_emplea, id_concepto, val_dias_trab, val_horas_trab)
    VALUES (pano_nomina, pmes_nomina, pper_nomina, pid_emplea, pid_concepto, pval_dias_trab, pval_horas_trab);

    RAISE NOTICE 'Novedad insertada correctamente para el empleado %, concepto %, período %, mes %, año %',
        pid_emplea, pid_concepto, pper_nomina, pmes_nomina, pano_nomina;

    RETURN TRUE;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error: No se puede insertar la novedad porque el empleado o el concepto no existen.';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al insertar la novedad: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
