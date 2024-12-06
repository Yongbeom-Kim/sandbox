-- Revert sqitch-csql-sandbox:create_test_schema_again from cockroach

BEGIN;

DROP SCHEMA testschema;

COMMIT;
