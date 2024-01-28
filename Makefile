.PHONY: build
build:
	go build -o main .

.PHONY: lint
lint:
	docker run --rm -v $$(pwd):/app -w /app golangci/golangci-lint:v1.55.2 golangci-lint run -v  --timeout 10m

.PHONY: container
container:
	docker build -t ghcr.io/michaelvl/sigstore-in-toto-workshop:latest .



.PHONY: deploy-sigstore-policy-controller
deploy-sigstore-policy-controller:
	kubectl create namespace cosign-system
	helm upgrade -i policy-controller oci://ghcr.io/sigstore/helm-charts/policy-controller --version 0.6.7 -n cosign-system

.PHONY: build-app
build-app:
	go build -o main main.go

.PHONY: build-container
build-container:
	docker build -t sigstore-in-toto-workshop:latest .
