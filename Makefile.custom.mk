.PHONY: build
build:
	vendir sync
	kubectl kustomize vendor/external-snapshotter --output helm/aws-ebs-csi-driver-app/templates/external-snapshotter.yaml
