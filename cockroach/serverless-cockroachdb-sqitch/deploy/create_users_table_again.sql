-- Deploy sqitch-csql-sandbox:create_users_table_again to cockroach
-- requires: drop_users_table

BEGIN;

CREATE TABLE testschema.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT current_timestamp()
);

COMMIT;
