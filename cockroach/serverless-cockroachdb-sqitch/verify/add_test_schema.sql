-- Verify sqitch-csql-sandbox:add_test_schema on cockroach

BEGIN;

SELECT 1/COUNT(*) FROM information_schema.schemata WHERE schema_name = 'testschema';

ROLLBACK;
