#!/bin/bash

declare -i argc=0
declare -a argv=()

progname=$(basename $0)
outfile="out.zip"
srcdir=$1
procs=1
overwrite=""
complevel="3"
varbose=""
declare -a excludes=()

usage() {
  echo "Usage:"
  echo "  ${progname} [OPTIONS] files"
  echo
  echo "Options:"
  echo "  -h, --help"
  echo "  -#: compression level, 1-19 (default: ${complevel})"
  echo "  -P, --processes NUMBER: Maximum number of processes (default: ${procs})"
  echo "  -o FILENAME: output file (default: ${outfile})"
  echo "  -v: verbose mode"
  echo "  -W: overwrite if output file already exists"
  echo "  -x PATTERN:  no compress file pattern"
  echo
  exit 1
}

: "parse options" && {
  while [ -n "$1" ]
  do
    OPT=$1
    case $OPT in
      '-h' | '--help' )
        usage
        ;;
      -[1-9] | -1[0-9] )
        complevel=${OPT:1}
        shift
        ;;
      '-P' | '--processes' )
        if [[ -z $2 ]] || [[ $2 =~ ^-+ ]] ; then
          echo "${progname}: option requires an argument -- $1" 1>&2
          exit 1
        fi
        procs=$2
        shift 2
        ;;
      '-o' )
        if [[ -z $2 ]] || [[ $2 =~ ^-+ ]] ; then
          echo "${progname}: option requires an argument -- $1" 1>&2
          exit 1
        fi
        outfile=$2
        shift 2
        ;;
      '-v' )
        verbose="yes"
        shift
        ;;
      '-W' )
        overwrite="yes"
        shift
        ;;
      '-x' )
        if [[ -z $2 ]] || [[ $2 =~ ^-+ ]] ; then
          echo "${progname}: option requires an argument -- $1" 1>&2
          exit 1
        fi
        excludes+=( "$2" )
        shift 2
        ;;
      -*)
        echo "${progname}: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
        exit 1
        ;;
      *)
        ((++argc))
        argv+=( "$1" )
        shift
        ;;
    esac
  done

  if [ -z $argv ]; then
    echo "${progname}: too few arguments" 1>&2
    usage
  fi
}

: "create excludes parameter" && {
  excludes_param=()
  for exclude in "${excludes[@]}"
  do
    excludes_param+=("-not -name \"${exclude}\"")
  done
}

: "check output zip file and overwrite" && {
  if [ -n $overwrite ] && [ -f $outfile ] ; then
    echo "${progname}: output file already exists. remove ${outfile}"
    rm ${outfile}
  fi
}

: "main" && {
  echo "${progname}: start compression"
  echo "${progname}: Maximum number of Processes: ${procs}"

  compress_dir() {
    DIR=$1
    echo "${progname}: [Directory: ${DIR}]"
    files=$( eval "find ${DIR} -type f ${excludes_param[@]} -print0" | base64)
    echo ${files} | base64 -D | xargs ${verbose:+-t} -0 -n 1 -P ${procs} zstd -${complevel:-3}
    echo ${files} | base64 -D | xargs ${verbose:+-t} -0 -n 1 -P 1 -I {} zip -0r ${outfile} {}.zst
    echo ${files} | base64 -D | xargs ${verbose:+-t} -0 -n 1 -P ${procs} -I {} rm {}.zst
    echo
  }

  compress_file() {
    FILE=$1
    echo "${progname}: [File: ${FILE}]"
    if [ -z $( eval "find ${FILE} ${excludes_param[@]}" ) ]; then
      zip -0r ${verbose:+-v} ${outfile} ${FILE}
    else
      zstd -${complevel:-3} ${FILE}
      zip -0r ${verbose:+-v} ${outfile} ${FILE}.zst
      rm ${FILE}.zst
    fi
    echo
  }

  for file in "${argv[@]}"
  do
    if [ -f $file ]; then
      compress_file $file
    fi
    if [ -d $file ]; then
      compress_dir $file
    fi
  done
}
