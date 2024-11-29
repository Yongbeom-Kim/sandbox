-- Revert sqitch-csql-sandbox:testschema from cockroach

BEGIN;

-- XXX Add DDLs here.
DROP SCHEMA testschema;

COMMIT;
