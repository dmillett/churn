#!/bin/bash

PRINT_HEADER="false"
PRINT_TAIL="true"

#
# Toggle printing the header (off by default)
function git_churn_toggle_print_header() {

  if [[ "$PRINT_HEADER" == "true" ]]; then
    export PRINT_HEADER="false"
  else
    export PRINT_HEADER="true"
  fi
}

function git_churn_toggle_print_tail() {

  if [[ "$PRINT_TAIL" == "true" ]]; then
    export PRINT_TAIL="false"
  else
    export PRINT_TAIL="true"
  fi
}

#
# Print the header (if toggled 'true')
function print_header() {

  if [[ "$PRINT_HEADER" == "true" ]]; then
    awk 'BEGIN { printf "|%7s|%7s|%11s|%11s| filename |\n", "file", "line", "growth", "shrink" }'
    awk 'BEGIN{for(c=0;c<52;c++) printf "="; printf "\n"}'
  fi
}

#
# Print the header (if toggled 'true')
function print_tail() {

  if [[ "$PRINT_TAIL" == "true" ]]; then
    awk 'BEGIN{for(c=0;c<52;c++) printf "="; printf "\n"}'
    awk 'BEGIN { printf "|%7s|%7s|%11s|%11s| filename |\n", "file", "line", "growth", "shrink" }'
  fi
}

##
# Sum file and line modifications for all files from within a git project. 
# Basic results are provided via: 
#
# 'git log --numstat'
#
# ('git log --stat' shows growth/sthrink trends)
#
# Additional arguments may be passed in via the command line similar
# to calling 'git log' directly. For example
# 
# 'git_file_churn --after="2014-06-21"'
# 'git_file_churn --after="2014-06-21 --author=dmillett'
#
function git_churn() {

  gitargs=($@)
  git log --numstat "$@"| grep "^[0-9]" | awk '{
    fmods[$3]++;
    adds[$3] += $1;
    subtracts[$3] += $2;
    lmods[$3] += ($1 + $2);
    ftotal++;
    ltotal += ($1 + $2);
    growth += $1;
    shrink += $2;
  }
  END {
    d="|"
    for (f in fmods)
      printf("%s %5s %s %5s %s %5s %s %5s %s %s %s\n", d, fmods[f], d, lmods[f], d, adds[f], d, subtracts[f], d, f, d)

    printf("%s %5s %s %5s %s %5s %s %5s %s Stat Totals %s\n", d, ftotal, d, ltotal, d, growth, d, shrink, d, d)
  }'
}

#
# Sort file modification count ascending
function git_file_churn() {
  print_header
  git_churn "$@" | sort -n --key=2
  print_tail
}

#
# Sort by line modification count per file ascending
function git_line_churn() {
  print_header
  git_churn "$@" | sort -n --key=4
  print_tail
}

#
# Sort by line growth trend/count per file ascending
function git_line_growth() {
  print_header
  git_churn "$@" | sort -n --key=6
  print_tail
}

#
# Sort by line shrink trend/count per file ascending
function git_line_shrink() {
  print_header
  git_churn "$@" | sort -n --key=8
  print_tail
}

#
# Sort by file name (regardless of count)
function git_file_sort() {
  print_header
  git_churn "$@" | sort --key=10
}
