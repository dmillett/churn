#!/bin/bash

##
# Update your .bashrc file
# source "$path-to-script/git-simple-prompt.sh"
# PROMPT_COMMAND=git_simple_prompt
#
# Please adjust 'DEFAULT_PROMPT' accordingly for non
# git project directories. It defaults to the current
# directory path.
#
# Use 'git_toggle_prompt' to enable/disable git prompt customization
# Use 'git_toggle_prompt_suggestions' to hide excess verbiage in the prompt.
#
# Some useful defaults:
# '\w': shows entire path
# '\W': shows current directory
# '\u': shows current user
# '\s': the shell name (bash, sh, etc)
# '\v': the shell version
# '\h': the short host name (up to first '.')
##
DEFAULT_PROMPT="[\w]$ "
DEFAULT_REMOTE="origin"
DEFAULT_REMOTE_BRANCH="master"

GIT_PROMPT_ACTIVE="true"
SHOW_SUGGESTION="true"

#
# Changes the remote target. Default is 'origin'
# $1: remote target name
function git_prompt_remote() {
  
  if [[ "$1" != "origin" ]]; then
    export DEFAULT_REMOTE="$1"
  else
    export DEFAULT_REMOTE="origin"
  fi
}

#
# Setting the remote branch. Default is 'master'
# $1: the remote branch name
function git_prompt_remote_branch() {
  
  if [[ "$1" != "master" ]]; then
    export DEFAULT_REMOTE_BRANCH="$1"
  else
    export DEFAULT_REMOTE_BRANCH="master"
  fi
}

#
# Turns git prompt customization on/off in
# the current shell
function git_prompt_toggle() {

  if [[ "$GIT_PROMPT_ACTIVE" == "true" ]]; then
    export GIT_PROMPT_ACTIVE="false"
  else
    export GIT_PROMPT_ACTIVE="true"
  fi
}

# 
# Whether or not to show suggested git actions
# in the current shell
function git_prompt_toggle_suggestions() {

  if [[ "$SHOW_SUGGESTION" == "true" ]]; then
    export SHOW_SUGGESTION="false"
  else
    export SHOW_SUGGESTION="true"
  fi
}

#
# Internally build suggestion for next git action
# These suggestions are comma delimited inside parenthessi
function build_git_suggestion() {
  
  if [[ "$SHOW_SUGGESTION" == "true" ]] ; then
    message=""
    for arg in "$@"; do
      if [[ "$message" == "" ]] ; then
        message="$arg"
      else
        message="$message,$arg"
      fi
    done
    echo "($message)"
  else
    echo ""
  fi
}


# Color options
# 0: reset
# 1: bold
# 4: underline
# 5: blink
# 7: invert foreground and background
RESET="\[\e[00m\]"

# Push up to remote
# Shows as purple or yellow depending on terminal
YELLOW="\[\e[00;33m\]"
YELLOW_B="\[\e[01;33m\]"
PURPLE="\[\e[00;35m\]"
PURPLE_B="\[\e[01;35m\]"

# Minimal or no changes pending
GREEN="\[\e[00;32m\]"
GREEN_B="\[\e[01;32m\]"

# modifications, pending commit
BLUE="\[\e[00;34m\]"
BLUE_B="\[\e[01;34m\]"

# Suggestions
PUSH="↑"
FETCH="↓"
MERGE="↓↑" 
MODIFIED="*"
EXTERNAL="+"

# GIT regex
BRANCH_PATTERN="# On branch ([a-zA-Z0-9]*)"
CHANGED_PATTERN="# Changed but not updated:"
MODIFIED_PATTERN="# Changes not staged for commit:"
NEW_FILE_PATTERN="# Changes to be committed:"
UNTRACKED_PATTERN="# Untracked files:"
HAS_REMOTE_PATTERN="[remote \"(.*)\"]"
ERROR_PATTERN="fatal: "

#
# how-to
# source this file in .bashrc 
# add 'PROMPT_COMMAND=git_simple_prompt'
# source .bashrc
#
# Ready for use
function git_simple_prompt() {

  pscmd="$DEFAULT_PROMPT"
  status=`git status 2>&1`
  
  # It's a git project 
  if [[ "$GIT_PROMPT_ACTIVE" == "true" && $status =~ $BRANCH_PATTERN ]]; then
    branch="${BASH_REMATCH[1]}"
    project="\w"

    untracked=""
    if [[ $status =~ $UNTRACKED_PATTERN ]]; then
      untracked=$EXTERNAL
    fi

    color="$RESET"

    if [[ $status =~ $CHANGED_PATTERN ]]; then
      message=`build_git_suggestion "$untracked" "$MODIFIED"`
      color="$BLUE_B" 
    elif [[ $status =~ $MODIFIED_PATTERN ]]; then
      message=`build_git_suggestion "$untracked" "$MODIFIED"`
      color="$BLUE_B"
    elif [[ $status =~ $NEW_FILE_PATTERN ]]; then
      message=`build_git_suggestion "$untracked" "$MODIFIED"`
      color="$BLUE_B"
    else

      merge_remote="false"
      has_remote=`git remote -v`

      if [[ $has_remote != "" ]]; then
        diff_remote=`git diff $DEFAULT_REMOTE/$DEFAULT_REMOTE_BRANCH 2>&1`
        if [[ $diff_remote != "" ]]; then
          merge_remote="true"
        fi
      fi
 
      if [[ $merge_remote == "true" ]]; then
        message=`build_git_suggestion "$untracked" "$MERGE"`
        color="$PURPLE_B"
      else
        message=`build_git_suggestion "$untracked" ""`
        color="$GREEN_B"
      fi
    fi

    pscmd="[${color}$project:$branch$message$RESET]$ "
  fi

  export PS1="$pscmd"
}

# .bashrc PROMPT_COMMAND relies on this
export -f git_simple_prompt
export -f git_prompt_toggle
export -f git_prompt_toggle_suggestions
export -f git_prompt_remote
export -f git_prompt_remote_branch
