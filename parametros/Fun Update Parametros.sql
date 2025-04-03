CREATE OR REPLACE FUNCTION sp_update_pmtros(
    pid_empresa tab_pmtros.id_empresa%TYPE,
    pnom_empresa tab_pmtros.nom_empresa%TYPE DEFAULT NULL,
    pind_perio_pago tab_pmtros.ind_perio_pago%TYPE DEFAULT NULL,
    pval_smlv tab_pmtros.val_smlv%TYPE DEFAULT NULL,
    pval_auxtrans tab_pmtros.val_auxtrans%TYPE DEFAULT NULL,
    pind_num_trans tab_pmtros.ind_num_trans%TYPE DEFAULT NULL,
    pano_nomina tab_pmtros.ano_nomina%TYPE DEFAULT NULL,
    pmes_nomina tab_pmtros.mes_nomina%TYPE DEFAULT NULL,
    pval_por_intces tab_pmtros.val_por_intces%TYPE DEFAULT NULL,
    pnum_diasmes tab_pmtros.num_diasmes%TYPE DEFAULT NULL,
    pid_concep_sb tab_pmtros.id_concep_sb%TYPE DEFAULT NULL,
    pid_concep_at tab_pmtros.id_concep_at%TYPE DEFAULT NULL
) RETURNS BOOLEAN AS
$$
DECLARE
    v_exist BOOLEAN;
BEGIN
    -- Verificar si la empresa existe
    SELECT EXISTS(SELECT 1 FROM tab_pmtros WHERE id_empresa = pid_empresa) INTO v_exist;
    
    IF NOT v_exist THEN
        RAISE EXCEPTION 'Error: La empresa con ID % no existe', pid_empresa;
    END IF;

    -- Actualizar la empresa
    UPDATE tab_pmtros SET
        nom_empresa = COALESCE(pnom_empresa, nom_empresa),
        ind_perio_pago = COALESCE(pind_perio_pago, ind_perio_pago),
        val_smlv = COALESCE(pval_smlv, val_smlv),
        val_auxtrans = COALESCE(pval_auxtrans, val_auxtrans),
        ind_num_trans = COALESCE(pind_num_trans, ind_num_trans),
        ano_nomina = COALESCE(pano_nomina, ano_nomina),
        mes_nomina = COALESCE(pmes_nomina, mes_nomina),
        val_por_intces = COALESCE(pval_por_intces, val_por_intces),
        num_diasmes = COALESCE(pnum_diasmes, num_diasmes),
        id_concep_sb = COALESCE(pid_concep_sb, id_concep_sb),
        id_concep_at = COALESCE(pid_concep_at, id_concep_at)
    WHERE id_empresa = pid_empresa;

    RAISE NOTICE 'Empresa % actualizada correctamente', pid_empresa;
    RETURN TRUE;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error: Uno de los conceptos especificados no existe en tab_conceptos';
    WHEN check_violation THEN
        RAISE EXCEPTION 'Error: Algún valor no cumple con las restricciones de la tabla';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al actualizar empresa: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
