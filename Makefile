MAKEFILEDIR = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifeq ($(shell uname -o),Cygwin)
win_path = $(shell cygpath -ma "$(1)")
uri = $(shell echo file:///$(call win_path,$(1))  | perl -pe 's/ /%20/g')
else
win_path = $(shell readlink -f "$(1)")
uri = $(shell echo $(abspath $(1))  | perl -pe 's/ /%20/g')
endif

# Modified Cygwin/Windows-Java-compatible input file path:
out_path = $(shell echo $(call win_path,$(1)) | perl -pe 's/^(.+)\/(.+)\.(docx|idml)/$$1\/$(2)\/$$2\.$(3)/')
out_base = $(shell echo $(call win_path,$(1)) | perl -pe 's/^(.+)\/(.+)\.(docx|idml)/$$1\/$(2)\//')
#out_dir  = $(shell echo $(call win_path,$(1)) | perl -pe 's/^(.+)\/(.+)\.docx/$$1\/$(2)\//')


LOCALCSS = true
CHECK = yes
PROGRESS = yes
CALABASH = $(MAKEFILEDIR)/calabash/calabash.sh
DEBUG = yes
HEAP = 1024m

OUT_DIR     = $(call out_base,$(IN_FILE),output)
IN_FILE_COPY = $(OUT_DIR)/$(notdir $(IN_FILE))
SCHREPORT   = $(call out_path,$(IN_FILE_COPY),report,sch.xml)
HTMLREPORT  = $(call out_path,$(IN_FILE_COPY),report,xhtml)
HTML        = $(call out_path,$(IN_FILE_COPY),epub,xhtml)
HUB         = $(call out_path,$(IN_FILE_COPY),hub,xml)
HUBEVOLVED  = $(call out_path,$(IN_FILE_COPY),hub,evolved.xml)
TEI         = $(call out_path,$(IN_FILE_COPY),tei,xml)
IDML        = $(call out_path,$(IN_FILE_COPY),,idml)
EPUB        = $(call out_path,$(IN_FILE_COPY),,epub)
DEBUG_DIR   = $(call uri,$(OUT_DIR)/debug)
PROGRESSDIR = $(DEBUG_DIR)/status
ACTIONLOG  = $(PROGRESSDIR)/action.log
DEVNULL     = $(call win_path,/dev/null)

export
unexport out_dir out_base out_path win_path uri

default: usage

check_input:
ifeq ($(IN_FILE),)
	@echo Please specifiy IN_FILE
	@echo Call 'make usage' for more help.
	@exit 1
endif

mkdirs:
	-mkdir -p -v $(dir $(call out_path,$(IN_FILE_COPY),report,xhtml) $(call out_path,$(IN_FILE_COPY),hub,xml) $(call out_path,$(IN_FILE_COPY),tei,xml) $(call out_path,$(IN_FILE_COPY),epub,html))

transpect-prerequisite:
	-mkdir -p -v $(OUT_DIR)
	cp $(IN_FILE) $(IN_FILE_COPY)
	chmod 664 $(IN_FILE_COPY)

conversion: check_input transpect-prerequisite
	@echo "OUTPUT DIR = $(OUT_DIR)"
	@echo "DEBUG = $(DEBUG)"
	@echo "DEBUG-DIR = $(DEBUG_DIR)"
ifeq ($(suffix $(IN_FILE_COPY)),.docx)
	$(MAKE) docx2epub_and_docx2idml
else
ifeq ($(suffix $(IN_FILE_COPY)),.idml)
	$(MAKE) usage
endif
endif

docx2epub_and_docx2idml: check_input transpect-prerequisite mkdirs 
	HEAP=$(HEAP) $(CALABASH) -D \
		-i conf=$(call uri,conf/conf.xml) \
		-o hub=$(HUB) \
		-o html=$(HTML) \
		-o htmlreport=$(HTMLREPORT) \
		-o schematron=$(SCHREPORT) \
		-o result=$(DEVNULL) \
		$(call uri,adaptions/common/xpl/docx2epub_and_docx2idml.xpl) \
		docxfile=$(call win_path,$(IN_FILE_COPY)) \
		idml-target-uri=$(IDML) \
		check=$(CHECK) \
		progress=$(PROGRESS) \
		local-css=$(LOCALCSS) \
		debug-dir-uri=$(DEBUG_DIR)
		debug=$(DEBUG) \
	cp -v $(HTMLREPORT) $(OUT_DIR)
	cp -v $(HUB) $(OUT_DIR)

docx2idml: check_input transpect-prerequisite mkdirs
	HEAP=$(HEAP) $(CALABASH) -D \
		-i conf=$(call uri,conf/conf.xml) \
		-o hub=$(HUB) \
		-o result=$(DEVNULL) \
		$(call uri,adaptions/common/xpl/docx2idml.xpl) \
		docxfile=$(call win_path,$(IN_FILE_COPY)) \
		idml-target-uri=$(IDML) \
		debug-dir-uri=$(DEBUG_DIR)
		debug=$(DEBUG)

docx2epub: check_input transpect-prerequisite mkdirs 
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

idml2epub_hub: check_input transpect-prerequisite mkdirs 
	HEAP=$(HEAP) $(CALABASH) -D \
		-i conf=$(call uri,conf/conf.xml) \
		-o hub=$(HUB) \
		-o hubevolved=$(HUBEVOLVED) \
		-o html=$(HTML) \
		-o htmlreport=$(HTMLREPORT) \
		-o schematron=$(SCHREPORT) \
		-o result=$(DEVNULL) \
		$(call uri,adaptions/common/xpl/idml2epub_hub.xpl) \
		idmlfile=$(call win_path,$(IN_FILE_COPY)) \
		idml-target-uri=$(IDML) \
		check=$(CHECK) \
		local-css=$(LOCALCSS) \
		debug-dir-uri=$(DEBUG_DIR)
		debug=$(DEBUG) \
	cp -v $(HUB) $(OUT_DIR)
	cp -v $(HUBEVOLVED) $(OUT_DIR)
	cp -v $(HTML) $(OUT_DIR)
	cp -v $(HTMLREPORT) $(OUT_DIR)

idml2epub_tei_onix: check_input transpect-prerequisite mkdirs 
	HEAP=$(HEAP) $(CALABASH) -D \
		-i conf=$(call uri,conf/conf.xml) \
		-o hub=$(HUB) \
		-o tei=$(TEI) \
		-o html=$(HTML) \
		-o htmlreport=$(HTMLREPORT) \
		-o schematron=$(SCHREPORT) \
		-o result=$(DEVNULL) \
		$(call uri,adaptions/common/xpl/idml2epub_tei_onix.xpl) \
		idmlfile=$(call win_path,$(IN_FILE_COPY)) \
		idml-target-uri=$(IDML) \
		check=$(CHECK) \
		local-css=$(LOCALCSS) \
		debug-dir-uri=$(DEBUG_DIR)
		debug=$(DEBUG) \
	cp -v $(HUB) $(OUT_DIR)
	cp -v $(TEI) $(OUT_DIR)
#	cp -v $(HTML) $(OUT_DIR)
#	cp -v $(HTMLREPORT) $(OUT_DIR)

clean:
	-cd $(OUT_DIR) && rm -rf debug.zip $(HTMLREPORT) $(SCHREPORT) $(HTML) $(HUB) $(IN_FILE_COPY).tmp 


test:
	@echo =$(call win_path,$(IN_FILE_COPY))
	@echo $(call out_path,$(IN_FILE_COPY))
	@echo $(HUB)
	@echo $(HUBEVOLVED)


progress:
#	@ls -lrt "$(PROGRESSDIR)/*.txt" | xargs -d'\n' cat
#	@$(shell ls -lrt $(PROGRESSDIR)/*.txt | xargs -d'\n' cat)
	@ls -1rt $(PROGRESSDIR)/*.txt | xargs -d'\n' -I § sh -c 'date "+%H:%M:%S " -r § | tr -d [:cntrl:]; cat §'

usage:
	@echo "Usage (one of):"
	@echo "  make conversion IN_FILE=myfile.docx"
	@echo "  make docx2idml IN_FILE=myfile.docx"
	@echo "  make docx2epub IN_FILE=myfile.docx"
	@echo "  make idml2epub_hub IN_FILE=myfile.idml"
	@echo "  make idml2epub_tei_onix IN_FILE=myfile.idml"
	@echo ""
	@echo "  Sample file invocations:"
	@echo "  make conversion IN_FILE=../content/le-tex/whitepaper/de/transpect_wp_de.docx DEBUG=yes"
	@echo ""
	@echo "  - Campus sample (hub output is preferred):"
	@echo "    make conversion IN_FILE=../content/campus/sample/transpect_wp_de.docx"
