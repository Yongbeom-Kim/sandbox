-- Revert sqitch-csql-sandbox:drop_test_schema from cockroach

BEGIN;

CREATE SCHEMA testschema;

COMMIT;
