#!/usr/bin/env bash

source "git-commit-churn.sh"

#
# For all of those Confluence wiki users out there, you can
# create a wiki table from these statistics to paste as 'markup insert'
function churn_to_confluence_table() {

  git_churn_toggle_footer
  git_churn_toggle_header
  echo "{table-plus}"
  print_header "true" | sed 's/|/||/g' | sed '/=/d'
  git_churn "$@"
  echo "{table-plus}"
}

function churn_dates_to_confluence_table() {

  git_churn_toggle_footer
  git_churn_toggle_header
  echo "{table-plus}"
  print_date_header "true" | sed 's/|/||/g' | sed '/=/d'
  git_churn "$@"
  echo "{table-plus}"
}

function churn_messages_to_confluence_table() {

  git_churn_toggle_footer
  git_churn_toggle_header
  echo "{table-plus}"
  print_commit_msg_header "true" | sed 's/|/||/g' | sed '/=/d'
  git_churn "$@"
  echo "{table-plus}"
}

#
# Use for R or other plotting framework
function churn_to_csv() {

  git_churn_toggle_footer
  git_churn_toggle_header
  print_header "true" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/' | sed '/=/d'
  git_churn "$@" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/'
}

function churn_dates_to_csv() {

  git_churn_toggle_footer
  git_churn_toggle_header
  print_date_header "true" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/' | sed '/=/d'
  git_churn_dates "$@" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/'
}

function churn_messages_to_csv() {

  git_churn_toggle_footer
  git_churn_toggle_header
  print_commit_msg_header "true" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/' | sed '/=/d'
  git_message_churn "$@" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/'
}

function churn_R_pie_graph_for() {

  OPTIND=1
  ds="lines"
  while getopts "d:flgsn" options; do
    case $options in
      d)
        input="$OPTARG";
        ;;
      f)
        ds="files";
        ;;
      l)
        ds="lines";
        ;;
      g)
        ds="growth";
        ;;
      s)
        ds="shrink";
        ;;
      n)
        ds="net";
        ;;
      *)
        echo "Try '-d data.csv' with flags -f (files), -l (lines)"
        ;;
    esac
  done

  csvfile="$input"
  rfile="$(pwd)/pie_line_dates.r"
  echo "#!/usr/bin/Rscript  --vanilla --default-packages=utils" > $rfile
  echo "data <- read.csv(\"$csvfile\")" >> $rfile
  echo "data_source <- data\$$ds" >> $rfile
  echo "dates_data <- data\$dates" >> $rfile
  echo "pie(data_source, main=\"$ds mods by date\", col=rainbow(length(data_source)), label=dates_data)" >> $rfile

  chmod 755 $rfile
  Rscript $rfile
}

# xrange <- range(dates_data)
# yrange <- range(lines_data)
# colors <- rainbow(length(dates_data))
