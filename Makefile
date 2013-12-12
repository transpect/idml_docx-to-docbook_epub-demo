MAKEFILEDIR = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

export
unexport win_path uri out_path out_base

ifeq ($(shell uname -o),Cygwin)
win_path = $(shell cygpath -ma "$(1)")
uri = $(shell echo file:///$(call win_path,$(1))  | perl -pe 's/ /%20/g')
else
win_path = $(shell readlink -f "$(1)")
uri = $(shell echo file:$(abspath $(1))  | perl -pe 's/ /%20/g')
endif

# Modified Cygwin/Windows-Java-compatible input file path:
out_path = $(shell echo $(call win_path,$(1)) | perl -pe 's/^(.+)\/(.+)\.docx/$$1\/$(2)\/$$2\.$(3)/')
out_base = $(shell echo $(call win_path,$(1)) | perl -pe 's/^(.+)\/(.+)\.docx/$$1\/$(2)\//')
out_dir  = $(shell echo $(call win_path,$(1)) | perl -pe 's/^(.+)\/(.+)\.docx/$$1\/$(2)\//')

LOCALCSS = true
CHECK = yes
CALABASH = $(MAKEFILEDIR)/calabash/calabash.sh
DEBUG = no
HEAP = 1024m

OUT_DIR    = $(call out_dir,$(IN_FILE),output)
SCHREPORT = $(call out_path,$(IN_FILE),report,sch.xml)
HTMLREPORT = $(call out_path,$(IN_FILE),report,xhtml)
HTML       = $(call out_path,$(IN_FILE),epub,xhtml)
HUB        = $(call out_path,$(IN_FILE),hub,xml)
EPUB       = $(call out_path,$(IN_FILE),,epub)
DEBUG_DIR  = $(call uri,$(call out_base,$(IN_FILE),debug))

export
unexport out_base out_path win_path uri

default: usage

check_input:
ifeq ($(IN_FILE),)
	@echo Please specifiy IN_FILE
	@exit 1
endif

mkdirs:
	-mkdir -p -v $(dir $(call out_path,$(IN_FILE),report,xhtml) $(call out_path,$(IN_FILE),hub,xml) $(call out_path,$(IN_FILE),epub,html), $(OUT_DIR))

conversion: check_input
	@echo "OUTPUT DIR = "$(OUT_DIR)
	@echo "DEBUG = "$(DEBUG)
	@echo "DEBUG-DIR = "$(DEBUG_DIR)
ifeq ($(suffix $(IN_FILE)),.docx)
	$(MAKE) docx2epub
else
ifeq ($(suffix $(IN_FILE)),.idml)
	$(MAKE) check_input
endif
endif

docx2epub: mkdirs 
	HEAP=$(HEAP) $(CALABASH) -D \
		-i conf=$(call uri,conf/conf.xml) \
		-o hub=$(HUB) \
		-o html=$(HTML) \
		-o htmlreport=$(HTMLREPORT) \
		-o schematron=$(SCHREPORT) \
		$(call uri,adaptions/common/xpl/docx2epub.xpl) \
		docxfile=$(call win_path,$(IN_FILE)) \
		check=$(CHECK) \
		local-css=$(LOCALCSS) \
		debug-dir-uri=$(DEBUG_DIR)
		debug=$(DEBUG) \
	cp -v $(HTMLREPORT) $(OUT_DIR)
	cp -v $(EPUB) $(OUT_DIR)
	cp -v $(HUB) $(OUT_DIR)

test:
	@echo =$(call win_path,$(IN_FILE))
	@echo $(call out_path,$(IN_FILE))
	@echo $(HUB)

usage:
	@echo "Usage:"
	@echo "  make conversion IN_FILE=myfile.docx"
	@echo "  make doc rr=rr="
