-- Verify sqitch-csql-sandbox:drop_get_user_func on cockroach

BEGIN;

CREATE PROCEDURE verify_get_user_function_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.routines 
        WHERE routine_schema = 'testschema' 
        AND routine_name = 'get_user_by_username'
    ) THEN
        RAISE EXCEPTION 'get_user_by_username function still exists';
    END IF;
END;
$$;

CALL verify_get_user_function_dropped();

DROP PROCEDURE verify_get_user_function_dropped();

ROLLBACK;
