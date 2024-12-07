# Serverless CockroachDB Sqitch

Example of using Sqitch to manage schemas for a Serverless CockroachDB database.

## Notes:
- CockroachDB 24.3+ is required for triggers. There is a bug in Terraform CockroachDB provider:
  - When applying changes to `cockroach_cluster.example`, provider "provider[\"registry.opentofu.org/cockroachdb/cockroach\"]" produced an unexpected new value: .cockroach_version: was cty.StringVal("v24.3"), but now cty.StringVal("v24.2").
  - This is why we set the version to v24.2 in `.env`.
- No trigger support
- No anonymous block support (`DO $$ ... $$ LANGUAGE plpgsql;`)
- No RETURNS TABLE support
- 

## Commands used to set up

### Create Database Cluster
```bash
make tf-init
make tf-apply
```

### Initialize Sqitch

Steps to initialize Sqitch for CockroachDB:
```bash
sqitch config --user engine.pg.client $(which psql)
sqitch config --user engine.cockroach.client $(which psql)
sqitch config --user user.name 'Yongbeom Kim'
sqitch config --user user.email 'dernbu@gmail.com'
# Always verify after deployment.
# Issue with sqitch verify: https://github.com/sqitchers/sqitch/issues/506
sqitch config --bool deploy.verify true 
sqitch config --bool rebase.verify true
cat ~/.sqitch/sqitch.conf

## Fix "Cannot find template" error
etc_dir=$(dirname $(which sqitch))/../etc/sqitch
for template in deploy revert verify; do
    sudo cp $etc_dir/templates/$template/pg.tmpl $etc_dir/templates/$template/cockroach.tmpl
done
```

Register target DB:
```bash
sqitch init sqitch-csql-sandbox --uri https://github.com/Yongbeom-Kim/sandbox/cockroach/serverless-cockroachdb-sqitch --engine cockroach
sqitch target add sandbox_db "$(make print_cockroach_sqitch_uri)"
sqitch engine add cockroach sandbox_db
```

## Commands & Deployments
```bash
sqitch add commit_name -n "Commit message"
# After adding the scripts,
sqitch deploy
sqitch verify
```

### Create Schema
```bash
sqitch add add_test_schema -n "Add schema: testschema"
```
`deploy/testschema.sql`
```sql
CREATE SCHEMA testschema;
```
`revert/testschema.sql`
```sql
DROP SCHEMA testschema;
```
`verify/testschema.sql`
The tutorial recommends the following:
```sql
SELECT pg_catalog.has_schema_privilege('testschema', 'usage');
-- Or
SELECT 1/COUNT(*) FROM information_schema.schemata WHERE schema_name = 'testschema';
-- Does not work
DO $$
BEGIN
   ASSERT (SELECT has_schema_privilege('testschema', 'usage'));
END $$;
```

I prefer to have something more explicit like the following:
```sql
-- BEGIN ROLLBACK included in the template.
BEGIN;

CREATE PROCEDURE verify_test_schema()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'testschema') THEN
        RAISE EXCEPTION 'testschema does not exist';
    END IF;
END;
$$;

CALL verify_test_schema();

DROP PROCEDURE verify_test_schema();

ROLLBACK;
```

### Drop Schema
```bash
sqitch add drop_test_schema -n "Drop schema: testschema"
```

`deploy/drop_test_schema.sql`
```sql
DROP SCHEMA testschema;
```

`revert/drop_test_schema.sql`
```sql
CREATE SCHEMA testschema;
```

`verify/drop_test_schema.sql`
```sql
-- BEGIN ROLLBACK included in the template.
BEGIN;

CREATE PROCEDURE verify_drop_test_schema()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'testschema') THEN
        RAISE EXCEPTION 'testschema still exists';
    END IF;
END;
$$;

CALL verify_drop_test_schema();

DROP PROCEDURE verify_drop_test_schema();

ROLLBACK;
```

### Create Table
```bash
sqitch add create_user_table -n "Create table testschema.users table"
```

`deploy/create_user_table.sql`
```sql
CREATE TABLE testschema.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT current_timestamp()
);
```

`revert/create_user_table.sql`
```sql
DROP TABLE testschema.users;
```

`verify/create_user_table.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_users_table()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users'
    ) THEN
        RAISE EXCEPTION 'users table does not exist';
    END IF;
END;
$$;

CALL verify_users_table();

DROP PROCEDURE verify_users_table();

ROLLBACK;
```

### Alter Table (Add Column)
```bash
sqitch add add_user_status_column -r create_user_table -n "Add status column to users table" 
```

`deploy/add_user_status_column.sql`
```sql
ALTER TABLE testschema.users
ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active';
```

`revert/add_user_status_column.sql`
```sql
ALTER TABLE testschema.users
DROP COLUMN status;
```

`verify/add_user_status_column.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_user_status_column()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users' 
        AND column_name = 'status'
    ) THEN
        RAISE EXCEPTION 'status column does not exist in users table';
    END IF;
END;
$$;

CALL verify_user_status_column();

DROP PROCEDURE verify_user_status_column();

ROLLBACK;
```

