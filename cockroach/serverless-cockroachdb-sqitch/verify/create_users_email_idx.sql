-- Verify sqitch-csql-sandbox:create_users_email_idx on cockroach

BEGIN;

CREATE PROCEDURE verify_users_email_index()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_indexes 
        WHERE schemaname = 'testschema' 
        AND tablename = 'users' 
        AND indexname = 'idx_users_email'
    ) THEN
        RAISE EXCEPTION 'email index does not exist on users table';
    END IF;
END;
$$;

CALL verify_users_email_index();

DROP PROCEDURE verify_users_email_index();

ROLLBACK;
