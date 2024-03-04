#! /bin/sh

secrets=(
    "./kubernetes/cluster/monitoring/010-gatus-secret"
    "./kubernetes/cluster/tailscale/010-secrets"
)

# Get updated public certificate
echo "Fetching public certificate"
kubeseal --fetch-cert \
    --kubeconfig ./shaving-yaks.kubeconfig \
    --controller-name=sealed-secrets-controller \
    --controller-namespace=sealed-secrets \
    > sealed-secrets-pub.pem

# Update each secret
for s in ${secrets[@]}
do
    echo "Creating Sealed Secret: ${s}.yaml"
    kubeseal \
        --cert ./sealed-secrets-pub.pem \
        --secret-file "${s}.secret.yaml" \
        --sealed-secret-file "${s}.yaml"
done
