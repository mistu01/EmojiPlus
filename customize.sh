echo ''
echo '#                                         '
echo '#   _____             _ _ _____ _         '
echo '#  |   __|_____ ___  |_|_|  _  | |_ _ ___ '
echo '#  |   __|     | . | | | |   __| | | |_ -|'
echo '#  |_____|_|_|_|___|_| |_|__|  |_|___|___|'
echo '#                  |___|                  '
echo ''

# enable debugging mode
set -xv

# Maigsk Temp and Directories
# Original Paths
    [ -d ${ORIDIR:=`magisk --path`/.magisk/mirror} ] || \ # Borrowed From OMF
      ORIDIR=
      ORISYS=$ORIDIR/system
  ORISYSFONT=$ORISYS/fonts
  
# Modules paths
     SYSFONT=$MODPATH/system/fonts
	 mkdir -p $SYSFONT

# System Emoji
    DEMJ="NotoColorEmoji.ttf"	
    [ "$ORISYSFONT/$DEMJ" ] && cp "$MODPATH/Emoji.ttf" "$SYSFONT/$DEMJ" && echo "- Replacing NotoColorEmoji ✅" || ui_print "- Replacing NotoColorEmoji ❎"
	 
	SEMJ="$(find $ORISYSFONT -type f ! -name 'NotoColorEmoji.ttf' -name "*Emoji*.ttf" -exec basename {} \;)"	
	for i in $SEMJ; do
        if [ -f $SYSFONT/$DEMJ ]; then		                                                         
		    ln -s $SYSFONT/$DEMJ $SYSFONT/$i && ui_print "- Replacing $i ✅" || ui_print "- Replacing $i ❎"
        fi
    done
	
# Android 12+ | extended checking.. [?!]
    [ -d /data/fonts ] && rm -rf /data/fonts

# clear cache data of Gboard
    echo "- Clearing Gboard Cache"
    [ -d /data/data/com.google.android.inputmethod.latin ] &&
        find /data -type d -path '*inputmethod.latin*/*cache*' \
                           -exec rm -rf {} + &&
        am force-stop com.google.android.inputmethod.latin && echo "  Done ✅"
		
# change possible in-app emojis on boot time
echo 'MODDIR=${0%/*}
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
until [ -d /sdcard ]; do sleep 1; done
sleep 1 

dataemojis() {
    F1=$(find /data/data -name "*.ttf" -print | grep -E "Emoji")
    for i in $F1; do
        cp $MODDIR/system/fonts/NotoColorEmoji.ttf $i
		am force-stop com.facebook.orca
        am force-stop com.facebook.katana
		set_perm_recursive $i 0 0 0755 700		
        set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs 0 0 0755 755
        set_perm_recursive /data/data/com.facebook.orca/app_ras_blobs 0 0 0755 755
    done
}

dataemojis
pm disable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider	
rm -rf /data/fonts
rm -rf /data/data/com.google.android.gms/files/fonts/opentype/*ttf' > $MODPATH/service.sh

set_perm_recursive $MODPATH 0 0 0755 0644
rm -f $MODPATH/Emoji.ttf
rm -f $MODPATH/LICENSE