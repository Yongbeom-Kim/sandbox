-- Deploy sqitch-csql-sandbox:drop_get_user_func to cockroach
-- requires: create_get_user_func

BEGIN;

DROP FUNCTION testschema.get_user_by_username;

COMMIT;
