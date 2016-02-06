#!/usr/bin/env bash

PRINT_HEADER="false"
PRINT_FOOTER="true"
PRINT_TOTAL_STATS="true"

#
# Toggle printing the header (off by default)
function git_churn_toggle_header() {

  if [[ "$PRINT_HEADER" == "true" ]]; then
    export PRINT_HEADER="false"
  else
    export PRINT_HEADER="true"
  fi
}

function git_churn_toggle_footer() {

  if [[ "$PRINT_FOOTER" == "true" || "$1" == "true" ]]; then
    export PRINT_FOOTER="false"
  else
    export PRINT_FOOTER="true"
  fi
}

function git_churn_toggle_total_stats() {

  if [[ "$PRINT_TOTAL_STATS" == "true" ]]; then
    export PRINT_TOTAL_STATS="false"
  else
    export PRINT_TOTAL_STATS="true"
  fi
}

#
# Print the header (if toggled 'true')
function __print_header() {

  if [[ "$PRINT_HEADER" == "true" || "$1" == "true" ]]; then
    awk 'BEGIN { printf "| %7s | %7s | %-7s | %-7s | %7s | filename/stats |\n", "files", "lines", "growth", "shrink", "net(+/-)" }'
    awk 'BEGIN{ for(c=0;c<69;c++) printf "="; printf "\n"}'
  fi
}

#
# Print the header (if toggled 'true')
function __print_footer() {

  if [[ "$PRINT_FOOTER" == "true" || "$1" == "true" ]]; then
    awk 'BEGIN { for(c=0;c<69;c++) printf "="; printf "\n"}'
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

  git log --numstat "$@"| grep "^[0-9]" | awk -v stats="$PRINT_TOTAL_STATS" '{

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

    if (stats == "true")
    {
      totals = growth - shrink
      printf("| %7s | %7s | %7s | %7s | %8s | Stat Totals |\n", ftotal, ltotal, growth, shrink, totals)
    }
  }'
}

#
# Sort file modification count ascending
function git_file_churn() {
  __print_header
  git_churn "$@" | sort -n --key=2
  __print_footer
}

#
# Sort by line modification count per file ascending
function git_line_churn() {
  __print_header
  git_churn "$@" | sort -n --key=4
  __print_footer
}

#
# Sort by line growth trend/count per file ascending
function git_line_growth() {
  __print_header
  git_churn "$@" | sort -n --key=6
  __print_footer
}

#
# Sort by line shrink trend/count per file ascending
function git_line_shrink() {
  __print_header
  git_churn "$@" | sort -n --key=8
  __print_footer
}

#
# Sort by net growth
function git_net_growth() {
  __print_header
  git_churn "$@" | sort -n --key=10
  __print_footer
}

#
# Sort by net shrink
function git_net_shrink() {
  __print_header
  git_churn "$@" | sort -nr --key=10
  __print_footer
}

#
# Sort by file name (regardless of count)
function git_file_sort() {
  __print_header
  git_churn "$@" | sort --key=12
}

#
# Print the footer (if toggled 'true')
function __print_date_header() {

  if [[ "$PRINT_HEADER" == "true" || "$1" == "true" ]]; then
    awk 'BEGIN { printf "| %10s | %7s | %7s | %-7s | %-7s | %7s |\n", "dates", "files", "lines", "growth", "shrink", "net(+/-)" }'
    awk 'BEGIN{ for(c=0;c<65;c++) printf "="; printf "\n"}'
  fi
}

#
# Print the footer (if toggled 'true')
function __print_date_footer() {

  if [[ "$PRINT_FOOTER" == "true" ]]; then
    awk 'BEGIN{ for(c=0;c<65;c++) printf "="; printf "\n"}'
    awk 'BEGIN { printf "| %10s | %7s | %7s | %-7s | %-7s | %7s |\n", "dates", "files", "lines", "growth", "shrink", "net(+/-)" }'
  fi
}

function git_churn_dates() {

  git log --numstat --date=short "$@"| grep "^[0-9\|Date:]" | awk -v stats="$PRINT_TOTAL_STATS" '{

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
      ftotal++;
      ltotal += ($1 + $2);
      tgrowth += $1;
      tshrink += $2;
    }
  }
  END {
    for (t in dmods)
    {
      net =  grow[t] - shrink[t]
      printf("| %10s | %7s | %7s | %7s | %7s | %8s |\n", t, fmods[t], lmods[t], grow[t], shrink[t], net)
    }

    if (stats == "true")
    {
      totals = tgrowth - tshrink
      #printf("| Stat Totals | %7s | %7s | %7s | %7s | %8s |\n", ftotal, ltotal, tgrowth, tshrink, totals)
    }
  }'
}

#
# Sort file modification count ascending
function git_date_churn() {
__print_date_header
  git_churn_dates "$@" | sort -n --key=2
  __print_date_footer
}

