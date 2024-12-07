-- Deploy sqitch-csql-sandbox:drop_active_users_view to cockroach
-- requires: create_active_users_view

BEGIN;

DROP VIEW testschema.users_view;

COMMIT;
