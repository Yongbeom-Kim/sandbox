-- Verify sqitch-csql-sandbox:create_users_table_again on cockroach

BEGIN;

CREATE PROCEDURE verify_users_table()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users'
    ) THEN
        RAISE EXCEPTION 'users table does not exist';
    END IF;
END;
$$;

CALL verify_users_table();

DROP PROCEDURE verify_users_table();

ROLLBACK;
