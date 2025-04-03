-- Active: 1743100572938@@127.0.0.1@5432@nomina_adso
CREATE OR REPLACE FUNCTION sp_listar_parametros()
RETURNS TABLE (
 id_empresa      DECIMAL(10,0), 
    nom_empresa     VARCHAR   ,     
    ind_perio_pago  CHAR(1) ,       
    val_smlv        DECIMAL(8,0)   ,
    val_auxtrans    DECIMAL (7,0)  , 
    ano_nomina      DECIMAL(4,0)  ,  
    mes_nomina      DECIMAL(2)    ,  
    val_por_intces  DECIMAL(2,0)  , 
    num_diasmes     DECIMAL(2,0)   
) AS
$$
BEGIN
    RETURN QUERY 
    SELECT 
    p.id_empresa AS id,       
    p.nom_empresa AS nombre,          
    p.ind_perio_pago AS periodo_pago,    
    p.val_smlv   AS salario_minimo,     
    p.val_auxtrans AS auxilio_transporte,   
    p.ano_nomina  AS año_nomina,      
    p.mes_nomina   AS mes_nomina,     
    p.val_por_intces  AS intereses,
    p.num_diasmes  AS dias_mes       
    FROM tab_pmtros p;
END;
$$ LANGUAGE plpgsql;

SELECT sp_listar_parametros()


SELECT * FROM users;
SELECT * FROM tab_pmtros;