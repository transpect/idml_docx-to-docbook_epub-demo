# Makefile directory
MAKEFILEDIR = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# Cygwin
ifeq ($(shell uname -o),Cygwin)
win_path = $(shell cygpath -ma "$(1)")
uri = $(shell echo file:///$(call win_path,$(1)) | sed -e 's/\s/%20/g' )
else
win_path = $(shell readlink -f "$(1)")
uri = $(shell echo $(abspath $(1)) )
endif

# replace
out_replace = $(shell echo $(1) | sed -r 's/(idml|tei|hub|epub|docx)\/([^.]+)\.[a-z]+$$/$(2)\/\2.$(3)/')
# Modified Cygwin/Windows-Java-compatible input file path:
out_path = $(call win_path,$(call out_replace,$(1),$(2),$(3)))
# Unix style destination directory
out_base = $(shell readlink -f "$(1)" | sed -r 's/(idml|tei|hub|epub|docx)\/([^.]+)\.[a-z]+$$//')

# Just a default for the targets without IN_FILE (so that there is no error when calculating OUT_DIR):
IN_FILE = generic_output

CHECK = yes
PROGRESS = yes
CALABASH = $(MAKEFILEDIR)/calabash/calabash.sh
DEBUG = no
HEAP = 1024m

OUT_DIR       = $(call out_base,$(IN_FILE),output)
ZIP_DIR = $(OUT_DIR)/zip
IN_FILE_COPY  = $(OUT_DIR)/$(notdir $(IN_FILE))
IN_FILE_BASE  = $(call out_base,$(IN_FILE),)
DEBUG_DIR     = $(call out_path,$(OUT_DIR)/debug)
DEBUG_DIR_URI = $(call uri,$(OUT_DIR)/debug)
PROGRESS_DIR  = $(DEBUG_DIR)/status
PROGRESS_DIR_URI  = $(call uri,$(OUT_DIR)/debug/status)
ACTION_LOG    = $(PROGRESS_DIR)/action.log
DEVNULL       = $(call win_path,/dev/null)
FRONTEND_PIPELINES = adaptions/common/xpl/trdemo-main.xpl \
	transpectdoc/xpl/transpectdoc.xpl

export
unexport out_base out_path win_path uri

default: usage

check_input:
ifeq ($(IN_FILE),)
	@echo Please specifiy IN_FILE
	@echo Call 'make usage' for more help.
	@exit 1
endif

mkdirs:
	@echo ""
	@echo "Makefile target: mkdirs"
	@echo ""
	-mkdir -p -v $(dir $(call out_path,$(OUT_DIR)))
	-mkdir -p -v $(DEBUG_DIR)
	-mkdir -p -v $(PROGRESS_DIR)

clean: conversion
	rm -rf $(dir $(call out_path,$(IN_FILE_COPY),report,xhtml) $(call out_path,$(IN_FILE_COPY),epub,html) $(call out_path,$(IN_FILE_COPY),epub,epub) $(call out_path,$(IN_FILE_COPY),docbook,xml)) $(IN_FILE_COPY).tmp

copy-infile:
	@echo ""
	@echo "Makefile target: copy-infile"
	@echo ""
	cp $(IN_FILE) $(IN_FILE_COPY)
	chmod 664 $(IN_FILE_COPY)
#ifeq ($(suffix $(IN_FILE)),.zip)
#	$(MAKE) unzip
#endif

#unzip:
#	@echo ""
#	@echo "Makefile target: unzip"
#	@echo ""
#	-mkdir $(ZIP_DIR)
#	unzip $(IN_FILE_COPY) -d $(ZIP_DIR)
# IN_FILE_COPY = ls  $(ZIP_DIR) | sed -e '/idml/b' -e '/docx/b' -e d
#	 @echo "$(IN_FILE_COPY)"

conversion: check_input mkdirs copy-infile
	@echo "OUTPUT DIR = $(OUT_DIR)"
	@echo "DEBUG = $(DEBUG)"
	@echo "DEBUG-DIR = $(DEBUG_DIR)"
	@echo "IN_FILE_BASE = $(IN_FILE_BASE)"
	@echo "PROGRESS = $(PROGRESS)"
	@echo "PROGRESS_DIR = $(PROGRESS_DIR)"
	@echo "ACTION_LOG = $(ACTION_LOG)"
	rm -r $(DEBUG_DIR)
	HEAP=$(HEAP) $(CALABASH) -D \
		-o result=$(DEVNULL) \
		-o docbook=$(IN_FILE_COPY).dbk.xml \
		-o html=$(IN_FILE_COPY).preview.xhtml \
		-o htmlreport=$(IN_FILE_COPY).report.xhtml \
		$(call uri,adaptions/common/xpl/trdemo-main.xpl) \
		file=$(call win_path,$(IN_FILE_COPY)) \
		check=$(CHECK) \
		progress=$(PROGRESS) \
		status-dir-uri=$(PROGRESS_DIR_URI) \
		debug-dir-uri=$(DEBUG_DIR_URI) \
		debug=$(DEBUG)
ifneq ($(DEBUG),yes)
	rm -r $(DEBUG_DIR)
	rm -r $(OUT_DIR)/epub
endif


transpectdoc: $(addprefix $(MAKEFILEDIR)/,$(FRONTEND_PIPELINES))
	$(CALABASH) $(foreach pipe,$^,$(addprefix -i source=,$(call uri,$(pipe)))) \
		$(call uri,$(MAKEFILEDIR)/transpectdoc/xpl/transpectdoc.xpl) \
		output-base-uri=$(call uri,$(MAKEFILEDIR)/doc/transpectdoc) \
		project-name=transpect-demo \
		debug=$(DEBUG) debug-dir-uri=$(DEBUG_DIR_URI)

.PHONY: transpectdoc

test:
	@echo =$(call win_path,$(IN_FILE_COPY))
	@echo $(call out_path,$(IN_FILE_COPY))
	@echo $(HUB)
	@echo $(HUBEVOLVED)

progress:
	@ls -1rt $(PROGRESS_DIR)/*.txt | xargs -d'\n' -I § sh -c 'date "+%H:%M:%S " -r § | tr -d [:cntrl:]; cat §'

usage:
	@echo "Usage (one of):"
	@echo "  make conversion IN_FILE=myfile.docx"
	@echo "  make conversion IN_FILE=myfile.idml"
	@echo ""
	@echo "  Sample file invocations:"
	@echo "  make conversion IN_FILE=../content/le-tex/whitepaper/de/transpect_wp_de.docx DEBUG=yes"
	@echo ""
