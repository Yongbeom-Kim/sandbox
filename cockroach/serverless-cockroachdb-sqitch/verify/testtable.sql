-- Verify sqitch-csql-sandbox:testtable on cockroach

BEGIN;

-- XXX Add verifications here.
SELECT id, name FROM testschema.testtable WHERE FALSE;

ROLLBACK;
