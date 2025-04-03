CREATE OR REPLACE FUNCTION sp_listar_cargos()
RETURNS TABLE (id_cargo DECIMAL, nom_cargo VARCHAR) AS
$$
BEGIN
    RETURN QUERY
    SELECT t.id_cargo, t.nom_cargo FROM tab_cargos t;
END;
$$ LANGUAGE plpgsql;


SELECT sp_listar_cargos();