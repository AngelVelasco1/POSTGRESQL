CREATE OR REPLACE FUNCTION sp_insert_concepto(
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
    INSERT INTO tab_conceptos (id_concepto, nom_concepto, ind_operacion, ind_perio_pago, 
                               neto_pagado, val_porcent, val_fijo, ind_legal)
    VALUES (p_id_concepto, p_nom_concepto, p_ind_operacion, p_ind_perio_pago, 
            p_neto_pagado, p_val_porcent, p_val_fijo, p_ind_legal);
    
    RAISE NOTICE 'Concepto % insertado correctamente', p_nom_concepto;
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Error: El ID de concepto % ya existe.', p_id_concepto;
    WHEN check_violation THEN
        RAISE EXCEPTION 'Error: Violación de restricción CHECK.';
    WHEN others THEN
        RAISE EXCEPTION 'Error inesperado al insertar concepto.';
END;
$$ LANGUAGE plpgsql;
