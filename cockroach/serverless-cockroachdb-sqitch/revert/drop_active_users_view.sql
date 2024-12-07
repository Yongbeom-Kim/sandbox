-- Revert sqitch-csql-sandbox:drop_active_users_view from cockroach

BEGIN;

CREATE VIEW testschema.users_view AS
SELECT id, username, email, created_at
FROM testschema.users
WHERE 1 = 1;

COMMIT;
