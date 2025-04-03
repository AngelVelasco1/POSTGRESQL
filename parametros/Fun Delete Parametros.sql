CREATE OR REPLACE FUNCTION sp_delete_pmtros(
    pid_empresa tab_pmtros.id_empresa%TYPE
) RETURNS BOOLEAN AS
$$
DECLARE
    v_exist BOOLEAN;
BEGIN
    -- Verificar si la empresa existe antes de eliminar
    SELECT EXISTS(SELECT 1 FROM tab_pmtros WHERE id_empresa = pid_empresa) INTO v_exist;
    
    IF NOT v_exist THEN
        RAISE EXCEPTION 'Error: La empresa con ID % no existe', pid_empresa;
    END IF;

    -- Eliminar la empresa
    DELETE FROM tab_pmtros WHERE id_empresa = pid_empresa;

    RAISE NOTICE 'Empresa % eliminada correctamente', pid_empresa;
    RETURN TRUE;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error: No se puede eliminar la empresa porque tiene registros relacionados';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al eliminar empresa: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
