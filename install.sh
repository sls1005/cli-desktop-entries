#!/usr/bin/env bash
APPS_DIR="$HOME/.local/share/applications" # If your system uses another path, change this and next line to match it.
MIME_DIR="$HOME/.local/share/mime"
CURRENT_SCRIPT_DIR=$(realpath $(dirname $0)) # If you see an error, try modifying this line.

install_all=0
flag_success=0
flag_err=0
if [ $# -gt 0 ]; then
    if [ "$1" = 'all' ]; then
        install_all=1
        shift # drop $1
    fi
    if [ -d "$MIME_DIR/packages" ]; then
        if [ $install_all -eq 1 ]; then
            for f in $(ls "$CURRENT_SCRIPT_DIR/mime_types"); do # no quote here
                f_abs_path="$CURRENT_SCRIPT_DIR/mime_types/$f"
                if [ -f "$f_abs_path" ]; then
                    echo "Copying $f_abs_path"
                    cp "$f_abs_path" "$MIME_DIR/packages/cli-desktop-entries-mime-$f" && flag_success=1 || flag_err=1
                fi
            done
        else
            for a in $@; do
                for f in $CURRENT_SCRIPT_DIR/mime_types/*$a*; do
                    f_name=$(basename $f)
                    if [ -f "$f" ]; then
                        echo "Copying $f"
                        cp "$f" "$MIME_DIR/packages/cli-desktop-entries-mime-$f_name" && flag_success=1 || flag_err=1
                    fi
                done
            done
        fi
        if [ $flag_err -eq 0 -a $flag_success -eq 1 ]; then
            update-mime-database "$MIME_DIR" || flag_err=1
        fi
    fi
    if [ -d "$APPS_DIR" ]; then
        for d in $(ls "$CURRENT_SCRIPT_DIR/shortcuts"); do
            d_abs_path="$CURRENT_SCRIPT_DIR/shortcuts/$d"
            if [ $install_all -eq 1 ]; then
                for f in $(ls "$d_abs_path"); do
                    f_abs_path="$d_abs_path/$f"
                    if [ -f "$f_abs_path" ]; then
                        echo "Copying $f_abs_path"
                        cp "$f_abs_path" "$APPS_DIR" && flag_success=1 || flag_err=1
                    fi
                done
            else
                for a in $@; do
                    for f in $d_abs_path/*$a*; do # no quote here
                        if [ -f "$f" ]; then
                            echo "Copying $f"
                            cp "$f" "$APPS_DIR" && flag_success=1 || flag_err=1
                        fi
                    done
                done
            fi
        done
        if [ $flag_err -eq 0 -a $flag_success -eq 1 ]; then
            update-desktop-database "$APPS_DIR" || flag_err=1
        fi
    fi
else
    echo "Usage: ./install.sh FILE_NAME | KEYWORD | 'all'"
    echo ''
    echo "Hint: KEYWORD can be anything. All files whose names contain any of the keywords will be placed into the directory for local applications; if you pass 'all', all files (except certain files) will be copied there."
    exit
fi

if [ $flag_err -eq 0 -a $flag_success -eq 1 ]; then
    echo "Succeeded. The desktop entry files are placed into '$APPS_DIR' and '$MIME_DIR/packages'. No error is detected."
    echo "Note that most of these shortcuts will not show up in the app menu, but in action lists, such as one that might be shown by a file manager, and they might still not show up if you don't have the corresponding package/application/program installed. If you are unable to find a shortcut, you can check if the command and all its dependecies are installed."
fi
