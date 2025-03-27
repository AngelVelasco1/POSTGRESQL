-- Exceptions

-- not null violation
DO $$  
BEGIN  
    INSERT INTO tab_emplea (nom_emplea) VALUES (NULL);  
EXCEPTION  
		 -- exception name
    WHEN not_null_violation THEN  
        RAISE NOTICE '¡Error! No se pueden insertar valores NULL en la columna nombre.';  
END $$;


-- division_by_zero
DO $$
DECLARE 
	result NUMERIC;
BEGIN 
	result := 10/0;
	RAISE NOTICE 'The result is %', result;
EXCEPTION
		 -- exception name
	WHEN division_by_zero THEN
	RAISE NOTICE 'Error, you cant divide by zero';
END $$;


-- Excepciones personalizadas (Lanzar excepciones)