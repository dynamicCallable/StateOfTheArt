#!/usr/bin/env bash

POSITIONAL=()
EXTS=()
while [[  $# -gt 0  ]]
do
    key="$1"

    case $key in
        -e|--extension)
            EXTS+=("$2")
            shift
            shift
            ;;
        -d|--depth)
            DEPTH="$2"
            shift
            shift
            ;;
        -r|--reverse)
            REVERSED=1
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL[@]}"

export DEPTH
export EXTENSIONS=$( IFS=$'|'; echo "${EXTS[*]}")
REPO_PATH=${POSITIONAL[0]}
export SEARCH_PHRASE=${POSITIONAL[1]}
GIT_PATH="$REPO_PATH/.git"

if [[ ! -d "$GIT_PATH" ]]; then
    echo "Git at ${GIT_PATH} doesn't exist"
    exit 1
fi

git --git-dir="$GIT_PATH" log -S "$SEARCH_PHRASE" --pickaxe-regex -p $( (( $REVERSED )) && printf %s '--reverse' ) | ./process_log.pl
