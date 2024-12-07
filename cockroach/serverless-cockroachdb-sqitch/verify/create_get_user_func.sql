-- Verify sqitch-csql-sandbox:create_get_user_func on cockroach

BEGIN;

CREATE PROCEDURE verify_get_user_function()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO testschema.users (username, email) VALUES ('testuser', 'testuser@example.com');
    IF (SELECT email FROM testschema.get_user_by_username('testuser')) != 'testuser@example.com' THEN
        RAISE EXCEPTION 'get_user_by_username function does not exist, or does not return the correct user';
    END IF;
END;
$$;

CALL verify_get_user_function();

DROP PROCEDURE verify_get_user_function();

ROLLBACK;
