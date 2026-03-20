# Extract unseal keys
UNSEAL_KEY_1=$(cat vault-init-keys.json | jq -r '.unseal_keys_b64[0]')
UNSEAL_KEY_2=$(cat vault-init-keys.json | jq -r '.unseal_keys_b64[1]')
UNSEAL_KEY_3=$(cat vault-init-keys.json | jq -r '.unseal_keys_b64[2]')

# Unseal (need 3 keys)
kubectl exec -n vault-app vault-0 -- \
  env VAULT_ADDR='https://vault.fahmed.org:8200' \
  vault operator unseal $UNSEAL_KEY_1

kubectl exec -n vault-app vault-0 -- \
  env VAULT_ADDR='https://vault.fahmed.org:8200' \
  vault operator unseal $UNSEAL_KEY_2

kubectl exec -n vault-app vault-0 -- \
  env VAULT_ADDR='https://vault.fahmed.org:8200' \
  vault operator unseal $UNSEAL_KEY_3

# Verify it's unsealed
kubectl exec -n vault-app vault-0 -- \
  env VAULT_ADDR='https://vault.fahmed.org:8200' \
  vault status
