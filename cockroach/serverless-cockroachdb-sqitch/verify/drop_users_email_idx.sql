-- Verify sqitch-csql-sandbox:drop_users_email_idx on cockroach

BEGIN;

CREATE PROCEDURE verify_users_email_index_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM pg_indexes 
        WHERE schemaname = 'testschema' 
        AND tablename = 'users' 
        AND indexname = 'idx_users_email'
    ) THEN
        RAISE EXCEPTION 'email index still exists on users table';
    END IF;
END;
$$;

CALL verify_users_email_index_dropped();

DROP PROCEDURE verify_users_email_index_dropped();

ROLLBACK;
