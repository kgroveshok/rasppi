#!/bin/sh

# include these functions to make it easier

function gitauth {
killall ssh-agent

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/gitrsa
}

function gitupload {
git push origin master
}

gitauth