### Alter Table (Drop Column)
```bash
sqitch add drop_user_status_column -r add_user_status_column -n "Drop status column from users table"
```

`deploy/drop_user_status_column.sql`
```sql
ALTER TABLE testschema.users
DROP COLUMN status;
```

`revert/drop_user_status_column.sql`
```sql
ALTER TABLE testschema.users
ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active';
```

`verify/drop_user_status_column.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_user_status_column_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users' 
        AND column_name = 'status'
    ) THEN
        RAISE EXCEPTION 'status column still exists in users table';
    END IF;
END;
$$;

CALL verify_user_status_column_dropped();

DROP PROCEDURE verify_user_status_column_dropped();

ROLLBACK;
```

### Drop Table
```bash
sqitch add drop_users_table -r add_user_status_column -n "Drop users table"
```

`deploy/drop_users_table.sql`
```sql
DROP TABLE testschema.users;
```

`revert/drop_users_table.sql`
```sql
CREATE TABLE testschema.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT current_timestamp()
);
```

`verify/drop_users_table.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_users_table_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users'
    ) THEN
        RAISE EXCEPTION 'users table still exists';
    END IF;
END;
$$;

CALL verify_users_table_dropped();

DROP PROCEDURE verify_users_table_dropped();

ROLLBACK;
```

### Create Index
```bash
sqitch add create_users_email_idx -n "Create index on users email"
```

`deploy/add_users_email_idx.sql`
```sql
CREATE INDEX idx_users_email ON testschema.users(email);
```

`revert/add_users_email_idx.sql`
```sql
DROP INDEX testschema.idx_users_email;
```

`verify/add_users_email_idx.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_users_email_index()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_indexes 
        WHERE schemaname = 'testschema' 
        AND tablename = 'users' 
        AND indexname = 'idx_users_email'
    ) THEN
        RAISE EXCEPTION 'email index does not exist on users table';
    END IF;
END;
$$;

CALL verify_users_email_index();

DROP PROCEDURE verify_users_email_index();

ROLLBACK;
```

### Drop Index
```bash
sqitch add drop_users_email_idx -r create_users_email_idx -n "Drop index on users email"
```

`deploy/drop_users_email_idx.sql`
```sql
DROP INDEX testschema.idx_users_email;
```

`revert/drop_users_email_idx.sql`
```sql
CREATE INDEX idx_users_email ON testschema.users(email);
```

`verify/drop_users_email_idx.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_users_email_index_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM pg_indexes 
        WHERE schemaname = 'testschema' 
        AND tablename = 'users' 
        AND indexname = 'idx_users_email'
    ) THEN
        RAISE EXCEPTION 'email index still exists on users table';
    END IF;
END;
$$;

CALL verify_users_email_index_dropped();

DROP PROCEDURE verify_users_email_index_dropped();

ROLLBACK;
```

### Create View
```bash
sqitch add create_active_users_view -n "Create view equivalent to users"
```

`deploy/add_active_users_view.sql`
```sql
CREATE VIEW testschema.users_view AS
SELECT id, username, email, created_at
FROM testschema.users
WHERE 1 = 1;
```

`revert/add_active_users_view.sql`
```sql
DROP VIEW testschema.users_view;
```

`verify/add_active_users_view.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_active_users_view()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.views 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users_view'
    ) THEN
        RAISE EXCEPTION 'active_users view does not exist';
    END IF;
END;
$$;

CALL verify_active_users_view();

DROP PROCEDURE verify_active_users_view();

ROLLBACK;
```

### Drop View
```bash
sqitch add drop_active_users_view -r create_active_users_view -n "Drop active users view"
```

`deploy/drop_active_users_view.sql`
```sql
DROP VIEW testschema.users_view;
```

`revert/drop_active_users_view.sql`
```sql
-- I know, a bit strange for this to be in revert.
CREATE VIEW testschema.users_view AS
SELECT id, username, email, created_at
FROM testschema.users
WHERE 1 = 1;
```

`verify/drop_active_users_view.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_users_view_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.views 
        WHERE table_schema = 'testschema' 
        AND table_name = 'users_view'
    ) THEN
        RAISE EXCEPTION 'users_view still exists';
    END IF;
END;
$$;

CALL verify_users_view_dropped();

DROP PROCEDURE verify_users_view_dropped();

ROLLBACK;
```

### Create Function
```bash
sqitch add create_get_user_func -n "Create function to get user by username"
```

`deploy/create_get_user_func.sql`
```sql
CREATE FUNCTION testschema.get_user_by_username(IN p_username VARCHAR(50), OUT id UUID, OUT username VARCHAR(50), OUT email VARCHAR(255), OUT created_at TIMESTAMP)
LANGUAGE SQL AS $$
    SELECT u.id, u.username, u.email, u.created_at
    FROM testschema.users u
    WHERE u.username = p_username;
$$;
-- note that RETURNS TABLE is currently not supported by CockroachDB.
```

