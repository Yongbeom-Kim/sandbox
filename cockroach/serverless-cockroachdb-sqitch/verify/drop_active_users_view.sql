-- Verify sqitch-csql-sandbox:drop_active_users_view on cockroach

BEGIN;

CREATE PROCEDURE verify_users_view_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.views 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users_view'
    ) THEN
        RAISE EXCEPTION 'users_view still exists';
    END IF;
END;
$$;

CALL verify_users_view_dropped();

DROP PROCEDURE verify_users_view_dropped();

ROLLBACK;
