# Sigstore and in-toto workshop

This is an example project used together with
[michaelvl/gha-reusable-workflows](https://github.com/michaelvl/gha-reusable-workflows)
to demonstrate SLSA level 3 secure software supply chain.

See [SLSA Supply chain threats](https://slsa.dev/spec/v1.0/threats-overview)

## Verifying Artifacts

```
export REPO=ghcr.io/michaelvl/sigstore-in-toto-workshop
export DIGEST=$(crane digest $REPO:latest) && echo $DIGEST
export IMAGE=$REPO@$DIGEST && echo $IMAGE

cosign tree $IMAGE

# Container image signature
cosign verify --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-build-push.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
			  $IMAGE | jq .

# App SLSA provenance
cosign verify-attestation --type https://slsa.dev/provenance/v0.2 \
              --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-build-push.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
              $IMAGE > /dev/null

cosign download attestation --predicate-type https://slsa.dev/provenance/v0.2 $IMAGE | jq -r '.payload' | base64 -d | jq .

# Container SBOM
cosign verify-attestation --type https://spdx.dev/Document \
              --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-build-push.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
              $IMAGE > /dev/null

cosign download attestation --predicate-type https://spdx.dev/Document $IMAGE | jq -r '.payload' | base64 -d | jq .

# Container Trivy scan
cosign verify-attestation --type https://cosign.sigstore.dev/attestation/vuln/v1 \
              --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-scan.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
              $IMAGE > /dev/null

cosign download attestation --predicate-type https://cosign.sigstore.dev/attestation/vuln/v1 $IMAGE | jq -r '.payload' | base64 -d | jq .
```

Rekor search: https://search.sigstore.dev
