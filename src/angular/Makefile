SHELL := /bin/bash

include ../../.makeinfo
include ../../.makeproject
include ../../.makecommands

MODULES := $(shell find . -maxdepth 1 -mindepth 1 -type d | sed 's/^..//' )
TIMESTAMP ?= $(shell date +%Y%m%d%H%M%S)

.PHONY: all old new $(MODULES) clean distclean docker info _buildinfo

all: $(MODULES)

_buildinfo:
	@$(ECHO) "### ANG /INFO  $(PROJECT)"
	@$(ECHO) "MODULES        $(MODULES)"
	@$(ECHO) "CUSTOMER       '$(CUSTOMER)'" 
	@$(ECHO) "PROJECT        '$(PROJECT)'" 
	@$(ECHO) "COMPONENT      '$(COMPONENT)'" 
	@$(ECHO) "MODULE         '$(MODULE)'" 
	@$(ECHO) "TIMESTAMP      '$(TIMESTAMP)'" 
	@$(ECHO) "GITHASH        '$(GITHASH)'" 

$(MODULES):
	@$(MAKE) -C $@ docker

info: _buildinfo
	@for i in $(MODULES) ; do \
	    if [[ ! -d "$$i" ]] ; then continue ; fi ; \
			make -C "$$i" info ; \
	done

clean distclean ls docker-ls:
	@for i in $(MODULES) ; do \
	    if [[ ! -d "$$i" ]] ; then continue ; fi ; \
			$(MAKE) -C "$$i" $@ ; \
	done

