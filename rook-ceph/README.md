# rook-ceph

<https://ceph.fl.a14n.net/#/dashboard>

Use the [kubectl plugin](https://rook.io/docs/rook/latest-release/Troubleshooting/kubectl-plugin/).

## Runbook

### Check the cluster status

    kubectl rook-ceph ceph status

### Acknowledge warnings

    kubectl rook-ceph ceph crash archive-all
