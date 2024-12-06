# Serverless CockroachDB Sqitch

Example of using Sqitch to manage schemas for a Serverless CockroachDB database.


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
### Add a schema
```bash
sqitch add add_test_schema -n "Add schema: testschema"
# After adding the scripts,
sqitch deploy
sqitch verify
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



### Add table
```bash
sqitch add testtable -n 'Add test table.'
```

`deploy/testtable.sql`
```sql
CREATE TABLE testschema.testtable (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);
```

`revert/testtable.sql`
```sql
DROP TABLE testschema.testtable;
```

`verify/testtable.sql`
```sql
SELECT id, name FROM testschema.testtable WHERE FALSE;
```
