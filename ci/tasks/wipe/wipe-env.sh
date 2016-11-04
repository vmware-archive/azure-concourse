#!/bin/bash
set -e


if [ $arg_wipe == "wipe" ];
        then
                echo "Wiping Environment...."
        else
                echo "Need Args [0]=wipe, anything else and I swear I'll exit and do nothing!!! "
                echo "Example: ./wipe-env.sh wipe ..."
                exit 0
fi


exit 1
