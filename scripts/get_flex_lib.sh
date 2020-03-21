#!/usr/bin/env bash
OS=$(uname)
case $OS in
    'Linux')
        echo "fl"
        ;;
    'Darwin')
        echo "l"
        ;;
    *)
        ;;
esac
