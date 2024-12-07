-- Revert sqitch-csql-sandbox:drop_users_email_idx from cockroach

BEGIN;

CREATE INDEX idx_users_email ON testschema.users(email);

COMMIT;
