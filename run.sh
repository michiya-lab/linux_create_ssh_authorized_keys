#!/bin/bash

if [ $# -ne 1 ];
then
    echo "Invalid argument"
    exit 1
fi

if [ `id -u` -ne 0 ];
then
    echo "*** FATAL ERROR"
    echo " Please run as root"
fi

. functions/functions.sh

case "$1" in
"--create")
    create_authorized_key
;;
"--distribute")
    distribute_keys
;;
"--clean")
    clean_keys
;;
*)
    echo "invalid argument"
;;
esac

