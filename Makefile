# Copyright 2022 VMware. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

REQUIRED_BINARIES := imgpkg kbld ytt
BOOTIFUL_OCI_IMAGE = ghcr.io/dashaun/tce-local-bootiful
PAVED_OCI_IMAGE := ghcr.io/dashaun/tce-local-paved
REPO_OCI_IMAGE := ghcr.io/dashaun/tce-local
SOURCE_URL := $(shell git remote get-url origin)
BUILD_DATE := $(shell date +"%Y-%m-%dT%TZ")

check-carvel:
	$(foreach exec,$(REQUIRED_BINARIES),\
		$(if $(shell which $(exec)),,$(error "'$(exec)' not found. Carvel toolset is required. See instructions at https://carvel.dev/#install")))

clean:
	rm -rf repo pkg/paved/.imgpkg

lock: check-carvel # Lock files.
	vendir sync --chdir pkg/core

push: check-carvel # Build and push packages.
	rm -rf pkg/bootiful/.imgpkg && mkdir pkg/bootiful/.imgpkg && kbld -f pkg/bootiful/config --imgpkg-lock-output pkg/bootiful/.imgpkg/images.yml && \
	rm -rf pkg/paved/.imgpkg && mkdir pkg/paved/.imgpkg && kbld -f pkg/paved/config --imgpkg-lock-output pkg/paved/.imgpkg/images.yml && \
	mkdir -p repo/packages && \
    ytt -f pkg/bootiful/metadata.yaml -f pkg/bootiful/package.yaml -v pkg.bootiful=$(BOOTIFUL_OCI_IMAGE) -v source.url=$(SOURCE_URL) -v build.date=$(BUILD_DATE) > repo/packages/bootiful.yaml && \
    ytt -f pkg/paved/metadata.yaml -f pkg/paved/package.yaml -v pkg.paved=$(PAVED_OCI_IMAGE) -v source.url=$(SOURCE_URL) -v build.date=$(BUILD_DATE) > repo/packages/paved.yaml && \
	imgpkg push --bundle $(BOOTIFUL_OCI_IMAGE) --file pkg/bootiful && \
	imgpkg push --bundle $(PAVED_OCI_IMAGE) --file pkg/paved && \
	rm -rf repo/.imgpkg && mkdir -p repo/.imgpkg && \
	kbld -f repo/packages --imgpkg-lock-output repo/.imgpkg/images.yml && \
	imgpkg push --bundle $(REPO_OCI_IMAGE) --file repo

cluster-create:
	tanzu unmanaged-cluster create tce-local -c calico -p 80:80 -p 443:443

update-repo:
	tanzu package repository update tkg-core-repository --url projects.registry.vmware.com/tce/main:v0.10.3 -n tanzu-package-repo-global

repo-add:
	tanzu package repository add tce-local --url $(REPO_OCI_IMAGE) -n tanzu-package-repo-global

install-paved:
	tanzu package install local-paved --package-name paved.local.community.tanzu.vmware.com --version 1.0.0