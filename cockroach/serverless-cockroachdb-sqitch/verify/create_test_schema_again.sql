-- Verify sqitch-csql-sandbox:create_test_schema_again on cockroach

BEGIN;

CREATE PROCEDURE verify_test_schema()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'testschema') THEN
        RAISE EXCEPTION 'testschema does not exist';
    END IF;
END;
$$;

CALL verify_test_schema();

DROP PROCEDURE verify_test_schema();

ROLLBACK;