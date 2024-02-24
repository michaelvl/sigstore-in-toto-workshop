# Sigstore and in-toto workshop

This is an example project used together with
[michaelvl/gha-reusable-workflows](https://github.com/michaelvl/gha-reusable-workflows)
to demonstrate SLSA level 3 secure software supply chain.

See [SLSA Supply chain threats](https://slsa.dev/spec/v1.0/threats-overview)

## Verifying Artifacts

Container artifact:

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

# PR provenance
cosign verify-attestation --type https://github.com/michaelvl/gha-reusable-workflows/pr-provenance  \
              --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-build-push.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
              $IMAGE > /dev/null

cosign download attestation --predicate-type https://github.com/michaelvl/gha-reusable-workflows/pr-provenance $IMAGE | jq -r '.payload' | base64 -d | jq .

# Container Trivy scan
cosign verify-attestation --type https://cosign.sigstore.dev/attestation/vuln/v1 \
              --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/container-scan.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
              $IMAGE > /dev/null

cosign download attestation --predicate-type https://cosign.sigstore.dev/attestation/vuln/v1 $IMAGE | jq -r '.payload' | base64 -d | jq .

# Verification summary attestation
cosign verify-attestation --type https://slsa.dev/verification_summary/v1 \
              --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/policy-verification.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
              $IMAGE > /dev/null

cosign download attestation --predicate-type https://slsa.dev/verification_summary/v1 $IMAGE | jq -r '.payload' | base64 -d | jq .
```

Helm chart:

```
export CHARTREPO=ghcr.io/michaelvl/sigstore-in-toto-workshop-helm
export CHARTDIGEST=$(crane digest $CHARTREPO:latest) && echo $CHARTDIGEST
export CHART=$CHARTREPO@$CHARTDIGEST && echo $CHART

cosign tree $IMAGE

# Container image signature
cosign verify --certificate-identity-regexp https://github.com/michaelvl/gha-reusable-workflows/.github/workflows/chart-build-push.yaml@refs/.* \
              --certificate-oidc-issuer https://token.actions.githubusercontent.com \
			  $CHART | jq .
```

Rekor search: https://search.sigstore.dev

## Gitsign Setup

Enable signing using Gitsign:

```
git config --local commit.gpgsign true  # Sign all commits
git config --local tag.gpgsign true  # Sign all tags
git config --local gpg.x509.program gitsign  # Use gitsign for signing
git config --local gpg.format x509  # gitsign expects x509 args
```

Merging GitHub PRs using the Web UI will sign commit using a common
GitHub key **not your own individual key**, since GitHub does not have
access to your private key.

Merging PRs while signing with your individual key:

```
# Create change
...

# Create PR
gh pr create

# Later
gh pr checkout <number>
git checkout main
git merge -
git push origin main
# PR is automatically closed

# Verify HEAD
gitsign verify --certificate-identity-regexp=.*@example.com --certificate-oidc-issuer=https://github.com/login/oauth HEAD
```

Note, that squashing commits will not close the PR.
