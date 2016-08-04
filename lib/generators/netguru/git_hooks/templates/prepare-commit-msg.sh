#!/bin/bash
checker

if [ $? == 1 ]; then
  exit 1
fi

echo ":checkered_flag:" >> $1
