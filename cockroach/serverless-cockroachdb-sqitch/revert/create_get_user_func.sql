-- Revert sqitch-csql-sandbox:create_get_user_func from cockroach

BEGIN;

DROP FUNCTION testschema.get_user_by_username;

COMMIT;
