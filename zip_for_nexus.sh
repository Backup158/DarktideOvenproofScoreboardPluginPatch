# Mods folder exists in working directory
if [ -d "mods" ]; then
    # ls to get all, pipe into wc to count
    #   store result of command
    #   commands for multiline compatibility even though i dont need it here
    things_in_mods="$(ls mods | wc -l)"
    # there should be one folder (ovenproof_scoreboard_plugin), or it's empty
    if [ $things_in_mods -lt 2 ]; then
        # delete old upload and remake directory
        gio trash "mods"
    else
        # 2: improper command usage
        echo ">=2 files in mods folder. This may be the wrong one!"
        exit 2
    fi
fi

# no mods folder 
#   make one then copy patch over to it
mkdir mods
cp -r "ovenproof_scoreboard_plugin" "mods/ovenproof_scoreboard_plugin" 
#   zip it up
zip -r "ovenproof_scoreboard_plugin_patch.zip" "mods"