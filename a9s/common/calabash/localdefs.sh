LOCALDIR="$( cd -P "$(dirname $( readlink -f "$0" ))" && pwd )"
#CFG=$ADAPTIONS_DIR/common/calabash/xproc-config.xml

case "`hostname`" in
  don) JAVA=/usr/lib/jvm/java-6-sun/bin/java;;
  pollux) JAVA=/usr/lib/jvm/java-6-sun/bin/java;;
  aspect) JAVA=/usr/lib/jvm/java-6-sun/bin/java;;
  worker0) JAVA=/data/ASSP/ASSP_chroot/usr/local/bin/java16;;
esac

