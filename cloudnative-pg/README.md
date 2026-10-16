# cloudnative-pg

## Runbook

### Consistent recovery state has not been yet reached

During replica startup, the replica may never reach a ready state while it is waiting for recovery state.

#### Symptoms

- Replica pod remains `0/1 Running` and restarts periodically (typically every ~1 hour due to startup probe timeout).
- Replica container logs show recurring fatal connection errors:
  > postgres {"level":"info","logger":"postgres","msg":"record","record":{"error_severity":"FATAL","sql_state_code":"57P03","message":"the database system is not yet accepting connections","detail":"Consistent recovery state has not been yet reached."}}
- `kubectl cnpg status` reports the cluster phase as `Waiting for the instances to become active` and the replica status as `InternalError`.

#### Recovery

```bash
CLUSTER=mealie-db
NAMESPACE=mealie
```

1. Check replication status using [`kubectl cnpg status`](https://cloudnative-pg.io/docs/current/kubectl-plugin/#status):

   ```bash
   kubectl cnpg status "$CLUSTER" -n "$NAMESPACE"
   ```

2. Force a checkpoint on the primary via [`kubectl cnpg psql`](https://cloudnative-pg.io/docs/current/kubectl-plugin/#psql) to flush unflushed WAL buffers to the replica:

   ```bash
   kubectl cnpg psql "$CLUSTER" -n "$NAMESPACE" -- -c "CHECKPOINT;"
   ```

3. _(Fallback)_ If the replica is genuinely corrupt or required historical WAL segments are missing, recreate it using [`kubectl cnpg destroy`](https://cloudnative-pg.io/docs/current/kubectl-plugin/#destroy):

   ```bash
   INSTANCE=3
   kubectl cnpg destroy "$CLUSTER" "$INSTANCE" -n "$NAMESPACE"
   ```

#### References

- [CloudNativePG Failover & Switchover](https://cloudnative-pg.io/docs/current/failover/)
- [PostgreSQL WAL & Checkpoints](https://www.postgresql.org/docs/current/wal-configuration.html)