#
# Sort by line modification count per file ascending
function git_file_churn_dates() {
  __print_date_header
  git_churn_dates "$@" | sort -n --key=4
  __print_date_footer
}

#
# Sort by line modification count per file ascending
function git_line_churn_dates() {
  __print_date_header
  git_churn_dates "$@" | sort -n --key=6
  __print_date_footer
}

#
# Sort by line modification count per file ascending
function git_line_growth_dates() {
  __print_date_header
  git_churn_dates "$@" | sort -n --key=8
  __print_date_footer
}

#
# Sort by line modification count per file ascending
function git_line_shrink_dates() {
  __print_date_header
  git_churn_dates "$@" | sort -n --key=10
  __print_date_footer
}

#
# Sort by line modification count per file ascending
function git_net_growth_dates() {
  __print_date_header
  git_churn_dates "$@" | sort -n --key=12
  __print_date_footer
}

#
# Sort by net shrink
function git_net_shrink_dates() {
  __print_date_header
  git_churn_dates "$@" | sort -nr --key=12
  __print_date_footer
}

COMMIT_MSG_PREFIX=""
#
# Complimentary with grep=, since this only looks at the first "word"
function git_churn_commit_message_prefix() {
  export COMMIT_MSG_PREFIX="$1"
}

#
# Will pick up all the text until the first white space
function git_churn_messages() {

  git log --numstat "$@" | grep "^[^Author:\|Date:\|commit\|Merge]" | \
    awk -v stats="$PRINT_TOTAL_STATS" -v prefix="$COMMIT_MSG_PREFIX" '{

    if ($1 ~ /[^0-9\|\s]+/)
    {
      if (length(commit_msg) == 0 || nmbr == "true")
      {
        commit_msg = $1
        nmbr = "false";
      }
    }
    else if ($1 ~ /^[0-9]/)
    {
      nmbr = "true"
      if (commit_msg != "" && commit_msg ~ prefix)
      {
        dmods[commit_msg]++;
        grow[commit_msg] += $1;
        shrink[commit_msg] += $2;
        fmods[commit_msg] = fmods[commit_msg] "," $3
        lmods[commit_msg] += ($1 + $2);
        fmods[commit_msg]++;
        ftotal++;
        ltotal += ($1 + $2);
        tgrowth += $1;
        tshrink += $2;
      }
    }
  }
  END {
    for (t in dmods)
    {
      net =  grow[t] - shrink[t]
      printf("| %20s | %7s | %7s | %7s | %7s | %8s |\n", t, fmods[t], lmods[t], grow[t], shrink[t], net)
    };

    if (stats == "true")
    {
      totals = tgrowth - tshrink
      #printf("|          Stat Totals | %7s | %7s | %7s | %7s | %8s |\n", ftotal, ltotal, tgrowth, tshrink, totals)
    }
  }'
}

#
# Print the header (if toggled 'true')
function __print_commit_msg_header() {

  if [[ "$PRINT_HEADER" == "true" || "$1" == "true" ]]; then
    awk 'BEGIN { printf "| %20s | %7s | %7s | %-7s | %-7s | %7s |\n", "message", "files", "lines", "growth", "shrink", "net(+/-)" }'
    awk 'BEGIN{ for(c=0;c<75;c++) printf "="; printf "\n"}'
  fi
}

#
# Print the footer (if toggled 'true')
function __print_commit_msg_footer() {

  if [[ "$PRINT_FOOTER" == "true" ]]; then
    awk 'BEGIN{ for(c=0;c<75;c++) printf "="; printf "\n"}'
    awk 'BEGIN { printf "| %20s | %7s | %7s | %-7s | %-7s | %7s |\n", "message", "files", "lines", "growth", "shrink", "net(+/-)" }'
  fi
}

function git_message_churn() {
  __print_commit_msg_header
  git_churn_messages "$@" | sort -n --key=2
  __print_commit_msg_footer
}

function git_file_churn_messages() {
  __print_commit_msg_header
  git_churn_messages "$@" | sort -n --key=4
  __print_commit_msg_footer
}

function git_line_churn_messages() {
  __print_commit_msg_header
  git_churn_messages "$@" | sort -n --key=6
  __print_commit_msg_footer
}

function git_line_growth_messages() {
  __print_commit_msg_header
  git_churn_messages "$@" | sort -n --key=8
  __print_commit_msg_footer
}

function git_line_shrink_messages() {
  __print_commit_msg_header
  git_churn_messages "$@" | sort -n --key=10
  __print_commit_msg_footer
}

function git_net_growth_messages() {
  __print_commit_msg_header
  git_churn_messages "$@" | sort -n --key=12
  __print_commit_msg_footer
}

function git_net_shrink_messages() {
  __print_commit_msg_header
  git_churn_messages "$@" | sort -nr --key=12
  __print_commit_msg_footer
}
