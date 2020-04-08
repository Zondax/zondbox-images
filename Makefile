DOCKER_IMAGE="zondax/builder-yocto"

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)

ifdef INTERACTIVE
INTERACTIVE_SETTING:="-i"
TTY_SETTING:="-t"
else
INTERACTIVE_SETTING:=
TTY_SETTING:=
endif

QEMU_SERIAL1=54320
QEMU_SERIAL2=54321
GDB_SERVER=1234

SCRIPTS_DIR=/home/zondax/shared/scripts

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

pull_docker:
	docker pull $(DOCKER_IMAGE)

login: pull_docker
	$(call run_docker,zsh)

shell_bytesatwork: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxshell.sh,bytesatwork)

shell_dk2: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxshell.sh,dk2)

shell_imx8mq: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxshell.sh,imx8mq)

shell_qemu: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxshell.sh,qemu)

toaster: pull_docker
	$(call run_docker_ext,$(SCRIPTS_DIR)/zxtoaster.sh,dk2)

build_image_bytesatwork: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxbuild.sh,bytesatwork)

build_image_dk2: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxbuild.sh,dk2)

build_image_imx8mq: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxbuild.sh,imx8mq)

build_image_qemu: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxbuild.sh,qemu)

run_qemu: pull_docker
	$(call run_docker,$(SCRIPTS_DIR)/zxrun.sh,qemu)
