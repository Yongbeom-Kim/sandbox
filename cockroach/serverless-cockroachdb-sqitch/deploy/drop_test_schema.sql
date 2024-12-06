-- Deploy sqitch-csql-sandbox:drop_test_schema to cockroach

BEGIN;

DROP SCHEMA testschema;

COMMIT;
