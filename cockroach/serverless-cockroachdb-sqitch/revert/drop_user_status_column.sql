-- Revert sqitch-csql-sandbox:drop_user_status_column from cockroach

BEGIN;

ALTER TABLE testschema.users
ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active';

COMMIT;
