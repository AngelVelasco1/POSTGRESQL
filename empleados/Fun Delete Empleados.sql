-- Active: 1743100572938@@127.0.0.1@5432@nomina_adso
CREATE OR REPLACE FUNCTION fun_delete_empleados(
    pid_emplea tab_emplea.id_emplea%TYPE
) RETURNS BOOLEAN AS
$$
DECLARE
    error_code TEXT;
BEGIN
    DELETE FROM tab_emplea WHERE id_emplea = pid_emplea;

    IF FOUND THEN
        RAISE NOTICE 'Empleado con ID % eliminado correctamente', pid_emplea;
        RETURN TRUE;
    ELSE
        RAISE NOTICE 'Error: No se encontró un empleado con ID %', pid_emplea;
        RETURN FALSE;
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error! No se puede eliminar el empleado con ID % porque tiene registros relacionados.', pid_emplea;
    WHEN OTHERS THEN
        error_code := SQLSTATE;
        RAISE EXCEPTION 'Error al eliminar empleado: %', error_code;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
