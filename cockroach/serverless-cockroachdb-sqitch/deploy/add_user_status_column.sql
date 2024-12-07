-- Deploy sqitch-csql-sandbox:add_user_status_column to cockroach
-- requires: create_user_table

BEGIN;

ALTER TABLE testschema.users
ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active';

COMMIT;
