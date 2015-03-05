#!/usr/bin/env bash

PRINT_HEADER="false"
PRINT_TAIL="true"

#
# Toggle printing the header (off by default)
function git_churn_toggle_header() {

  if [[ "$PRINT_HEADER" == "true" ]]; then
    export PRINT_HEADER="false"
  else
    export PRINT_HEADER="true"
  fi
}

function git_churn_toggle_tail() {

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
    awk 'BEGIN { printf "| %7s | %7s | %-7s | %-7s | %7s | filename/stats |\n", "files", "lines", "growth", "shrink", "net(+/-)" }'
    awk 'BEGIN{ for(c=0;c<69;c++) printf "="; printf "\n"}'
  fi
}

#
# Print the header (if toggled 'true')
function print_tail() {

  if [[ "$PRINT_TAIL" == "true" ]]; then
    awk 'BEGIN{ for(c=0;c<69;c++) printf "="; printf "\n"}'
    awk 'BEGIN { printf "| %7s | %7s | %-7s | %-7s | %7s | filename/stats |\n", "files", "lines", "growth", "shrink", "net(+/-)" }'
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
function git_churn() {

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
    for (f in fmods)
    {
      net =  adds[f] - subtracts[f]
      printf("| %7s | %7s | %7s | %7s | %8s | %-s |\n", fmods[f], lmods[f], adds[f], subtracts[f], net, f)
    }

    totals = growth - shrink
    printf("| %7s | %7s | %7s | %7s | %8s | Stat Totals |\n", ftotal, ltotal, growth, shrink, totals)
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
# Sort by net growth
function git_net_growth() {
  print_header
  git_churn "$@" | sort -n --key=10
  print_tail
}

#
# Sort by net shrink
function git_net_shrink() {
  print_header
  git_churn "$@" | sort -n -r --key=10
  print_tail
}

#
# Sort by file name (regardless of count)
function git_file_sort() {
  print_header
  git_churn "$@" | sort --key=12
}

#
# Print the header (if toggled 'true')
function print_date_tail() {

  if [[ "$PRINT_TAIL" == "true" ]]; then
    awk 'BEGIN{ for(c=0;c<65;c++) printf "="; printf "\n"}'
    awk 'BEGIN { printf "| %10s | %7s | %7s | %-7s | %-7s | %7s |\n", "dates", "files", "lines", "growth", "shrink", "net(+/-)" }'
  fi
}

function git_churn_dates() {

  git log --numstat --date=short "$@"| grep "^[0-9\|Date:]" | awk '{

    if ( $1 == "Date:" )
    {
      commit_date = $2
    }
    else
    {
      dmods[commit_date]++;
      grow[commit_date] += $1;
      shrink[commit_date] += $2;
      fmods[commit_date] = fmods[commit_date] "," $3
      lmods[commit_date] += ($1 + $2);
      fmods[commit_date]++;
    }
  }
  END {
    for (t in dmods)
    {
      net =  grow[t] - shrink[t]
      printf("| %10s | %7s | %7s | %7s | %7s | %8s |\n", t, fmods[t], lmods[t], grow[t], shrink[t], net)
    }
  }'
}

#
# Sort file modification count ascending
function git_date_churn() {
  git_churn_dates "$@" | sort -n --key=2
  print_date_tail
}

#
# Sort by line modification count per file ascending
function git_date_files() {
  git_churn_dates "$@" | sort -n --key=4
  print_date_tail
}

#
# Sort by line modification count per file ascending
function git_date_lines() {
  git_churn_dates "$@" | sort -n --key=6
  print_date_tail
}

#
# Sort by line modification count per file ascending
function git_date_growth() {
  git_churn_dates | sort -n --key=8
  print_date_tail
}

#
# Sort by line modification count per file ascending
function git_date_shrink() {
  git_churn_dates | sort -n --key=10
  print_date_tail
}

#
# Sort by line modification count per file ascending
function git_date_net() {
  git_churn_dates | sort -n --key=12
  print_date_tail
}