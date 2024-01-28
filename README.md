# Sigstore and in-toto workshop

This is an example project used together with
[michaelvl/gha-reusable-workflows](https://github.com/michaelvl/gha-reusable-workflows)
to demonstrate Sigstore signed artifacts, SBOM and SLSA provenance.

## Verifying

```
export REPO=ghcr.io/michaelvl/sigstore-in-toto-workshop
export DIGEST=$(crane digest $REPO:latest) && echo $DIGEST
export IMAGE=$REPO@sha256:d40ba9d9eb519bf49610cf1e0ac5b6af9782ff851f4091b090067ea78f4f9e9e && echo $IMAGE

cosign tree $IMAGE

cosign verify --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-build-push.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
			  $IMAGE | jq .

cosign verify-attestation --type https://slsa.dev/provenance/v0.2 \
              --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-build-push.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
              $IMAGE > /dev/null

cosign download attestation $IMAGE | jq -r '.payload' | base64 -d | jq .
```
