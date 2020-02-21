##
## Makefile to run scripts to reduce JCMT HARP data of B30
##
## O. Morata
## 2020
##

##-- Info --------------------------------------------------------------
HOME_DIR := /lustre/opsw/work/omoratac/B30JCMT
SNAME := b30
PRJ_NAME := B30-JCMT

spec := hcop3_2

##-- End info ----------------------------------------------------------

# names of directories
#
BIN_DIR = $(HOME_DIR)/src
CFG_DIR = $(HOME_DIR)/cfg
DATA_DIR = $(HOME_DIR)/data
RES_DIR = $(HOME_DIR)/results

#SH_DIR = .

export


##-- Define Templates --------------------------------------------------


define Reduc_Template
# Template to run the reduction
#
#  parameters: 1 - species
#
.PHONY: reduce

reduce: reduce-$(1)

.PHONY: reduce-$(1)

reduce-$(1): $(RES_DIR)/$(1)/$(SNAME)-$(1)-cube.sdf

$(eval cfg_reduction := $(CFG_DIR)/reduction/reduce-$(SNAME)-$(1).cfg)

$(eval get_cube := $(RES_DIR)/$(1)/$(SNAME)-$(1)-cube.sdf)

$(get_cube): $(wildcard $(cfg_reduction))
	@if [ -f $(cfg_reduction) ];then \
            sh -c "$(BIN_DIR)/reduce_harp.sh $(cfg_reduction)" \
         else \
            echo " ignoring rule $(get_cube). No cfg file $(cfg_getflux)";\
         fi

endef



##-- End of template definition ----------------------------------------


all: reduce


#-- Auto-generate rules ------------------------------------------------

$(foreach sp, $(spec),\
    $(eval $(call Reduc_Template,$(sp)))\
)

##-- End rule generation -----------------------------------------------


.PHONY: help help_dirs help_rules list

help:
	@echo
	@echo " Makefile to analyse the data of $(PRJ_NAME)"
	@echo "-------------------------------------------"
	@echo "   Variables:"
	@echo "          Project Name = $(PRJ_NAME)"
	@echo "           File prefix = $(SNAME)"
	@echo "                 lines = $(spec)"
	@echo
	@echo "   General rule structure:"
	@echo "     make [task][-species]"
	@echo
	@echo "        where:"
	@echo "          task: all, reduce"
	@echo
	@echo "     example:  make reduce-hcop3_2"
	@echo
	@echo "   Help options:"
	@echo "      make help_dirs  -  info on directories"
	@echo



help_dirs:
	@echo
	@echo " Directory set-up:"
	@echo "-------------------"
	@echo "        project : $(HOME_DIR)"
	@echo "           bin  : $(BIN_DIR)"
	@echo "  configuration : $(CFG_DIR)"
	@echo "           data : $(DATA_DIR)"
	@echo "        results : $(RES_DIR)"
	@echo

list:
# lists all the rules in the Makefile
#
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | \
           awk -v RS= -F: '/^# File/,/^# Finished Make data base/ \
               {if ($$1 !~ "^[#.]") {print $$1}}' | sort | \
           egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

##
