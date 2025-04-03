CREATE OR REPLACE FUNCTION sp_listar_meses()
RETURNS TABLE (
   id_mes  DECIMAL(2,0),
   nom_mes VARCHAR
) AS
$$
BEGIN
    RETURN QUERY 
    SELECT 
        e.id_mes AS id,
        e.nom_mes AS nombre
    FROM tab_meses e;
END;
$$ LANGUAGE plpgsql;

SELECT sp_listar_meses()