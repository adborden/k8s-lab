# velero

Cluster backups.

## Runbook

### Restore a namespace

```bash
velero restore create --from-backup velero-cluster-20261116010034  --include-namespaces monitoring
```

### Restore only volumes

```bash
velero restore create --from-backup velero-cluster-20261116010034 --include-resources volumesnapshots,volumesnapshotcontents,persistentvolumeclaims,persistentvolumes --include-namespaces monitoring --namespace-mappings monitoring:default
```

Note: The `--namespace-mappings` option is used to restore the resources into a
different namespace than they were backed up from. In this example, resources
from the `monitoring` namespace are restored into the `default` namespace.
