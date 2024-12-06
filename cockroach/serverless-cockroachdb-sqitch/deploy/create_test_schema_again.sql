-- Deploy sqitch-csql-sandbox:create_test_schema_again to cockroach
-- requires: drop_test_schema

BEGIN;

CREATE SCHEMA testschema;

COMMIT;
