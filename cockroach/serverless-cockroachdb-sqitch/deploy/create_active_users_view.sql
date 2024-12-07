-- Deploy sqitch-csql-sandbox:create_active_users_view to cockroach

BEGIN;

CREATE VIEW testschema.users_view AS
SELECT id, username, email, created_at
FROM testschema.users
WHERE 1 = 1;

COMMIT;
