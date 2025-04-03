CREATE OR REPLACE FUNCTION sp_delete_concepto(
    p_id_concepto DECIMAL(2,0)
) RETURNS VOID AS
$$
BEGIN
    DELETE FROM tab_conceptos WHERE id_concepto = p_id_concepto;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Error: No se encontró un concepto con ID %.', p_id_concepto;
    END IF;

    RAISE NOTICE 'Concepto con ID % eliminado correctamente', p_id_concepto;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error: No se puede eliminar porque hay registros relacionados.';
    WHEN others THEN
        RAISE EXCEPTION 'Error inesperado al eliminar concepto.';
END;
$$ LANGUAGE plpgsql;
