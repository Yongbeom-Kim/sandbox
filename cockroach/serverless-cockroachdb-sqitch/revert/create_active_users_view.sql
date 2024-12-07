-- Revert sqitch-csql-sandbox:create_active_users_view from cockroach

BEGIN;

DROP VIEW testschema.users_view;

COMMIT;
