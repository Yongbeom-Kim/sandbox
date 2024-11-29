# Serverless CockroachDB Sqitch

Example of using Sqitch to manage schemas for a Serverless CockroachDB database.


## Commands used to set up

```bash
sqitch init sqitch-csql-sandbox --uri https://github.com/Yongbeom-Kim/sandbox/cockroach/serverless-cockroachdb-sqitch --engine cockroach
sqitch config --user engine.pg.client /opt/local/pgsql/bin/psql
sqitch config --user user.name 'Yongbeom Kim'
sqitch config --user user.email 'dernbu@gmail.com'
cat ~/.sqitch/sqitch.conf


```
