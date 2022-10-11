# ╭─────────────────────────────────────────╮
# │           EmojiPlus | MFFM              │
# │ github.com/charityrolfson433/EmojiPlus  │
# ├─────────────────────────────────────────┤
# │      credit: @MrCarb0n, MFFM, OMF       │
# ╰─────────────────────────────────────────╯

# enable debugging mode
set -xv

# Maigsk Temp and Directories
[ -d ${MAGISKTMP:=`magisk --path`/.magisk} ] && \
      ORIDIR=$MAGISKTMP/mirror
      ORISYS=$ORIDIR/system
  ORISYSFONT=$ORISYS/fonts
  
# Modules paths
     SYSFONT=$MODPATH/system/fonts

# System Emoji
    DEMJ="NotoColorEmoji.ttf"	
    [ $ORISYSFONT/$DEMJ ] && cp $MODPATH/Emoji.ttf $SYSFONT/$DEMJ;	
	
	SEMJ="$(find $ORISYSFONT -type f ! -name 'NotoColorEmoji.ttf' -name "*Emoji*.ttf" -exec basename {} \;)"	
	for i in $SEMJ; do
        if [ -f $SYSFONT/$DEMJ ]; then		                                                         
		    ln -s $SYSFONT/$DEMJ $SYSFONT/$i
        fi
    done

# Data directory Emoji replacements
	F1="$(find /data/data -name *Emoji*.ttf)"
        for i in $F1; do
            cp -f /system/fonts/NotoColorEmoji.ttf $i
			set_perm_recursive $i 0 0 0755 700
        done

# Android 12+ | extended checking.. [?!]
    [ -d /data/fonts ] && rm -rf /data/fonts

# clear cache data of Gboard
    [ -d /data/data/com.google.android.inputmethod.latin ] &&
        find /data -type d -path '*inputmethod.latin*/*cache*' \
                           -exec rm -rf {} + &&
        am force-stop com.google.android.inputmethod.latin

# change possible in-app emojis on boot time
echo '# ╭─────────────────────────────────────────╮
# │            EmojiPlus | MFFM             │
# │  github.com/charityrolfson433/EmojiPlus │
# ├─────────────────────────────────────────┤
# │        credit: @MrCarb0n, MFFM.         │
# ╰─────────────────────────────────────────╯

(   
    until [ "$(resetprop sys.boot_completed)" = "1" -a -d "/data" ]; do
        sleep 1
    done	
	
    [ -d /data/fonts ] && rm -rf /data/fonts    
)' > $MODPATH/service.sh

rm -f $MODPATH/Emoji.ttf