`revert/create_get_user_func.sql`
```sql
DROP FUNCTION testschema.get_user_by_username;
```

`verify/create_get_user_func.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_get_user_function()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO testschema.users (username, email) VALUES ('testuser', 'testuser@example.com');
    IF (SELECT email FROM testschema.get_user_by_username('testuser')) != 'testuser@example.com' THEN
        RAISE EXCEPTION 'get_user_by_username function does not exist, or does not return the correct user';
    END IF;
END;
$$;

CALL verify_get_user_function();

DROP PROCEDURE verify_get_user_function();

ROLLBACK;
```

### Drop Function
```bash
sqitch add drop_get_user_func -r create_get_user_func -n "Drop get user by username function"
```

`deploy/drop_get_user_func.sql`
```sql
DROP FUNCTION testschema.get_user_by_username;
```

`revert/drop_get_user_func.sql`
```sql
CREATE FUNCTION testschema.get_user_by_username(IN p_username VARCHAR(50), OUT id UUID, OUT username VARCHAR(50), OUT email VARCHAR(255), OUT created_at TIMESTAMP)
LANGUAGE SQL AS $$
    SELECT u.id, u.username, u.email, u.created_at
    FROM testschema.users u
    WHERE u.username = p_username;
$$;
```

`verify/drop_get_user_func.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_get_user_function_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.routines 
        WHERE routine_schema = 'testschema' 
        AND routine_name = 'get_user_by_username'
    ) THEN
        RAISE EXCEPTION 'get_user_by_username function still exists';
    END IF;
END;
$$;

CALL verify_get_user_function_dropped();

DROP PROCEDURE verify_get_user_function_dropped();

ROLLBACK;
```

### Create Trigger (CockroachDB 24.3+, not done right now)
```bash
sqitch add create_user_update_timestamp_trigger -n "Add trigger to update timestamp on modification"
```

`deploy/create_user_update_timestamp_trigger.sql`
```sql
CREATE FUNCTION testschema.update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified_at = current_timestamp();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_modtime
    BEFORE UPDATE ON testschema.users
    FOR EACH ROW
    EXECUTE FUNCTION testschema.update_modified_column();
```

`revert/create_user_update_timestamp_trigger.sql`
```sql
DROP TRIGGER update_users_modtime ON testschema.users;
DROP FUNCTION testschema.update_modified_column;
```

`verify/create_user_update_timestamp_trigger.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_update_timestamp_trigger()
LANGUAGE plpgsql AS $$
BEGIN
    DECLARE
        v_old_timestamp TIMESTAMP;
        v_new_timestamp TIMESTAMP;
    BEGIN
        -- Insert a test user
        INSERT INTO testschema.users (username, email) VALUES ('testuser', 'testuser@example.com');
        
        -- Get the current timestamp
        SELECT modified_at INTO v_old_timestamp FROM testschema.users WHERE username = 'testuser';
        
        -- Update the test user
        UPDATE testschema.users SET email = 'updateduser@example.com' WHERE username = 'testuser';
        
        -- Get the new timestamp
        SELECT modified_at INTO v_new_timestamp FROM testschema.users WHERE username = 'testuser';
        
        -- Check if the timestamp has been updated
        IF v_old_timestamp = v_new_timestamp THEN
            RAISE EXCEPTION 'update_users_modtime trigger did not update the timestamp';
        END IF;
        
        -- Clean up the test user
        DELETE FROM testschema.users WHERE username = 'testuser';
    END;
END;
$$;

CALL verify_update_timestamp_trigger();

DROP PROCEDURE verify_update_timestamp_trigger();

ROLLBACK;
```

### Drop Trigger (CockroachDB 24.3+, not done right now)
```bash
sqitch add drop_user_update_timestamp_trigger -r create_user_update_timestamp_trigger -n "Drop update timestamp trigger"
```

`deploy/drop_user_update_timestamp_trigger.sql`
```sql
DROP TRIGGER update_users_modtime ON testschema.users;
DROP FUNCTION testschema.update_modified_column;
```

`revert/drop_user_update_timestamp_trigger.sql`
```sql
CREATE FUNCTION testschema.update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified_at = current_timestamp();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_modtime
    BEFORE UPDATE ON testschema.users
    FOR EACH ROW
    EXECUTE FUNCTION testschema.update_modified_column();
```

`verify/drop_user_update_timestamp_trigger.sql`
```sql
BEGIN;

CREATE PROCEDURE verify_update_timestamp_trigger_dropped()
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM pg_trigger t 
        JOIN pg_class c ON t.tgrelid = c.oid 
        JOIN pg_namespace n ON c.relnamespace = n.oid 
        WHERE n.nspname = 'testschema' 
        AND c.relname = 'users' 
        AND t.tgname = 'update_users_modtime'
    ) THEN
        RAISE EXCEPTION 'update_users_modtime trigger still exists';
    END IF;
END;
$$;

CALL verify_update_timestamp_trigger_dropped();

DROP PROCEDURE verify_update_timestamp_trigger_dropped();

ROLLBACK;
```