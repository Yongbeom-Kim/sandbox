-- Verify sqitch-csql-sandbox:create_active_users_view on cockroach

BEGIN;

CREATE PROCEDURE verify_active_users_view()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.views 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users_view'
    ) THEN
        RAISE EXCEPTION 'active_users view does not exist';
    END IF;
END;
$$;

CALL verify_active_users_view();

DROP PROCEDURE verify_active_users_view();

ROLLBACK;
