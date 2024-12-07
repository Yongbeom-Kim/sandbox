-- Deploy sqitch-csql-sandbox:drop_user_status_column to cockroach
-- requires: add_user_status_column

BEGIN;

ALTER TABLE testschema.users
DROP COLUMN status;

COMMIT;
