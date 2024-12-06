-- Verify sqitch-csql-sandbox:drop_test_schema on cockroach


BEGIN;

CREATE PROCEDURE verify_drop_test_schema()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'testschema') THEN
        RAISE EXCEPTION 'testschema still exists';
    END IF;
END;
$$;

CALL verify_drop_test_schema();

DROP PROCEDURE verify_drop_test_schema();

ROLLBACK;