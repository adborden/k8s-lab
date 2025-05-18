# vault


## Create node-ca secret

Get ca.pem from vault pki. Create the secret.

    $ kubectl -n vault create secret generic node-ca --from-file=ca.crt=ca.pem
