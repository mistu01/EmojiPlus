# ╭─────────────────────────────────────────╮
# │        EmojiPlus | MFFM, @MrCarb0n      │
# │  gitlab.com/MrCarb0n/NotoEmojiPlus_OMF  │
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

    ui_print '- Installing Emoji'

# get original system emoji filename
    [ $API -ge 33 ] &&
        S_EMJ="$(find $ORISYSFONT -type f \
                                  -iname '*emoji*legacy*.[ot]t[fc]' \
                                  -exec basename {} +)"
    [ $API -le 32 ] &&
        S_EMJ="$(find $ORISYSFONT -type f \
                                  -iname '*emoji*.[ot]t[fc]' \
                                ! -iname '*emoji*flags*.[ot]t[fc]' \
                                  -exec basename {} +)"
# copy to module dir
    [ $MODPATH/Emoji.ttf ] &&
        cp $MODPATH/Emoji.ttf $SYSFONT/$S_EMJ

# Android 12+ | extended checking.. [?!]
    [ -d /data/fonts ] && rm -rf /data/fonts

# clear cache data of Gboard
    [ -d /data/data/com.google.android.inputmethod.latin ] &&
        find /data -type d -path '*inputmethod.latin*/*cache*' \
                           -exec rm -rf {} + &&
        am force-stop com.google.android.inputmethod.latin

# change possible in-app emojis on boot time
    {
        echo '# ╭─────────────────────────────────────────╮'
        echo '# │        EmojiPlus | MFFM, @MrCarb0n      │'
        echo '# │  gitlab.com/MrCarb0n/NotoEmojiPlus_OMF  │'        
        echo '# ├─────────────────────────────────────────┤'
        echo '# │        credit: @MrCarb0n, MFFM.         │'
        echo '# ╰─────────────────────────────────────────╯'
        echo ''
        echo '(   '
        echo '    until [ "$(resetprop sys.boot_completed)" = "1" -a -d "/data" ]; do'
        echo '        sleep 1'
        echo '    done'
        echo '    '
        echo '    [ -d /data/fonts ] && rm -rf /data/fonts'
        echo '    '
        echo '    find /data/data -type f -iname "*emoji*.[ot]t[fc]" -print |'
        echo '        while IFS= read -r EMJ; do'
		echo "            for i in $EMJ; do"
        echo "               cp -f /system/fonts/$S_EMJ \$i"
		echo '            done'
        echo '        done'
        echo ')'
    } > $MODPATH/service.sh

rm -f $MODPATH/Emoji.ttf