#!/bin/bash

declare -i argc=0
declare -a argv=()

progname=$(basename $0)
outdir="."
procs=1
varbose=""

usage() {
  echo "Usage:"
  echo "  ${progname} [OPTIONS] files"
  echo
  echo "Options:"
  echo "  -h, --help"
  echo "  -P, --processes ARG: Maximum number of processes (default: ${procs})"
  echo "  -o ARG: output directory (default: ${outdir})"
  echo "  -v: verbose mode"
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
        outdir=$2
        shift 2
        ;;
      '-v' )
        verbose="yes"
        shift
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

: "main" && {
  echo "${progname}: start decompression"
  echo "${progname}: Maximum number of Processes: ${procs}"

  decompress() {
    file=$1
    echo "[File: ${file}]"
    unzip ${file} -d ${outdir}
    find ${outdir} -type f -name "*.zst" -print0 | xargs ${verbose:+-t} -0 -n 1 -P ${procs} zstd -d --rm
    echo
  }

  for file in ${argv[@]}
  do
    if [ -f $file ]; then
      decompress $file
    fi
    if [ -d $file ]; then
      echo "${progname}: skip. ${file} is directory"
    fi
  done
}
