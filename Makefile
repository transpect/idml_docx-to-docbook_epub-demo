# check for cygwin, get paths
ifeq ($(shell uname -o),Cygwin)
get-fullpath	= $(shell cygpath -ma "$(1)")
get-uri		= $(shell echo file:///$(call get-fullpath,$(1))  | sed -r 's/ /%20/g')
else
get-fullpath	= $(shell readlink -f "$(1)")
get-uri		= $(shell echo $(abspath $(1)) )
endif

# default values

OUT_DIR		= output
IN_FILE_BASE	= $(basename $(notdir $(IN_FILE)))
OUT_DIR_PATH	= $(call get-fullpath,$(OUT_DIR))/$(IN_FILE_BASE)
IN_FILE_COPY	= $(OUT_DIR_PATH)/$(notdir $(IN_FILE))
MAKEFILE_DIR	= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
CALABASH	= $(MAKEFILE_DIR)/calabash/calabash.sh
DEBUG		= no
DEBUG_DIR	= $(OUT_DIR_PATH)/debug
DEBUG_DIR_URI	= $(call get-uri,$(DEBUG_DIR))
STATUS_DIR	= $(OUT_DIR_PATH)/status
STATUS_DIR_URI= $(call get-uri,$(STATUS_DIR))
HEAP		= 1024m
DEVNULL		= $(call get-fullpath,/dev/null)

usage:

	@echo "Usage (one of):"
	@echo "  make conversion IN_FILE=myfile.docx"
	@echo "  make conversion IN_FILE=myfile.idml"
	@echo ""
	@echo "  Sample file invocations:"
	@echo "  make conversion IN_FILE=../content/le-tex/whitepaper/de/transpect_wp_de.docx DEBUG=yes"
	@echo ""

messages:
	@echo ""
	@echo "Makefile target: messages"
	@echo ""
	@echo "BASENAME:		$(IN_FILE_BASE)"
	@echo "OUT_DIR:		$(OUT_DIR_PATH)"
	@echo "MAKEFILE_DIR:		$(MAKEFILE_DIR)"
	@echo "CALABASH:		$(CALABASH)"
	@echo "DEBUG:			$(DEBUG)"
	@echo "DEBUG_DIR:		$(DEBUG_DIR)"
	@echo "STATUS_DIR:		$(STATUS_DIR)"

checkinput:
	@echo ""
	@echo "Makefile target: checkinput"
	@echo ""
ifeq ("$(wildcard $(IN_FILE))","")
	@echo "[ERROR] File not found. Please check IN_FILE"
	exit 1
else
	@echo "File exists $(IN_FILE)"
endif

preprocess:
	@echo ""
	@echo "Makefile target: preprocess"
	@echo ""
	-rm -rf $(OUT_DIR_PATH)
	-mkdir -p $(OUT_DIR_PATH)
	-mkdir -p $(DEBUG_DIR)
	-mkdir -p $(STATUS_DIR)
	-cp $(IN_FILE) $(IN_FILE_COPY)

transpectdemo:
	@echo ""
	@echo "Makefile target: transpectdemo"
	@echo ""
	HEAP=$(HEAP) $(CALABASH) -D \
		-o result=$(OUT_DIR_PATH)/$(IN_FILE_BASE).report.xhtml \
		-o docbook=$(OUT_DIR_PATH)/$(IN_FILE_BASE).dbk.xml \
		-o html=$(OUT_DIR_PATH)/$(IN_FILE_BASE).preview.xhtml \
		$(call get-uri,adaptions/common/xpl/trdemo-main.xpl) \
		file=$(IN_FILE_COPY) \
		status-dir-uri=$(STATUS_DIR_URI) \
		debug-dir-uri=$(DEBUG_DIR_URI) \
		debug=$(DEBUG)

postprocess:
	@echo ""
	@echo "Makefile target: postprocess"
	@echo ""
ifneq ($(DEBUG),yes)
-rm -rf $(DEBUG_DIR)
endif

archive:
	@echo ""
	@echo "Makefile target: archive"
	@echo ""
	zip -j $(OUT_DIR_PATH)/$(IN_FILE_BASE).zip $(OUT_DIR_PATH)/*

conversion: messages checkinput preprocess transpectdemo postprocess archive
	@echo ""
	@echo "Makefile target: conversion FINISHED"
	@echo ""

progress:
	@ls -1rt $(PROGRESS_DIR)/*.txt | xargs -d'\n' -I § sh -c 'date "+%H:%M:%S " -r § | tr -d [:cntrl:]; cat §'

transpectdoc: $(addprefix $(MAKEFILE_DIR)/,$(FRONTEND_PIPELINES))
	$(CALABASH) $(foreach pipe,$^,$(addprefix -i source=,$(call uri,$(pipe)))) \
		$(call uri,$(MAKEFILE_DIR)/transpectdoc/xpl/transpectdoc.xpl) \
		output-base-uri=$(call uri,$(MAKEFILEDIR)/doc/transpectdoc) \
		project-name=transpect-demo \
		debug=$(DEBUG) debug-dir-uri=$(DEBUG_DIR_URI)
