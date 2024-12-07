-- Revert sqitch-csql-sandbox:add_user_status_column from cockroach

BEGIN;

ALTER TABLE testschema.users
DROP COLUMN status;

COMMIT;
