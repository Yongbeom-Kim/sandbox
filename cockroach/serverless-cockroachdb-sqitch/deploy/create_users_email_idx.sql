-- Deploy sqitch-csql-sandbox:create_users_email_idx to cockroach

BEGIN;

CREATE INDEX idx_users_email ON testschema.users(email);

COMMIT;
