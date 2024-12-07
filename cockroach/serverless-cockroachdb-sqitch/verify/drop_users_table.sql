-- Verify sqitch-csql-sandbox:drop_users_table on cockroach

BEGIN;

CREATE PROCEDURE verify_users_table_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users'
    ) THEN
        RAISE EXCEPTION 'users table still exists';
    END IF;
END;
$$;

CALL verify_users_table_dropped();

DROP PROCEDURE verify_users_table_dropped();

ROLLBACK;
