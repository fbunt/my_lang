#!/usr/bin/env bash
OS=$(uname)
case $OS in
    'Linux')
        echo "g++"
        ;;
    'Darwin')
        echo "g++-9"
        ;;
    *)
        ;;
esac
