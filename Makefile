DOCKER_IMAGE="zondax/builder-yocto"

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)

ifdef INTERACTIVE
INTERACTIVE_SETTING:="-i"
TTY_SETTING:="-t"
else
INTERACTIVE_SETTING:=
TTY_SETTING:=
endif

SCRIPTS_DIR=/home/zondax/shared/scripts

QEMU_SERIAL1=54320
QEMU_SERIAL2=54321
GDB_SERVER=1234

# $(2) is MACHINE
define run_docker
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) --rm \
	--privileged \
	-u $(shell id -u) \
	-v $(shell pwd)/shared:/home/zondax/shared \
	-p $(QEMU_SERIAL1):$(QEMU_SERIAL1) \
	-p $(QEMU_SERIAL2):$(QEMU_SERIAL2) \
	-p $(QDB_SERVER):$(GDB_SERVER) \
	-e ZONDAX_CONF=$(2) \
	$(DOCKER_IMAGE) \
	"$(1)"
endef

# $(2) is MACHINE
define run_docker_ext
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) --rm \
	--privileged \
	-u $(shell id -u) \
	-v $(shell pwd)/shared:/home/zondax/shared \
	-v $(RUSTEE_APP_LOCAL):/home/zondax/hello-rustee.git \
	-p 8000:8000	\
	-e DISPLAY=$(shell echo ${DISPLAY}) \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	-e ZONDAX_CONF=$(2) \
	$(DOCKER_IMAGE) \
	"$(1)"
endef

define run_docker_recipe
	$(eval MACHINE := $(word 1, $(2)))
	$(eval RECIPE := $(word 2, $(2)))
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) --rm \
	--privileged \
	-u $(shell id -u) \
	-v $(shell pwd)/shared:/home/zondax/shared \
	-v $(RUSTEE_APP_LOCAL):/home/zondax/hello-rustee.git \
	-p 8000:8000	\
	-e DISPLAY=$(shell echo ${DISPLAY}) \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	-e ZONDAX_CONF=$(MACHINE) \
	-e ZONDAX_RECIPE=$(RECIPE) \
	$(DOCKER_IMAGE) \
	"$(1)"
endef

.PHONY: pull_docker
pull_docker:
	docker pull $(DOCKER_IMAGE)

.PHONY: pull_manifest
pull_manifest: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxfetch.sh,null)

.PHONY: login
login: pull_docker
	$(call run_docker,zsh)

.PHONY: toaster
toaster: pull_docker
	$(call run_docker_ext,$(SCRIPTS_DIR)/zxtoaster.sh,dk2)

.PHONY: shell
shell: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxshell.sh,$(filter-out $@,$(MAKECMDGOALS)))

# Building images
.PHONY: build
build: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxbuild.sh,$(filter-out $@,$(MAKECMDGOALS)))

.PHONY: run
run : pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxrun.sh,$(filter-out $@,$(MAKECMDGOALS)))

# Creating workspace so you can work locally on recipe source code
# Example:
# $ make workspace <recipe-name>
.PHONY: workspace
workspace: pull_docker
	$(call run_docker_recipe,$(SCRIPTS_DIR)/zxworkspace.sh,$(filter-out $@,$(MAKECMDGOALS)))

.PHONY: help
help:
	@echo "Usage:"
	@echo "   make pull_docker                  Fetch Zondax docker image"
	@echo "   make pull_manifest                Fetch Zondax repo manifest"
	@echo "   make login                        Simply login into docker container"
	@echo "   make build <target>               Build image for <target>"
	@echo "   make shell <target>               Get shell for <target>"
	@echo "   make workspace <target> <recipe>  Create a workspace for recipe"
	@echo "   make run <qemu|qemu8>             Run QEMU ARMv7/QEMU ARMv8 emulation"

# Drop other targets
%:
	@:
