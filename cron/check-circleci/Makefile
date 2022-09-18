PROGRAM=server
.DEFAULT_GOAL := help

.PHONY: help build
help:
	@grep -E '^[a-z0-9A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## build
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o $(PROGRAM) "-ldflags=-s -w -buildid=" -trimpath
	docker build . -t k8s-m1.igtm.link:5000/check-circleci
push: ## push
	docker push k8s-m1.igtm.link:5000/check-circleci
cron: ## cron
	# kubectl delete -f cron.yaml
	kubectl apply -f cron.yaml
