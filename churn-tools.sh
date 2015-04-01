#!/usr/bin/env bash

source "$(pwd)/git-commit-churn.sh"

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
  git_churn_dates "$@"
  echo "{table-plus}"
  __toggle
}

function churn_messages_to_confluence_table() {
  __toggle
  echo "{table-plus}"
  print_commit_msg_header "true" | sed 's/|/||/g' | sed '/=/d'
  git_churn_messages "$@"
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
  echo "#!/usr/bin/Rscript  --vanilla" > $rfile
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
#> legend(min(ad$lines), max(ad$lines), c("files", "lines", "growth", "shrink", "net"), cex=0.8, col=c("black", "blue", "green", "red", "orange"), pch=21:22, lty=1:2);

function churn_R_plot() {

  OPTIND=1
  default=""

  while getopts "i:o:DMFflgsnS:" options; do
    case $options in
      D)
        X="dates";
        ;;
      M)
        X="message";
        ;;
      F)
        X="filename";
        ;;
      i)
        INPUT="$OPTARG";
        ;;
      o)
        OUTPUT="$OPTARG"
        ;;
      f)
        files="files";
        if [ -z "$default" ]; then
          default="files"
        fi
        ;;
      l)
        lines="lines";
        if [ -z "$default" ]; then
          default="lines"
        fi
        ;;
      g)
        growth="growth";
        if [ -z "$default" ]; then
          default="growth"
        fi
        ;;
      s)
        shrink="shrink";
        if [ -z "$default" ]; then
          default="shrink"
        fi
        ;;
      n)
        net="net";
        if [ -z "$default" ]; then
          default="net"
        fi
        ;;
      S)
        sc="$OPTARG";
        ;;
      *)
        echo "Try \"-i '<some_file>.csv' -o '<output_file>' with one X-axis flag:"
        echo "-D (dates) -F (filename) -M (message)"
        echo "and sort flag(s):"
        echo "  -f (files), -l (lines) -g (growth) -s (shrink) -n (net)"
        return 1;
        ;;
    esac
  done

  if [[ -z "$INPUT" || -z "$X" ]]; then
    echo "Please Specify input (-i) and x-axis (-D or -F or -M)"
    return 1;
  fi

  rfile="$(pwd)/$OUTPUT.r"
  echo "#!/usr/bin/Rscript --vanilla" > $rfile
  echo "d <- read.csv(\"$INPUT\")" >> $rfile
  echo "ds <- d" >> $rfile

  if [ ! -z "$sc" ]; then
    echo "ds <- d[order(-d\$$sc),]" >> $rfile
  fi

  echo "w <- max(19 * length(ds\$$default), 600)" >> $rfile
  echo "h <- 0.70 * w[1]" >> $rfile
  echo "cx <- max(length(ds\$$default) / 50, 1)" >> $rfile
  echo "png(filename=\"$OUTPUT.png\", width=w[1], height=h[1], bg='dark grey')" >> $rfile

  echo "om <- par(mar = c(10,5,2,2) + 0.1)" >> $rfile
  echo "plot(ds\$$default, type='l', ylim=c(min(ds\$net), max(ds\$lines)), lwd=2, xaxt='n',"\
       "ylab = NA, xlab = NA, main=\"$OUTPUT\", cex.main=cx[1] + 1)" >> $rfile

  echo "grid()" >> $rfile
  echo "mtext(side = 2, 'Modification Count', line = 2, cex=cx[1] + .3)" >> $rfile
  echo "axis(1, at=1:length(ds\$$X), labels=ds\$$X, las=2)" >> $rfile

  echo "colors <- c('black')" >> $rfile
  echo "options <- c(\"$default\")" >> $rfile

  if [[ $files == "files" && $default != "files" ]]; then
    echo "lines(ds\$files, col='brown', type='l', lwd=2)" >> $rfile
    echo "options <- c(options, 'files')" >> $rfile
    echo "colors <- c(colors, 'brown')" >> $rfile
  fi

  if [[ $lines == "lines" && $default != "lines" ]]; then
    echo "lines(ds\$lines, col='blue', type='l', lwd=2)" >> $rfile
    echo "options <- c(options, 'lines')" >> $rfile
    echo "colors <- c(colors, 'blue')" >> $rfile
  fi

  if [[ $growth == "growth" && $default != "growth" ]]; then
    echo "lines(ds\$growth, col='green', type='l', lwd=2)" >> $rfile
    echo "options <- c(options, 'growth')" >> $rfile
    echo "colors <- c(colors, 'green')" >> $rfile
  fi

  if [[ $shrink == "shrink" && $default != "shrink" ]]; then
    echo "lines(ds\$shrink, col='red', type='l', lwd=2)" >> $rfile
    echo "options <- c(options, 'shrink')" >> $rfile
    echo "colors <- c(colors, 'red')" >> $rfile
  fi

  if [[ $net == "net" && $default != "net" ]]; then
    echo "lines(ds\$net, col='purple', type='l', lwd=2)" >> $rfile
   echo "options <- c(options, 'net (+/-)')" >> $rfile
    echo "colors <- c(colors, 'purple')" >> $rfile
  fi

  echo "legend('topright', inset=0.05, title='Mod Type', c(options), fill=c(colors), cex=cx[1])" >> $rfile
  echo "dev.off()" >> $rfile

  # Defaults to 'pdf' output, it should be 'png'
  chmod 755 $rfile
  Rscript $rfile > /dev/null 2>&1
  if [ -f "Rplots.pdf" ]; then
    rm "Rplots.pdf"
  fi
}

