-- Verify sqitch-csql-sandbox:drop_user_status_column on cockroach

BEGIN;

CREATE PROCEDURE verify_user_status_column_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users' 
        AND column_name = 'status'
    ) THEN
        RAISE EXCEPTION 'status column still exists in users table';
    END IF;
END;
$$;

CALL verify_user_status_column_dropped();

DROP PROCEDURE verify_user_status_column_dropped();

ROLLBACK;