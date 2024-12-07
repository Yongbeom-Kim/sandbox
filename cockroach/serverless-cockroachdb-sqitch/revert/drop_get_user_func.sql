-- Revert sqitch-csql-sandbox:drop_get_user_func from cockroach

BEGIN;

CREATE FUNCTION testschema.get_user_by_username(IN p_username VARCHAR(50), OUT id UUID, OUT username VARCHAR(50), OUT email VARCHAR(255), OUT created_at TIMESTAMP)
LANGUAGE SQL AS $$
    SELECT u.id, u.username, u.email, u.created_at
    FROM testschema.users u
    WHERE u.username = p_username;
$$;

COMMIT;
