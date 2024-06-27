#!/bin/bash

# For usage help run: ./stack-que.test

declare -Algx sqType
declare -gx sqReturn

# --------------------
fsqExists() {
    local pName=${1:-sqList}

    # sqType should be q or s
    if [[ ! "sqType[$pName]" =~ [qs] ]]; then
        return 1
    fi

    eval declare -p $pName 2>/dev/null | grep -q '^declare \-a'
    return $?
} # fsqExists

# --------------------
fsqNew() {
    declare -l pType=$1
    local pName=${2:-sqList}

    case $pType in
        q | que | queue)
            sqType[$pName]="q"
            ;;
        s | stk | stack)
            sqType[$pName]="s"
            ;;
        *)
            return 1
            ;;
    esac

    if fsqExists $pName; then
        fsqClear $pName
        return 0
    fi

    eval declare -gxa $pName
    return 0
} # fsqNew

# --------------------
fsqClear() {
    local pName=${1:-sqList}

    if ! fsqExists $pName; then
        return 1
    fi

    sqReturn=""
    eval $pName=\(\)
    return 0
} # fsqClear

# --------------------
fsqPush() {
    sqReturn="$1"
    local pName=${2:-sqList}

    if ! fsqExists $pName; then
        return 1
    fi

    if [ -z "$sqReturn" ]; then
        return 1
    fi

    if [ "${sqType[$pName]}" = "q" ]; then
        eval $pName=\("\${$pName[@]}" "$sqReturn"\)
    else
        eval $pName=\("$sqReturn" "\${$pName[@]}"\)
    fi
    return 0
} # fsqPush

# --------------------
fsqPop() {
    local pName=${1:-sqList}

    if ! fsqExists $pName; then
        return 1
    fi

    fsqSize $pName
    if [ $sqReturn -eq 0 ]; then
        sqReturn=""
        return 1
    fi
    eval sqReturn=\${$pName[0]}
    eval $pName=\("\${$pName[@]:1}"\)
    return 0
} # fsqPop

# --------------------
fsqSize() {
    local pName=${1:-sqList}

    if ! fsqExists $pName; then
        return 1
    fi

    eval sqReturn=\${#$pName[@]}
    return 0
} # fsqSize
