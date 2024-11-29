-- Revert sqitch-csql-sandbox:testtable from cockroach

BEGIN;

-- XXX Add DDLs here.
DROP TABLE testschema.testtable;
COMMIT;
