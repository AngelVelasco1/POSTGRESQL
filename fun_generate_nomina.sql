-- Active: 1743100572938@@127.0.0.1@5432@nomina_adso
CREATE OR REPLACE FUNCTION generate_nomina (pano_nomina tab_nomina.ano_nomina%TYPE, pmes_nomina tab_nomina.mes_nomina%TYPE, pper_nomina tab_nomina.per_nomina%TYPE) RETURNS BOOLEAN AS
$$  
DECLARE 
    cur_emplea REFCURSOR;
    cur_concep REFCURSOR;
    cur_noved REFCURSOR;
    rec_pmetros RECORD;
    rec_emplea RECORD;
    rec_concep RECORD;
    rec_noved RECORD;
    query_emplea VARCHAR;
    query_concep VARCHAR;

    BEGIN
        SELECT id_emplea ,nom_emplea, ape_emplea INTO rec_emplea FROM tab_emplea;
    END;
$$


