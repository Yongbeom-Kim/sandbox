-- Revert sqitch-csql-sandbox:create_users_table_again from cockroach

BEGIN;

DROP TABLE testschema.users;

COMMIT;
