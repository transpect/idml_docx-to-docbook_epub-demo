MAKEFILEDIR = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifeq ($(shell uname -o),Cygwin)
win_path = $(shell cygpath -ma "$(1)")
uri = $(shell echo file:///$(call win_path,$(1))  | perl -pe 's/ /%20/g')
else
win_path = $(shell readlink -f "$(1)")
uri = $(shell echo $(abspath $(1))  | perl -pe 's/ /%20/g')
endif

# Modified Cygwin/Windows-Java-compatible input file path:
out_path = $(shell echo $(call win_path,$(1)) | perl -pe 's/^(.+)\/(.+)\.docx/$$1\/$(2)\/$$2\.$(3)/')
out_base = $(shell echo $(call win_path,$(1)) | perl -pe 's/^(.+)\/(.+)\.docx/$$1\/$(2)\//')
#out_dir  = $(shell echo $(call win_path,$(1)) | perl -pe 's/^(.+)\/(.+)\.docx/$$1\/$(2)\//')

LOCALCSS = true
CHECK = yes
CALABASH = $(MAKEFILEDIR)/calabash/calabash.sh
DEBUG = yes
HEAP = 1024m

OUT_DIR     = $(call out_base,$(IN_FILE),output)
IN_FILE_COPY = $(OUT_DIR)/$(notdir $(IN_FILE))
SCHREPORT   = $(call out_path,$(IN_FILE_COPY),report,sch.xml)
HTMLREPORT  = $(call out_path,$(IN_FILE_COPY),report,xhtml)
HTML        = $(call out_path,$(IN_FILE_COPY),epub,xhtml)
HUB         = $(call out_path,$(IN_FILE_COPY),hub,xml)
EPUB        = $(call out_path,$(IN_FILE_COPY),,epub)
DEBUG_DIR   = $(OUT_DIR)/debug
PROGRESSDIR = $(DEBUG_DIR)/status
ACTIONLOG  = $(PROGRESSDIR)/action.log
DEVNULL     = $(call win_path,/dev/null)

export
unexport out_dir out_base out_path win_path uri

default: usage

check_input:
ifeq ($(IN_FILE_COPY),)
	@echo Please specifiy IN_FILE
	@exit 1
endif

mkdirs:
	-mkdir -p -v $(dir $(call out_path,$(IN_FILE_COPY),report,xhtml) $(call out_path,$(IN_FILE_COPY),hub,xml) $(call out_path,$(IN_FILE_COPY),epub,html), $(OUT_DIR))

conversion: check_input
	@echo "OUTPUT DIR = "$(OUT_DIR)
	@echo "DEBUG = "$(DEBUG)
	@echo "DEBUG-DIR = "$(DEBUG_DIR)
	cp $(IN_FILE) $(IN_FILE_COPY)
	chmod 664 $(IN_FILE_COPY)
ifeq ($(suffix $(IN_FILE_COPY)),.docx)
	$(MAKE) docx2epub
else
ifeq ($(suffix $(IN_FILE_COPY)),.idml)
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
		-o result=$(DEVNULL) \
		$(call uri,adaptions/common/xpl/docx2epub.xpl) \
		docxfile=$(call win_path,$(IN_FILE_COPY)) \
		check=$(CHECK) \
		local-css=$(LOCALCSS) \
		debug-dir-uri=$(DEBUG_DIR)
		debug=$(DEBUG) \
	cp -v $(HTMLREPORT) $(OUT_DIR)
	cp -v $(HUB) $(OUT_DIR)

clean:
	-cd $(OUT_DIR) && rm -rf debug.zip $(HTMLREPORT) $(SCHREPORT) $(HTML) $(HUB) $(IN_FILE_COPY).tmp 


test:
	@echo =$(call win_path,$(IN_FILE_COPY))
	@echo $(call out_path,$(IN_FILE_COPY))
	@echo $(HUB)

progress:
#	@ls -lrt "$(PROGRESSDIR)/*.txt" | xargs -d'\n' cat
#	@$(shell ls -lrt $(PROGRESSDIR)/*.txt | xargs -d'\n' cat)
	@ls -1rt $(PROGRESSDIR)/*.txt | xargs -d'\n' -I § sh -c 'date "+%H:%M:%S " -r § | tr -d [:cntrl:]; cat §'

usage:
	@echo "Usage:"
	@echo "  make conversion IN_FILE=myfile.docx"
	@echo "  make doc rr=rr="
