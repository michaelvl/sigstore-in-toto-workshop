# Sigstore and in-toto workshop

This is an example project used together with
[michaelvl/gha-reusable-workflows](https://github.com/michaelvl/gha-reusable-workflows)
to demonstrate Sigstore signed artifacts, SBOM and SLSA provenance.

## Verifying

```
export REPO=ghcr.io/michaelvl/sigstore-in-toto-workshop
export DIGEST=$(crane digest $REPO:latest) && echo $DIGEST
export IMAGE=$REPO@$DIGEST && echo $IMAGE

cosign tree $IMAGE

cosign verify --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-build-push.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
			  $IMAGE | jq .

cosign verify-attestation --type https://slsa.dev/provenance/v0.2 \
              --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-build-push.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
              $IMAGE > /dev/null

cosign download attestation --predicate-type https://slsa.dev/provenance/v0.2 $IMAGE | jq -r '.payload' | base64 -d | jq .

cosign verify-attestation --type https://spdx.dev/Document \
              --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-build-push.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
              $IMAGE > /dev/null

cosign download attestation --predicate-type https://spdx.dev/Document $IMAGE | jq -r '.payload' | base64 -d | jq .
```



TODO:
- SLSA levels
- in-toto layouts
- Helm chart stored in OCI registry
- ArgoCD/Flux application, repo policy on valid repo
- Break glass, bypassing policies
- Revocation, TUF
- Vulnerability scanning
- Use Ratify with GateKeeper. https://ratify.dev/blog https://www.youtube.com/watch?v=pj8Q8nnMQWM
  - or KubeWarden https://docs.kubewarden.io/distributing-policies/secure-supply-chain#keyless-signature-validation
