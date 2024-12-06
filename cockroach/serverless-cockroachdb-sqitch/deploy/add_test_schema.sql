-- Deploy sqitch-csql-sandbox:add_test_schema to cockroach

BEGIN;

CREATE SCHEMA testschema;

COMMIT;
