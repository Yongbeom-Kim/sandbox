-- Revert sqitch-csql-sandbox:create_users_email_idx from cockroach

BEGIN;

DROP INDEX testschema.idx_users_email;

COMMIT;
