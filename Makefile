SHELL = bash

REPO ?= ghcr.io/michaelvl/sigstore-in-toto-workshop

.PHONY: build
build:
	go build -o main .

.PHONY: lint
lint:
	docker run --rm -v $$(pwd):/app -w /app golangci/golangci-lint:v1.55.2 golangci-lint run -v  --timeout 10m

.PHONY: container
container:
	docker build -t $(REPO):latest .

.PHONY: deploy-sigstore-policy-controller
deploy-sigstore-policy-controller:
	kubectl create namespace cosign-system
	helm upgrade -i policy-controller oci://ghcr.io/sigstore/helm-charts/policy-controller --version 0.6.7 -n cosign-system
	kubectl -n cosign-system wait --for=condition=Available deployment/policy-controller-webhook

.PHONY: enable-policy-controller
enable-policy-controller:
	kubectl label namespace default policy.sigstore.dev/include=true
	kubectl apply -f deploy/clusterimagepolicy-trusted-builder.yaml
	kubectl apply -f deploy/clusterimagepolicy-vsa-slsa-level3.yaml

.PHONY: test-deploy-rejection0
test-deploy-rejection0:
	kubectl run --image cgr.dev/chainguard/nginx:latest nginx

.PHONY: test-deploy-rejection1
test-deploy-rejection1:
	kubectl run --image $(REPO)@$(shell crane digest $(REPO):latest) tester

.PHONY: deploy-app
deploy-app:
	$(eval DIGEST=$(shell crane digest ${REPO}:latest))
	helm template test-app charts/sigstore-in-toto-workshop-helm --set image.digest=${DIGEST} > app.yaml
	cat app.yaml
	kubectl apply --dry-run=server -f app.yaml

.PHONY: policy-data
policy-data:
	cosign download attestation --predicate-type https://slsa.dev/provenance/v0.2 ${IMAGE} | jq -r '.payload' | base64 -d > _provenance.json
	cosign download attestation --predicate-type https://spdx.dev/Document ${IMAGE} | jq -r '.payload' | base64 -d > _sbom.json
	cosign download attestation --predicate-type https://cosign.sigstore.dev/attestation/vuln/v1 ${IMAGE} | jq -r '.payload' | base64 -d > _vuln.json

.PHONY: policy-data-bundle
policy-data-bundle:
	echo '{}' | jq \
	  --argjson prov "$$(<_provenance.json)" \
	  --argjson sbom "$$(<_sbom.json)" \
	  --argjson vuln "$$(<_vuln.json)" \
	  '.provenance.orig.Attestation=($$prov | tojson) | .sbom.orig.Attestation=($$sbom | tojson) | .vuln.orig.Attestation=($$vuln | tojson)' > policydata.json

.PHONY: test-chart
test-chart:
	docker run --rm -i --workdir=/data --volume $(shell pwd)/charts:/data quay.io/helmpack/chart-testing:v3.10.1 ct lint --chart-dirs . --charts sigstore-in-toto-workshop-helm --validate-maintainers=false
