-- Active: 1743100572938@@127.0.0.1@5432@nomina_adso
CREATE OR REPLACE FUNCTION sp_listar_conceptos()
RETURNS TABLE (id_concepto tab_conceptos.id_concepto%TYPE, nom_concepto tab_conceptos.nom_concepto%TYPE, ind_perio_pago tab_conceptos.ind_perio_pago%TYPE) AS
$$
BEGIN
    RETURN QUERY 
    SELECT t.id_concepto, t.nom_concepto, t.ind_perio_pago FROM tab_conceptos t;
END;
$$ LANGUAGE plpgsql;


SELECT sp_listar_conceptos();