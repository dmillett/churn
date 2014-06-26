#!/bin/bash

PRINT_HEADER="false"

#
# Toggle printing the header (off by default)
function git_churn_toggle_header() {

  if [[ "$PRINT_HEADER" == "true" ]]; then
    export PRINT_HEADER="false"
  else
    export PRINT_HEADER="true"
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

##
# Sum file and line modifications for all files from within a git project. 
# Basic results are provided via: 
#
# 'git log --stat'
#
# Additional arguments may be passed in via the command line similar
# to calling 'git log' directly. For example
# 
# 'git_file_churn --after="2014-06-21"'
# 'git_file_churn --after="2014-06-21 --author=dmillett'      
#
function git_churn() {

  gitArguments=($@)
  git log --stat "${gitArguments[@]}" | grep -v -E "^[commit\|Author\|Date]" | grep \| | awk '{
    Mods[$1]++; 
    LineMods[$1] += $3;
    modLength = length($4) + 1;
    growthi = index($4, "+");
    growth = modLength - growthi;  
    
    if ( index($4, "+") )
      Growth[$1] += growth
    else
      Growth[$1] += 0     

    if ( index($4, "-") )
      Shrink[$1] += modLength - growth;
    else
      Shrink[$1] += 0
  }
  END {
    d="|"
    for (f in Mods)
      printf("%s %5s %s %5s %s %5s (+) %s %5s (-) %s %s %s\n", d,Mods[f],d,LineMods[f],d,Growth[f],d,Shrink[f],d,f,d)
  }'
}

#
# Sort file modification count ascending
function git_file_churn_sorted() {
  print_header
  git_churn $@ | sort -n --key=2
}

function git_line_churn_sorted() {
  print_header
  git_churn $@ | sort -n --key=4
}

function git_line_growth_sorted() {
  print_header
  git_churn $@ | sort -n --key=6
}

function git_line_shrink_sorted() {
  print_header
  git_churn $@ | sort -n --key=9
}

function git_file_sort() {
  print_header
  git_churn $@ | sort --key=10
}
