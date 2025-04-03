CREATE OR REPLACE FUNCTION sp_insert_nomina(
    pano_nomina tab_nomina.ano_nomina%TYPE,
    pmes_nomina tab_nomina.mes_nomina%TYPE,
    pper_nomina tab_nomina.per_nomina%TYPE,
    pid_emplea tab_nomina.id_emplea%TYPE,
    pid_concepto tab_nomina.id_concepto%TYPE,
    pval_dias_trab tab_nomina.val_dias_trab%TYPE,
    pval_nomina tab_nomina.val_nomina%TYPE
) RETURNS BOOLEAN AS
$$
DECLARE
    v_exist_empleado BOOLEAN;
    v_exist_concepto BOOLEAN;
    v_exist_mes BOOLEAN;
BEGIN
    -- Validar si el empleado existe
    SELECT EXISTS(SELECT 1 FROM tab_emplea WHERE id_emplea = pid_emplea) INTO v_exist_empleado;
    IF NOT v_exist_empleado THEN
        RAISE EXCEPTION 'Error: El empleado con ID % no existe.', pid_emplea;
    END IF;

    -- Validar si el concepto existe
    SELECT EXISTS(SELECT 1 FROM tab_conceptos WHERE id_concepto = pid_concepto) INTO v_exist_concepto;
    IF NOT v_exist_concepto THEN
        RAISE EXCEPTION 'Error: El concepto con ID % no existe.', pid_concepto;
    END IF;

    -- Validar si el mes existe
    SELECT EXISTS(SELECT 1 FROM tab_meses WHERE id_mes = pmes_nomina) INTO v_exist_mes;
    IF NOT v_exist_mes THEN
        RAISE EXCEPTION 'Error: El mes con ID % no existe.', pmes_nomina;
    END IF;

    -- Insertar la nómina si pasa todas las validaciones
    INSERT INTO tab_nomina (
        ano_nomina, mes_nomina, per_nomina, id_emplea, id_concepto, val_dias_trab, val_nomina
    ) VALUES (
        pano_nomina, pmes_nomina, pper_nomina, pid_emplea, pid_concepto, pval_dias_trab, pval_nomina
    );

    RAISE NOTICE 'Nómina insertada correctamente: Año %, Mes %, Período %, Empleado %, Concepto %',
        pano_nomina, pmes_nomina, pper_nomina, pid_emplea, pid_concepto;

    RETURN TRUE;

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Error: La nómina ya existe para el empleado %, concepto % en el período especificado.', pid_emplea, pid_concepto;
    WHEN check_violation THEN
        RAISE EXCEPTION 'Error: Verifica los valores de días trabajados (1-30) y valor de nómina (>=0).';
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error: Alguna clave foránea no es válida.';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al insertar la nómina: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
