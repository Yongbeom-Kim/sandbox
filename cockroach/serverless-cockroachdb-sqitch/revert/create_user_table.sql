-- Revert sqitch-csql-sandbox:create_user_table from cockroach

BEGIN;

DROP TABLE testschema.users;

COMMIT;
