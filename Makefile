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
