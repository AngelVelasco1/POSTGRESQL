CREATE OR REPLACE FUNCTION fun_insert_cargos(wnom_cargo tab_cargos.nom_cargo%TYPE) RETURNS VARCHAR AS
$$
    BEGIN
	IF wnom_cargo = '' THEN
		RAISE NOTICE 'Empty values are not allowed';
		RETURN FALSE;
	ELSE 
        INSERT INTO tab_cargos VALUES((SELECT COALESCE(MAX(id_cargo),0) + 1 FROM tab_cargos),wnom_cargo);
        IF FOUND THEN
            RAISE NOTICE 'Ya inserté el cargo %.. Soy un duro, cómo me ves?',wnom_cargo;
            RETURN 'Esta vaina funcionó.. Somos duros en ADSO';
        ELSE
            RAISE NOTICE 'Pequeño demonio, no funcionó esta joda... Y ahora????';
            RETURN 'Eche pa la primaria porque de esto no va a comer... Sorry';
        END IF;
    END IF;
	END;
$$
LANGUAGE PLPGSQL;

SELECT fun_insert_cargos('');
SELECT fun_insert_cargos('Gerente de Ventas');
SELECT fun_insert_cargos('Gerente de TI');
SELECT fun_insert_cargos('Gerente de RRHH');
SELECT fun_insert_cargos('Gerente Comercial');
SELECT fun_insert_cargos('Subgerente de Seguridad de la Informacion');
SELECT fun_insert_cargos('Secretaria General');
SELECT fun_insert_cargos('WebMaster');
SELECT fun_insert_cargos('Desarrollador Senior');
SELECT fun_insert_cargos('Desarrollador Junior');
SELECT fun_insert_cargos('Tester');
SELECT fun_insert_cargos('Documentador');
SELECT fun_insert_cargos('Scrum Master');
SELECT fun_insert_cargos('Diseñador');
SELECT fun_insert_cargos('Vendedor');
SELECT fun_insert_cargos('Servicios Generales');
SELECT fun_insert_cargos('Vigilante');
SELECT fun_insert_cargos('Mensajero');
SELECT fun_insert_cargos('Asistente de gerencia');



SELECT * FROM tab_cargos;