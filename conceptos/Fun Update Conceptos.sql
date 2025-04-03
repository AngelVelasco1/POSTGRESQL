CREATE OR REPLACE FUNCTION sp_update_concepto(
    p_id_concepto DECIMAL(2,0),
    p_nom_concepto VARCHAR,
    p_ind_operacion BOOLEAN,
    p_ind_perio_pago CHAR(1),
    p_neto_pagado BOOLEAN,
    p_val_porcent DECIMAL(3,0),
    p_val_fijo DECIMAL(8,0),
    p_ind_legal BOOLEAN
) RETURNS VOID AS
$$
BEGIN
    UPDATE tab_conceptos 
    SET nom_concepto = p_nom_concepto,
        ind_operacion = p_ind_operacion,
        ind_perio_pago = p_ind_perio_pago,
        neto_pagado = p_neto_pagado,
        val_porcent = p_val_porcent,
        val_fijo = p_val_fijo,
        ind_legal = p_ind_legal
    WHERE id_concepto = p_id_concepto;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Error: No se encontró un concepto con ID %.', p_id_concepto;
    END IF;

    RAISE NOTICE 'Concepto % actualizado correctamente', p_nom_concepto;
EXCEPTION
    WHEN check_violation THEN
        RAISE EXCEPTION 'Error: Violación de restricción CHECK.';
    WHEN others THEN
        RAISE EXCEPTION 'Error inesperado al actualizar concepto.';
END;
$$ LANGUAGE plpgsql;
