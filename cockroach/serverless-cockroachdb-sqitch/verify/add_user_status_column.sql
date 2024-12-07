-- Verify sqitch-csql-sandbox:add_user_status_column on cockroach

BEGIN;

CREATE PROCEDURE verify_user_status_column()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users'
        AND column_name = 'status'
    ) THEN
        RAISE EXCEPTION 'status column does not exist in users table';
    END IF;
END;
$$;

CALL verify_user_status_column();

DROP PROCEDURE verify_user_status_column();

ROLLBACK;
