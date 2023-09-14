#Arches can be: amd64 s390x arm64 ppc64le
ARCH ?= ppc64le

# The app to build
APP ?= phony

# If absent, registry defaults
REGISTRY ?= quay.io/cbade_cs/openshift-demo
ARM_REGISTRY ?= ${REGISTRY}

verify-environment:
	+@echo "REGISTRY: ${REGISTRY}"
	+@echo "ARCH: ${ARCH}"
	+@echo "ARM_REGISTRY: ${ARM_REGISTRY}"
.PHONY: verify-environment

cross-build-user: verify-environment
	+@echo "Building Image - 'user'"
	+@podman build --platform linux/${ARCH} -t ${REGISTRY}:user-${ARCH} -f automation/Dockerfile-user
	+@echo "Done Image - 'user'"
.PHONY: cross-build-user

cross-build-user-db: verify-environment
	+@echo "Building Image - 'user-db'"
	+@podman build --platform linux/${ARCH} -t ${REGISTRY}:user-db-${ARCH} -f automation/Dockerfile-user-db
	+@echo "Done Image - 'user-db'"
.PHONY: cross-build-user-db

cross-build-front-end: verify-environment
	+@echo "Building Image - 'front-end'"
	+@podman build --platform linux/${ARCH} -t ${REGISTRY}:front-end-${ARCH} -f automation/Dockerfile-front-end
	+@echo "Done Image - 'front-end'"
.PHONY: cross-build-front-end

cross-build-payment: verify-environment
	+@echo "Building Image - 'payment'"
	+@podman build --platform linux/${ARCH} -t ${REGISTRY}:payment-${ARCH} -f automation/Dockerfile-payment
	+@echo "Done Image - 'payment'"
.PHONY: cross-build-payment

cross-build-orders: verify-environment
	+@echo "Building Image - 'orders'"
	+@podman build --platform linux/${ARCH} -t ${REGISTRY}:orders-${ARCH} -f automation/Dockerfile-orders
	+@echo "Done Image - 'orders'"
.PHONY: cross-build-orders

cross-build-catalogue: verify-environment
	+@echo "Building Image - 'catalogue'"
	+@podman build --platform linux/${ARCH} -t ${REGISTRY}:catalogue-${ARCH} -f automation/Dockerfile-catalogue
	+@echo "Done Image - 'catalogue'"
.PHONY: cross-build-catalogue

cross-build-catalogue-db: verify-environment
	+@echo "Building Image - 'catalogue-db'"
	+@podman build --platform linux/${ARCH} -t ${REGISTRY}:catalogue-db-${ARCH} -f automation/Dockerfile-catalogue-db
	+@echo "Done Image - 'catalogue-db'"
.PHONY: cross-build-catalogue-db

cross-build-carts: verify-environment
	+@echo "Building Image - 'carts'"
	+@podman build --platform linux/${ARCH} -t ${REGISTRY}:carts-${ARCH} -f automation/Dockerfile-carts
	+@echo "Done Image - 'carts'"
.PHONY: cross-build-carts

cross-build-shipping: verify-environment
	+@echo "Building Image - 'shipping'"
	+@podman build --platform linux/${ARCH} -t ${REGISTRY}:shipping-${ARCH} -f automation/Dockerfile-shipping
	+@echo "Done Image - 'shipping'"
.PHONY: cross-build-shipping

cross-build-queue-master: verify-environment
	+@echo "Building Image - 'queue-master'"
	+@podman build --platform linux/${ARCH} -t ${REGISTRY}:queue-master-${ARCH} -f automation/Dockerfile-queue-master
	+@echo "Done Image - 'queue-master'"
.PHONY: cross-build-queue-master

cross-build-amd64: cross-build-user cross-build-front-end cross-build-payment cross-build-orders cross-build-catalogue cross-build-catalogue-db cross-build-carts cross-build-shipping cross-build-queue-master
.PHONY: cross-build-amd64 

# cross-build-catalogue-db is not supported on non-amd64 arches
cross-build-other: cross-build-user cross-build-front-end cross-build-payment cross-build-orders cross-build-catalogue cross-build-carts cross-build-shipping cross-build-queue-master
.PHONY: cross-build-other

# pushes the individual images
push-all-ind: verify-environment
	+@podman push ${REGISTRY}:carts-${ARCH}
	+@podman push ${REGISTRY}:catalogue-${ARCH}
	+@podman push ${REGISTRY}:front-end-${ARCH}
	+@podman push ${REGISTRY}:orders-${ARCH}
	+@podman push ${REGISTRY}:payment-${ARCH}
	+@podman push ${REGISTRY}:queue-master-${ARCH}
	+@podman push ${REGISTRY}:user-${ARCH}
	+@podman push ${REGISTRY}:shipping-${ARCH}
.PHONY: push-all-ind

push-catalogue-db: verify-environment
	+@echo "push Image - 'catalogue-db'"
	+@podman push ${REGISTRY}:catalogue-db-${ARCH}
	+@echo "Done push Image - 'catalogue-db'"
.PHONY: push-catalogue-db

push-user-db: verify-environment
	+@echo "push Image - 'user-db'"
	+@podman push ${REGISTRY}:user-db-${ARCH}
	+@echo "Done Image - 'user-db'"
.PHONY: push-user-db

# These images are build separately and only target amd64
push-db: verify-environment push-catalogue-db push-user-db
.PHONY: push-db

pull-deps:
	+@podman pull --platform linux/amd64 ${REGISTRY}:${APP}-amd64
	+@podman pull --platform linux/s390x ${REGISTRY}:${APP}-s390x
	+@podman pull --platform linux/arm64 ${ARM_REGISTRY}:${APP}-arm64
	+@podman pull --platform linux/ppc64le ${REGISTRY}:${APP}-ppc64le
.PHONY: pull-deps

# Applies to all (except catalogue-db) - generate-and-push-manifest-list.
push-ml: verify-environment pull-deps
	+@echo "Remove existing manifest listed - ${APP}"
	+@podman manifest rm ${REGISTRY}:sock-shop-${APP} || true
	+@echo "Create new ML - ${APP}"
	+@podman manifest create ${REGISTRY}:sock-shop-${APP} \
		${REGISTRY}:${APP}-amd64 \
		${REGISTRY}:${APP}-s390x \
		${ARM_REGISTRY}:${APP}-arm64 \
		${REGISTRY}:${APP}-ppc64le
	+@echo "Pushing image - ${APP}"
	+@podman manifest push ${REGISTRY}:sock-shop-${APP} ${REGISTRY}:sock-shop-${APP}
.PHONY: push-ml
