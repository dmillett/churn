#!/bin/bash

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
git_churn() {

  gitArguments=($@)
  git log --stat "${gitArguments[@]}" | grep -v -E "^[commit\|Author\|Date]" | grep \| | awk '{
    Mods[$1]++; 
    LineMods[$1] += $3;
    modLength = length($4) + 1;

    if ( index($4, "+") )
      Growth[$1] = modLength - index($4, "-");

     if ( index($4, "-") )
       Shrink[$1] = modLength - Growth[$1];
  }
  END {
    del="|"
    for (f in Mods)
      print del, Mods[f], del, LineMods[f], del, f, del, Growth[f], del, Shrink[f], del
  }'
}

#
# Sort file modification count ascending
git_file_churn_sorted() {
  git_churn $@ | sort -n --key=2
}

git_line_churn_sorted() {
  git_churn $@ | sort -n --key=4
  #echo ""
}
