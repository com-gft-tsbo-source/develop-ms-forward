SHELL := /bin/bash

include ../../.makeinfo
include ../../.makeproject
include ../../.makecommands

MODULES := $(shell find ./src -maxdepth 1 -mindepth 1 -type d | sed 's/^..//' | grep -v '^src/common$$' )
TIMESTAMP ?= $(shell date +%Y%m%d%H%M%S)

.PHONY: all old new $(MODULES) clean distclean docker info _buildinfo

DOCKER_TARGET=all
all: DOCKER_TARGET=all
all: $(MODULES)
docker: DOCKER_TARGET=docker
docker: $(MODULES)
docker-local: DOCKER_TARGET=docker-local
docker-local: $(MODULES)

_buildinfo:
	@$(ECHO) "### GO  /INFO  $(PROJECT)"
	@$(ECHO) "MODULES        $(MODULES)"
	@$(ECHO) "CUSTOMER       '$(CUSTOMER)'" 
	@$(ECHO) "PROJECT        '$(PROJECT)'" 
	@$(ECHO) "COMPONENT      '$(COMPONENT)'" 
	@$(ECHO) "MODULE         '$(MODULE)'" 
	@$(ECHO) "TIMESTAMP      '$(TIMESTAMP)'" 
	@$(ECHO) "GITHASH        '$(GITHASH)'" 

$(MODULES):
	@$(MAKE) -C $@ $(DOCKER_TARGET)

info: _buildinfo
	@for i in $(MODULES) ; do \
	    if [[ ! -d "$$i" ]] ; then continue ; fi ; \
			make -C "$$i" info ; \
	done

clean distclean ls:
	@for i in $(MODULES) ; do \
	    if [[ ! -d "$$i" ]] ; then continue ; fi ; \
			$(MAKE) -C "$$i" $@ ; \
	done

docker-ls:
	@$(ECHO) "### GO  /DOLS  $(PROJECT)"
	@while read img imgname ; do \
		$(ECHO) "I $$img $$imgname" ; \
		while read id state name image ; do \
			$(PRINTF) 'C %-7s %-10s %-20s %s\n' "$$id" "$$state" "$$name" "$$image" ; \
		done < <( $(DOCKER) container ls --filter "ancestor=$$img" --format='{{.ID}} {{.State}} {{.Names}} {{.Image}}'  | sort ) ; \
	done < <($(DOCKER) image ls --filter "label=PROJECT=$(PROJECT)" --filter "label=CUSTOMER=$(CUSTOMER)" --format='{{.ID}} {{.Repository}}:{{.Tag}}' | sort -k 2)

docker-clean:
	@$(ECHO) "### GOM /DOCLN $(PROJECT).$(MODULE).$(COMPONENT) - $(DOCKER_VARIANT)"
	@while read img imgname ; do \
		while read id state name image ; do \
			$(PRINTF) 'C %-7s %-10s %-20s %s\n' "$$id" "$$state" "$$name" "$$image" ; \
			$(DOCKER) container stop --time 5 "$$id" ; \
		done < <( $(DOCKER) container ls --filter "ancestor=$$img" --format='{{.ID}} {{.State}} {{.Names}} {{.Image}}'  | sort ) ; \
		$(ECHO) "I $$img $$imgname" ; \
		$(DOCKER) image rm -f $$img ; \
		done < <($(DOCKER) image ls --filter "label=PROJECT=$(PROJECT)" --filter "label=CUSTOMER=$(CUSTOMER)" --format='{{.ID}} {{.Repository}}:{{.Tag}}' "$(DOCKER_IMAGE)" | sort -k 2)
