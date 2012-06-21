#!/bin/bash

SHOW_REPO="true"
SHOW_SUGGESTION="true"

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

# Commit changes locally
ARROW_UP="↑"
# Pull changes from remote (todo)
ARROW_DOWN="↓"

# GIT regex
BRANCH_PATTERN="^# On branch ([a-zA-Z0-9]*)"
CHANGED_PATTERN="# Changed but not updated:"
MODIFIED_PATTERN="# Changes not staged for commit:"
NEW_FILE_PATTERN="# Changes to be committed:"
UNTRACKED_PATTERN="# Untracked files:"
ERROR_PATTERN="fatal: "

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

function git_upstream_diffs_exist() {

  # todo

}

#
# how-to
# source this file in .bashrc 
# add 'PROMPT_COMMAND=git_simple_prompt'
# source .bashrc
#
# Ready for use
function git_simple_prompt() {

  # todo handle a PS that is passed to the function
  ps_default="$1 "
  pscmd="[\u:\w]$ "

  # It's a git project
  if [[ -d ".git" ]]; then
    project=${PWD##*/}
    status=`git status`

    branch=""
    if [[ "$status" =~ "$BRANCH_PATTERN" ]] ; then
      branch="${BASH_REMATCH[1]}"
    fi
      
    untracked=""
    if [[ "$status" =~ "$UNTRACKED" ]] ; then
      untracked="add"
    fi

    if [[ "$status" =~ "$CHANGED_PATTERN" ]] ; then
      message=`build_git_suggestion "$untracked" "commit"`
      pscmd="[${BLUE_B}git:$project:$branch$message$RESET]> "

    elif [[ "$status" =~ "$MODIFIED_PATTERN" ]] ; then
      message=`build_git_suggestion "$untracked" "commit"`
      pscmd="[${BLUE_B}git:$project:$branch$message$RESET]> "

    elif [[ "$status" =~ "$NEW_FILE_PATTERN" ]] ; then
      message=`build_git_suggestion "$untracked" "commit"`
      pscmd="[${BLUE_B}git:$project:$branch$message$RESET]> "

    else
      # todo: refactor this into a function
      git_upstream_diff=`git diff origin/master > /dev/null`

      if [[ "$git_upstream_diff" =~ "fatal: " ]] ; then
        message=`build_git_suggestion "$untracked" "remote setup?"`
        pscmd="[${YELLOW_B}git:$project:$branch$message$RESET]> "
      elif [[ "$git_upstream_diff" != "" ]] ; then
        message=`build_git_suggestion "$untracked" "merge"`
        pscmd="[${PURPLE_B}git:$project:$branch$message$RESET]> "
      else
        message=`build_git_suggestion "$untracked" ""`
        pscmd="[${BOLD_GREEN}git:$project:$branch$message$RESET]$ "
      fi
    fi
  fi

  export PS1="$pscmd"
}

# .bashrc PROMPT_COMMAND relies on this
export -f git_simple_prompt

#
# Whether or not to show the repo name in the git prompt
# expects path $HOME/bash/bash-help/
function git_prompt_toggle_repo() {

  cwd="$HOME/bash/bash-help/git-simple-prompt.sh"
  if [[ "$SHOW_REPO" == "true" ]]; then
    echo "Setting SHOW_REPO to 'false'"
    sed 's/SHOW_REPO=\"true\"/SHOW_REPO=\"false\"/' -i $cwd
  else
    echo "Setting SHOW_REPO to 'true'"
    sed 's/SHOW_REPO=\"false\"/SHOW_REPO=\"true\"/' -i $cwd
  fi

  source $HOME/.bashrc
}

#
# Whether or not to show suggested git actions
function git_prompt_toggle_suggestions() {

  cwd="$HOME/bash/bash-help/git-simple-prompt.sh"
  if [[ "$SHOW_SUGGESTION" == "true" ]]; then
    echo "Setting SHOW_SUGGESTION to 'false'"
    sed 's/SHOW_SUGGESTION=\"true\"/SHOW_SUGGESTION=\"false\"/' -i $cwd
  else
    echo "Setting SHOW_SUGGESTION to 'true'"
    sed 's/SHOW_SUGGESTION=\"false\"/SHOW_SUGGESTION=\"true\"/' -i $cwd
  fi

  source $HOME/.bashrc
}
