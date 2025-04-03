CREATE OR REPLACE FUNCTION sp_listar_empleados()
RETURNS TABLE (
    id_emplea DECIMAL(10,0),
    nom_emplea VARCHAR,
    ape_emplea VARCHAR,
    ind_genero BOOLEAN,
    dir_emplea VARCHAR,
    tel_emplea DECIMAL(10,0),
    ind_estrato DECIMAL(1,0),
    ind_est_civil DECIMAL(1,0),
    num_hijos DECIMAL(1,0),
    val_tipo_sangre VARCHAR,
    val_edad DECIMAL(2,0),
    id_cargo DECIMAL(2,0),
    val_sal_basico DECIMAL(8,0),
    fec_ingreso DATE
) AS
$$
BEGIN
    RETURN QUERY 
    SELECT 
        e.id_emplea,
        e.nom_emplea,
        e.ape_emplea,
        e.ind_genero,
        e.dir_emplea,
        e.tel_emplea, 
        e.ind_estrato,
        e.ind_est_civil,
        e.num_hijos,
        e.val_tipo_sangre,
        e.val_edad,
        e.id_cargo,
        e.val_sal_basico,
        e.fec_ingreso
    FROM tab_emplea e;
END;
$$ LANGUAGE plpgsql;


