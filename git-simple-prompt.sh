#!/bin/bash

export SHOW_REPO="true"
export SHOW_SUGGESTION="true"

#
# Whether or not to show the repo name in the git prompt
# expects path $HOME/bash/bash-help/
function git_prompt_toggle_repo() {

  if [[ "$SHOW_REPO" == "true" ]]; then
    echo "Setting SHOW_REPO to 'false'"
    export $SHOW_REPO="false"
  else
    echo "Setting SHOW_REPO to 'true'"
    export $SHOW_REPO="true"
  fi
}

#
# Whether or not to show suggested git actions
function git_prompt_toggle_suggestions() {

  if [[ "$SHOW_SUGGESTION" == "true" ]]; then
    echo "Setting SHOW_SUGGESTION to 'false'"
    export $SHOW_SUGGESTION="false"
  else
    echo "Setting SHOW_SUGGESTION to 'true'"
    export $SHOW_SUGGESTION="true"
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

  #ps_default="$1 "
  pscmd="[\u:\w]$ "
  status=`git status 2>&1`
  
  # It's a git project 
  if [[ $status =~ $BRANCH_PATTERN ]]; then
    branch="${BASH_REMATCH[1]}"
    project=${PWD##*/}

    untracked=""
    if [[ $status =~ $UNTRACKED_PATTERN ]]; then
      untracked=$EXTERNAL #"add"
    fi

    color="$RESET"

    if [[ $status =~ $CHANGED_PATTERN ]]; then
      message=`build_git_suggestion "$untracked" "$MODIFIED"` #"commit"`
      color="$BLUE_B" 
    elif [[ $status =~ $MODIFIED_PATTERN ]]; then
      message=`build_git_suggestion "$untracked" "$MODIFIED"` #"commit"`
      color="$BLUE_B"
    elif [[ $status =~ $NEW_FILE_PATTERN ]]; then
      message=`build_git_suggestion "$untracked" "$MODIFIED"` #"commit"`
      color="$BLUE_B"
    else

      merge_remote="false"
      has_remote=`git remote -v`

      if [[ $has_remote != "" ]]; then
        diff_remote=`git diff origin/master`
        if [[ $diff_remote != "" ]]; then
          push_rebase_merge="true"
        fi
      fi
 
      if [[ merge_remote == "true" ]]; then
        message=`build_git_suggestion "$untracked" "$MERGE"`
        color="$PURPLE_B"
      else
        message=`build_git_suggestion "$untracked" ""`
        color="$GREEN_B"
      fi
    fi

    pscmd="[${color}git@$project:$branch$message$RESET]> "
  fi

  export PS1="$pscmd"
}

# .bashrc PROMPT_COMMAND relies on this
export -f git_simple_prompt

