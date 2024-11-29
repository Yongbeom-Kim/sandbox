-- Verify sqitch-csql-sandbox:testschema on cockroach

BEGIN;

-- XXX Add verifications here.
-- Does not work
-- DO $$
-- BEGIN
--    ASSERT (SELECT has_schema_privilege('testschema', 'usage'));
-- END $$;

SELECT 1/COUNT(*) FROM information_schema.schemata WHERE schema_name = 'testschema';

ROLLBACK;
