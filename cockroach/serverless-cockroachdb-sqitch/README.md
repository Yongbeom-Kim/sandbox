# Serverless CockroachDB Sqitch

Example of using Sqitch to manage schemas for a Serverless CockroachDB database.


## Commands used to set up

```bash
sqitch init sqitch-csql-sandbox --uri https://github.com/Yongbeom-Kim/sandbox/cockroach/serverless-cockroachdb-sqitch --engine cockroach
sqitch config --user engine.pg.client /opt/local/pgsql/bin/psql
sqitch config --user engine.cockroach.client /opt/local/pgsql/bin/psql
sqitch config --user user.name 'Yongbeom Kim'
sqitch config --user user.email 'dernbu@gmail.com'
cat ~/.sqitch/sqitch.conf

# Fix "Cannot find template" error
sudo cp /usr/local/etc/sqitch/templates/deploy/pg.tmpl /usr/local/etc/sqitch/templates/deploy/cockroach.tmpl
sudo cp /usr/local/etc/sqitch/templates/revert/pg.tmpl /usr/local/etc/sqitch/templates/revert/cockroach.tmpl
sudo cp /usr/local/etc/sqitch/templates/verify/pg.tmpl /usr/local/etc/sqitch/templates/verify/cockroach.tmpl
```
### Adding Schema
```bash
sqitch add testschema -n 'Add test schema.'
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

#### Deploying
```bash
sqitch deploy db:cockroach://kim:PASSWORD@URI
```

#### Verifying
```bash
sqitch verify db:cockroach://kim:PASSWORD@URI

```

#### Reverting
```bash
sqitch revert db:cockroach://kim:PASSWORD@URI
```

### Register Target DB
```bash
sqitch target add testdb db:cockroach://kim:PASSWORD@URI
# Now we can do
sqitch deploy testdb # etc.
```

### Register default target
```bash
sqitch engine add cockroach testdb
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
