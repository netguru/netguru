#!/bin/sh

diff=`git diff --name-only HEAD@{1} HEAD`

migrate=`expr "$diff" : ".*db/migrate.*"`
bundle=`expr "$diff" : ".*Gemfile*"`

if [ ! "$bundle" -eq 0 ]
then
    title='Bundle needed!'
    message="You should run 'bundle install'"
    appname="Git merge"
    command -v notify-send >/dev/null 2>&1 && notify-send --icon=info "$title" "$message"
    command -v growlnotify >/dev/null 2>&1 && growlnotify -n "$appname" -m "$message" -t "$title"
    echo ""
    echo "###################################"
    echo "#  Changes in Gemfile detected!   #"
    echo "# You should run 'bundle install' #"
    echo "###################################"
    echo ""
fi

if [ ! "$migrate" -eq 0 ]
then
    title='Migration needed!'
    message="You should run 'rake db:migrate'"
    appname="Git merge"
    command -v notify-send >/dev/null 2>&1 && notify-send --icon=info "$title" "$message"
    command -v growlnotify >/dev/null 2>&1 && growlnotify -n "$appname" -m "$message" -t "$title"
    echo ""
    echo "####################################"
    echo "#     Migration file detected!     #"
    echo "# You should run 'rake db:migrate' #"
    echo "####################################"
    echo ""
fi
