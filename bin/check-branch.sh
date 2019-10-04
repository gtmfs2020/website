#!/usr/bin/env bash

TARGET_BRANCH=deploy
CURRENT_BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

if [ "$CURRENT_BRANCH" != "$TARGET_BRANCH" ]; then
   echo "Error.  "
   echo "  The current branch is: $CURRENT_BRANCH"
   echo "  Expected to be on branch: $TARGET_BRANCH"
   exit -1
fi
