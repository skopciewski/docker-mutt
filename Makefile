TM := $(shell date +%Y%m%d)

build:
	docker build \
		-t skopciewski/mutt:$(TM) \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--cache-from skopciewski/mutt:$(TM) \
		.
.PHONY: build

push:
	docker push skopciewski/mutt:$(TM)
	docker tag skopciewski/mutt:$(TM) skopciewski/mutt:latest
	docker push skopciewski/mutt:latest

.PHONY: push

push_all:
	docker push skopciewski/mutt
.PHONY: push_all
