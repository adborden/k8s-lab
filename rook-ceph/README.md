# rook-ceph

<https://ceph.fl.a14n.net/#/dashboard>

Use the [kubectl plugin](https://rook.io/docs/rook/latest-release/Troubleshooting/kubectl-plugin/).

## Runbook

### Check the cluster status

```bash
    kubectl rook-ceph ceph status
```

### Acknowledge warnings

Clear recent crashes.

```bash
kubectl rook-ceph ceph crash archive-all
```

View recent health check events.

```bash
kubectl rook-ceph ceph healthcheck history ls
```

Clear health check history. Do this after an incident so we have a fresh
history for the next one.

```bash
kubectl rook-ceph ceph healthcheck history clear
```

### Drain an OSD

Mark the OSD as `out` to remap pgs and remove the disk from service.

```bash
kubectl rook-ceph osd out <osd-id>
```

### Maintenance mode

See [docs](https://github.com/rook/kubectl-rook-ceph/blob/master/docs/maintenance.md).

### Repair node or disk

1. (optional) Drain OSD
2. Disable argocd autosync
3. Scale down rook-ceph-operator

Create a sync window to disable autosync.

```bash
kubectl -n argocd patch appproject default --type merge --patch '{"spec":{"syncWindows":[{"applications":["rook-ceph"],"duration":"1h","kind":"deny","manualSync":true,"namespaces":["rook-ceph"],"schedule":"* * * * *"}]}}'
```

Scale down rook-ceph-operator.

```bash
kubectl -n rook-ceph scale deployment rook-ceph-operator --replicas=0
```

Re-enable ArgoCD autosync.

```bash
kubectl -n argocd patch appproject default --type merge --patch '{"spec":{"syncWindows":[]}}'
```

### View rdb task list

```bash
k rook-ceph ceph rbd task list
```
