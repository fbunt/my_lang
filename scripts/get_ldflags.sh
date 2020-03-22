#!/usr/bin/env bash
OS=$(uname)
case $OS in
    'Linux')
        echo "-Llib"
        ;;
    'Darwin')
        echo ""
        ;;
    *)
        ;;
esac
