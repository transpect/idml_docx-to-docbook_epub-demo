Invocation using GNU make:

make conversion IN_FILE=../content/le-tex/whitepaper/de/transpect_wp_de.docx debug=yes

Sample invocation using calabash.sh or calabash.bat:

calabash/calabash.sh -D \
        -i conf=file:///C:/cygwin/home/gerrit/Dev/transpect-demo/trunk/conf/conf.xml \
        -o hub=C:/cygwin/home/gerrit/Dev/transpect-demo/content/le-tex/whitepaper/de/hub/transpect_wp_de.xml \
        -o html=C:/cygwin/home/gerrit/Dev/transpect-demo/content/le-tex/whitepaper/de/epub/transpect_wp_de.xhtml \
        -o htmlreport=C:/cygwin/home/gerrit/Dev/transpect-demo/content/le-tex/whitepaper/de/report/transpect_wp_de.xhtml \
        -o schematron=C:/cygwin/home/gerrit/Dev/transpect-demo/content/le-tex/whitepaper/de/report/transpect_wp_de.sch.xml \
        -o result=//./NUL \
        file:///C:/cygwin/home/gerrit/Dev/transpect-demo/trunk/adaptions/common/xpl/docx2epub.xpl \
        docxfile=C:/cygwin/home/gerrit/Dev/transpect-demo/content/le-tex/whitepaper/de/transpect_wp_de.docx \
        check=yes \
        local-css=true \
        debug-dir-uri=file:///C:/cygwin/home/gerrit/Dev/transpect-demo/content/le-tex/whitepaper/de/debug

Please note that the pipelines work best if you pass absolute URIs. You can obtain them easily by using 
$(cygpath -ma ../content/le-tex/whitepaper/de/hub/transpect_wp_de.docx) or
file:/$(cygpath -ma conf/conf.xml), for example. 

If you don't use cygwin, you may want to use $(readlink -f …) instead of $(cygpath -ma …).
If you are using non-cygwin Windows, you are on your own, but you are invited to tell us what you found out.
