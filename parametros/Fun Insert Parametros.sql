-- Active: 1743100572938@@127.0.0.1@5432@nomina_adso
CREATE OR REPLACE FUNCTION sp_insert_pmtros(
    pid_empresa tab_pmtros.id_empresa%TYPE,
    pnom_empresa tab_pmtros.nom_empresa%TYPE,
    pind_perio_pago tab_pmtros.ind_perio_pago%TYPE,
    pval_smlv tab_pmtros.val_smlv%TYPE,
    pval_auxtrans tab_pmtros.val_auxtrans%TYPE,
    pind_num_trans tab_pmtros.ind_num_trans%TYPE,
    pano_nomina tab_pmtros.ano_nomina%TYPE,
    pmes_nomina tab_pmtros.mes_nomina%TYPE,
    pval_por_intces tab_pmtros.val_por_intces%TYPE,
    pnum_diasmes tab_pmtros.num_diasmes%TYPE,
    pid_concep_sb tab_pmtros.id_concep_sb%TYPE,
    pid_concep_at tab_pmtros.id_concep_at%TYPE
) RETURNS BOOLEAN AS
$$
DECLARE
    v_exist BOOLEAN;
BEGIN
    -- Verificar si la empresa ya existe
    SELECT EXISTS(SELECT 1 FROM tab_pmtros WHERE id_empresa = pid_empresa) INTO v_exist;
    
    IF v_exist THEN
        RAISE EXCEPTION 'Error: La empresa con ID % ya existe', pid_empresa;
    END IF;

    -- Insertar la empresa con los parámetros
    INSERT INTO tab_pmtros (
        id_empresa, nom_empresa, ind_perio_pago, val_smlv, val_auxtrans, 
        ind_num_trans, ano_nomina, mes_nomina, val_por_intces, num_diasmes,
        id_concep_sb, id_concep_at
    ) VALUES (
        pid_empresa, pnom_empresa, pind_perio_pago, pval_smlv, pval_auxtrans, 
        pind_num_trans, pano_nomina, pmes_nomina, pval_por_intces, pnum_diasmes,
        pid_concep_sb, pid_concep_at
    );

    RAISE NOTICE 'Empresa % insertada correctamente', pid_empresa;
    RETURN TRUE;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error: Uno de los conceptos especificados no existe en tab_conceptos';
    WHEN check_violation THEN
        RAISE EXCEPTION 'Error: Algún valor no cumple con las restricciones de la tabla';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error desconocido al insertar empresa: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
