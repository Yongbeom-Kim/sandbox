-- Deploy sqitch-csql-sandbox:testtable to cockroach
-- requires: testschema

BEGIN;

-- XXX Add DDLs here.
CREATE TABLE testschema.testtable (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

COMMIT;
