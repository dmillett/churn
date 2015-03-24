#!/usr/bin/env bash

source "git-commit-churn.sh"

function __toggle() {
  git_churn_toggle_header
  git_churn_toggle_footer
}

function __toggle_all() {
  git_churn_toggle_header
  git_churn_toggle_footer
  git_churn_toggle_total_stats
}

#
# For all of those Confluence wiki users out there, you can
# create a wiki table from these statistics to paste as 'markup insert'
function churn_to_confluence_table() {
  __toggle
  echo "{table-plus}"
  print_header "true" | sed 's/|/||/g' | sed '/=/d'
  git_churn "$@"
  echo "{table-plus}"
  __toggle
}

function churn_dates_to_confluence_table() {
__toggle
  echo "{table-plus}"
  print_date_header "true" | sed 's/|/||/g' | sed '/=/d'
  git_churn "$@"
  echo "{table-plus}"
  __toggle
}

function churn_messages_to_confluence_table() {
  __toggle
  echo "{table-plus}"
  print_commit_msg_header "true" | sed 's/|/||/g' | sed '/=/d'
  git_churn "$@"
  echo "{table-plus}"
  __toggle
}

#
# Use for R or other plotting framework
function churn_to_csv() {
  __toggle_all
  print_header "true" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/' | sed '/=/d'
  git_churn "$@" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/'
  __toggle_all
}

function churn_dates_to_csv() {
  __toggle_all
  print_date_header "true" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/' | sed '/=/d'
  git_churn_dates "$@" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/'
  __toggle_all
}

function churn_messages_to_csv() {
  __toggle_all
  print_commit_msg_header "true" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/' | sed '/=/d'
  git_message_churn "$@" | sed 's/|/,/g' | sed 's/^.\(.*\).$/\1/'
  __toggle_all
}

function churn_R_pie_graph_for() {

  OPTIND=1
  ds="lines"
  output="churn-pie"

  while getopts "d:flgsno:" options; do
    case $options in
      d)
        data="$OPTARG";
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
      o)
        output="$OPTARG"
        ;;
      *)
        echo "Try '-d data.csv' with flags -f (files), -l (lines)"
        ;;
    esac
  done

  csvfile="$data"
  rfile="$(pwd)/$output.r"
  echo "#!/usr/bin/Rscript  --vanilla --default-packages=utils" > $rfile
  echo "data <- read.csv(\"$csvfile\")" >> $rfile
  echo "data_source <- data\$$ds" >> $rfile
  echo "dates_data <- data\$dates" >> $rfile
  echo "pie(data_source, main=\"$ds mods by date\", col=rainbow(length(data_source)), label=dates_data)" >> $rfile

  # Defaults to 'pdf' output, it should be 'png'
  chmod 755 $rfile
  Rscript $rfile
}

# Notes:
# label orientation: "las=" 0 - parallel, 1 - horizontal, 2 - perpendicular, 3 - vertical

# xrange <- range(dates_data)
# yrange <- range(lines_data)
# colors <- rainbow(length(dates_data))
#
# actually plots lines
#> plot(ad$files, type="b", ylim=c(min(ad$shrink),max(ad$lines)), lwd=2, xaxt="n",col="black",ylab="# mod",xlab="")
#> axis(1,at=1:length(ad$dates),labels=ad$dates, las=2)
#> lines(ad$lines, col="blue", type="b", lwd=2)
#> lines(ad$growth, col="green", type="b", lwd=2)
#> lines(ad$shrink, col="red", type="b", lwd=2)
#> lines(ad$net, col="orange", type="b", lwd=2)
#> legend(min(ad$lines), max(ad$lines), c("files", "lines", "growth", "shrink", "net"), cex=0.8, col=c("black", "blue", "green", "red", "orange"), pch=21:22, lty=1:2);

#
# Where file mod count meets net growth/shrink == config files or coupled code
function churn_plot_files_and_net() {

  input="$1"
  rfile="$(pwd)/fileplots.r"
  echo "#!/usr/bin/Rscript  --vanilla --default-packages=utils" > $rfile
  echo "d <- read.csv(\"$input\")" >> $rfile
  echo "om <- par(mar = c(10,4,5,2) + 0.1)" >> $rfile
  echo "plot(d\$files,type=\"l\",ylim=c(min(d\$shrink),max(d\$lines)),lwd=2,xaxt=\"n\",col=\"black\",ylab=\"# mods\",xlab=\"\")" >> $rfile
  echo "axis(1,at=1:length(d\$filename),labels=d\$filename,las=2)" >> $rfile
  echo "par(om)" >> $rfile
  echo "lines(d\$net, col=\"orange\", type=\"l\", lwd=2)" >> $rfile

  # Defaults to 'pdf' output, it should be 'png'
  chmod 755 $rfile
  Rscript $rfile
}

