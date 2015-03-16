#!/usr/bin/env bash

source "git-commit-churn.sh"

#
# For all of those Confluence wiki users out there, you can
# create a wiki table from these statistics to paste as 'markup insert'
function churn_to_confluence_table() {

  if [ -z "$1" ]
  then
    echo "Please supply wiki file name"
    return 1
  fi

  wiki_file="$1"
  git_churn_toggle_footer
  git_churn_toggle_header
  echo "{table-plus}" >> $wiki_file
  print_header | sed 's/|/||/g' | sed '/=/d' >> $wiki_file
  git_churn >> $wiki_file
  echo "{table-plus}" >> $wiki_file
}

function churn_to_R_csv() {

  if [ -z "$1" ]
  then
    echo "Please supply R csv file name"
    return 1
  fi

  csv_file="$1"
  git_churn_toggle_footer
  git_churn_toggle_header
  print_header | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/' | sed '/=/d' >> $csv_file
  git_churn | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/' >> $csv_file
}