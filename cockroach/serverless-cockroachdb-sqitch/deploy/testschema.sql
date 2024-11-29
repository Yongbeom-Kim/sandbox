-- Deploy sqitch-csql-sandbox:testschema to cockroach

BEGIN;

-- XXX Add DDLs here.
CREATE SCHEMA testschema;

COMMIT;
