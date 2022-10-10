SHELL := /bin/bash

include ../.makeinfo
include ../.makeproject
include ../.makecommands

MODULES := go angular
TIMESTAMP ?= $(shell date +%Y%m%d%H%M%S)

.PHONY: all old new go angular clean distclean info _buildinfo

all: angular go

_buildinfo:
	@$(ECHO) "### BASE/INFO  $(PROJECT)"
	@$(ECHO) "CUSTOMER       '$(CUSTOMER)'" 
	@$(ECHO) "PROJECT        '$(PROJECT)'" 
	@$(ECHO) "COMPONENT      '$(COMPONENT)'" 
	@$(ECHO) "MODULE         '$(MODULE)'" 
	@$(ECHO) "TIMESTAMP      '$(TIMESTAMP)'" 
	@$(ECHO) "GITHASH        '$(GITHASH)'" 

angular:
	@$(MAKE) -C angular all
  
go:
	@$(MAKE) -C go all
  
info: _buildinfo
	@for i in $(MODULES) ; do \
	    if [[ ! -d "$$i" ]] ; then continue ; fi ; \
			$(MAKE) -C "$$i" info ; \
	done

clean distclean ls docker-ls:
	@for i in $(MODULES) ; do \
	    if [[ ! -d "$$i" ]] ; then continue ; fi ; \
			$(MAKE) -C "$$i" $@ ; \
	done

