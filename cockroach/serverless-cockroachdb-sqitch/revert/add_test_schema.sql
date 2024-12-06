-- Revert sqitch-csql-sandbox:add_test_schema from cockroach

BEGIN;

DROP SCHEMA testschema;

COMMIT;
