# Rook Ceph OSD Encryption Migration Guide

This document outlines the steps to migrate existing, unencrypted Rook-Ceph OSDs to encrypted OSDs.

**<font color='red'>WARNING:</font> This is a sensitive, manual process that carries a risk of data loss if not performed carefully. Do not proceed unless you have a complete, verified backup of your data. Your Ceph cluster MUST be in a `HEALTH_OK` state before you begin this procedure.**

---

## Step 1: Verify Cluster Health

Before starting, ensure the cluster is healthy.

1. Find your `rook-ceph-tools` pod name:

    ```sh
    kubectl -n rook-ceph get pod -l app=rook-ceph-tools
    ```

2. Exec into the tools pod and check the status:

    ```sh
    kubectl -n rook-ceph exec -it <tools-pod-name> -- ceph status
    ```

The output should show `health: HEALTH_OK`. If it shows any other state (like `HEALTH_WARN` or `HEALTH_ERR`), you must resolve those issues before continuing.

---

## Step 2: Back Up Your Data

This is the most critical step. Ensure you have a complete and tested backup of all data residing in your Ceph cluster before making any changes.

---

## Step 3: Confirm Encryption is Enabled for New OSDs

Your configuration already specifies that new OSDs should be encrypted. This setting is in your `applications/rook-ceph-cluster.yaml` file under `cephClusterSpec`:

```yaml
spec:
  cephClusterSpec:
    storage:
      config:
        encryptedDevice: true
```

This means you do not need to make any configuration changes, and you can proceed directly to replacing the OSDs.

---

## Step 4: Replace OSDs (One by One)

You will repeat this process for every OSD in your cluster. It is highly recommended to **start with an OSD from an unused pool** (e.g., `ceph-blockpool-ssd`) to verify the process works as expected in your environment.

### Process for a Single OSD (e.g., osd.0)

1. **Set the `noout` flag:** This prevents Ceph from rebalancing data across the cluster while you are performing maintenance.

    ```sh
    kubectl -n rook-ceph exec -it <tools-pod-name> -- ceph osd set noout
    ```

2. **Find the OSD's Deployment:** Get the name of the deployment for the OSD you want to replace (e.g., for `osd.0`).

    ```sh
    kubectl -n rook-ceph get deployment -l ceph-osd-id=0
    ```

    This will give you a name like `rook-ceph-osd-0`.

3. **Delete the OSD Deployment:** Deleting the deployment will trigger the Rook operator to start the OSD provisioning process again. Since `encryptedDevice: true` is set, the new OSD will be created with encryption.

    ```sh
    kubectl -n rook-ceph delete deployment <osd-deployment-name>
    ```

    For example: `kubectl -n rook-ceph delete deployment rook-ceph-osd-0`

4. **Monitor Pod Recreation:** A new OSD pod will be created. You can watch its status. The old one will terminate, and a new one will start.

    ```sh
    watch kubectl -n rook-ceph get pods -l ceph-osd-id=0
    ```

5. **Verify Encryption on the New OSD:** Once the new pod is in a `Running` state, exec into it and use the `ceph-volume` command to verify that the underlying device is encrypted.

    ```sh
    kubectl -n rook-ceph exec -it <new-osd-pod-name> -- ceph-volume lvm list
    ```

    The output should show `(encrypted)` next to the OSD device.

6. **Unset the `noout` flag:** Once you have verified the new OSD is up, running, and encrypted, you can allow the cluster to rebalance data to it.

    ```sh
    kubectl -n rook-ceph exec -it <tools-pod-name> -- ceph osd unset noout
    ```

7. **Wait for Cluster to Become Healthy:** Data will now backfill to the new OSD. Wait for this process to complete and for the cluster to return to `HEALTH_OK`.

    ```sh
    watch kubectl -n rook-ceph exec -it <tools-pod-name> -- ceph status
    ```

---

## Step 5: Repeat for All OSDs

Once the cluster is healthy again, repeat the entire **Step 4** for the next OSD until all OSDs in your cluster have been replaced.
