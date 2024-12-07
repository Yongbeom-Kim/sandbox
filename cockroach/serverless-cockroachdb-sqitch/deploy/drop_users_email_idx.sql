-- Deploy sqitch-csql-sandbox:drop_users_email_idx to cockroach
-- requires: create_users_email_idx

BEGIN;

DROP INDEX testschema.idx_users_email;

COMMIT;
