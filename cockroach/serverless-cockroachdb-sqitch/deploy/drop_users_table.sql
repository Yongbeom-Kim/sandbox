-- Deploy sqitch-csql-sandbox:drop_users_table to cockroach
-- requires: add_user_status_column

BEGIN;

DROP TABLE testschema.users;

COMMIT;
