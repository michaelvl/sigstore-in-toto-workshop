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

.PHONY: test-deploy-rejection0
test-deploy-rejection0:
	kubectl run --image cgr.dev/chainguard/nginx:latest nginx

.PHONY: test-deploy-rejection1
test-deploy-rejection1:
	kubectl run --image $(REPO)@$(shell crane digest $(REPO):latest) tester
