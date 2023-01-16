# lab-k8s

Kubernetes manifests for lab cluster.


## Secrets

Secret | Description
------ | -----------
google-cloud.json | Google Cloud DNS service account key for cert-manager


Deploy the secrets.

    $ kubectl create secret generic --namespace cert-manager --from-file=secret/google-cloud.json clouddns-dns01-solver-svc-acct --from-literal=project_id=$PROJECT_ID
