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

# System Emoji
    DEMJ="NotoColorEmoji.ttf"	
   [ "$ORISYSFONT/$DEMJ" ] && cp "$MODPATH/Emoji.ttf" "$SYSFONT/$DEMJ" && echo "- Replacing NotoColorEmoji ✅" || ui_print "- Replacing NotoColorEmoji ❎"
	
	SEMJ="$(find $ORISYSFONT -type f ! -name 'NotoColorEmoji.ttf' -name "*Emoji*.ttf" -exec basename {} \;)"	
	for i in $SEMJ; do
        if [ -f $SYSFONT/$DEMJ ]; then		                                                         
		    ln -s $SYSFONT/$DEMJ $SYSFONT/$i && ui_print "- Replacing $i ✅" || ui_print "- Replacing $i ❎"
        fi
    done
	
	F1="$(find /data/data -name *Emoji*.ttf)"
    for i in $F1; do
        cp $MODPATH/Emoji.ttf $i && echo "- Replacing $i ✅" || ui_print "- Replacing $i ❎"
		set_perm_recursive $i 0 0 0755 700
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
echo '#!/system/bin/sh
# EmojiPlus By MFFM
# Credit: @MrCarb0n, OMF 

{   
    until [ "$(resetprop sys.boot_completed)" = "1" -a -d "/data" ]; do
        sleep 1
    done
	
	F1="$(find /data/data -name *Emoji*.ttf)"
    for i in $F1; do
        cp -f /system/fonts/NotoColorEmoji.ttf $i
		set_perm_recursive $i 0 0 0755 700
    done
	
    [ -d /data/fonts ] && rm -rf /data/fonts
}' > $MODPATH/service.sh

rm -f $MODPATH/Emoji.ttf