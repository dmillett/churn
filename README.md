churn
=====
A summary of file and line modifications, including growth/shrink, to identify code "hot spots".
Customization of git prompts, code commit statistics and other beneficial bash helper files.

# git-commit-churn.sh
Use to identify commit file/line churn for a specific git project. This is helpful for 
highlighting potentially fragile and coupled code (todo: refactor :-) by identifying:

1. What files changed the most/least?
2. When did the most/least file modifications occur?
3. What feature/bug/comment did the most/least file modification occur?
4. Line modifications
5. Line additions
6. Line removals
7. Net growth/shrink of the codebase

###*churn examples:*
The function will pass along other *git log* arguments and apply them. Thus it is possible
to search for commit stats with date ranges, authoring, file name patterns, etc. It is
possible to find dates with the largest/smallest churn in addition to what commit message
prefixes were used (ex: feature-id FOO-123 resulted in a lot of file mods).

#### sort by file modification count
```shell
[~/bash/bash-help:master(+,*)]$ git_file_churn
|    file |    line | growth  | shrink  | net(+/-) | filename/stats |
=====================================================================
|       1 |     202 |     202 |       0 |      202 | LICENSE-2.0 |
|       3 |     108 |      54 |      54 |        0 | git-help.sh |
|      12 |     291 |     215 |      76 |      139 | git-commit-churn.sh |
|      17 |     564 |     393 |     171 |      222 | git-simple-prompt.sh |
|      18 |     320 |     214 |     106 |      108 | README.md |
|      51 |    1485 |    1078 |     407 |      671 | Stat Totals |
```

#### net line growth by author and file type with file pattern(s)
```shell
[~/bash/bash-help:master()]$ git_net_growth --after=2014-01-01 --author=dbmillett -- "*.sh"
|       3 |     108 |      54 |      54 |        0 | git-help.sh |
|      12 |     291 |     215 |      76 |      139 | git-commit-churn.sh |
|      17 |     564 |     393 |     171 |      222 | git-simple-prompt.sh |
|      32 |     963 |     662 |     301 |      361 | Stat Totals |
=====================================================================
|    file |    line | growth  | shrink  | net(+/-) | filename/stats |
```

#### available functions
1. **churn by file:**
  - git_file_churn(), git_line_churn(), git_line_growth(), git_line_shrink()
    git_net_growth(), git_net_shrink(), git_file_sort()
2. **churn by date:**
  - git_date_churn(), git_file_churn_dates(), git_line_churn_dates(), git_line_growth_dates()
    git_line_shrink_dates(), git_net_growth_dates(), git_net_shrink_dates()
3. **churn by message:**
  - git_message_churn(), git_file_churn_messages, git_line_churn_messages()
    git_line_growth_messages(), git_line_shrink_messages(), git_net_growth_messages()
    git_net_shrink_messages()
4. **toggles:**
  - git_churn_toggle_header(), git_churn_toggle_footer(), git_churn_commit_message_prefix(),
    git_churn_toggle_total_stats()

**Note** that it does combine stats for file moves and renames.

##### use churn by file/date/message in conjunction with each other
Sometimes it is helpful to find out what files changed on a specific date
for a given commit message (feature-id).

```shell
# When did the file modifications occur?
[~/bash/bash-help:master()]$ git_line_churn_dates --after=2015-02-01
| 2015-03-05 |       4 |      34 |      22 |      12 |       10 |
| 2015-02-27 |       5 |      39 |      18 |      21 |       -3 |
| 2015-03-02 |       4 |      40 |      20 |      20 |        0 |
| 2015-02-26 |       2 |     111 |      56 |      55 |        1 |
| 2015-03-11 |       2 |     129 |     121 |       8 |      113 |
| 2015-03-04 |       6 |     252 |     193 |      59 |      134 |
=================================================================
|      dates |   files |   lines | growth  | shrink  | net(+/-) |

# What files were updated the most during this time?
[~/bash/bash-help:master()]$ git_line_churn --after=2015-03-01 --before=2015-03-03
|       1 |       2 |       1 |       1 |        0 | git-simple-prompt.sh |
|       2 |      18 |       9 |       9 |        0 | git-commit-churn.sh |
|       1 |      20 |      10 |      10 |        0 | README.md |
|       4 |      40 |      20 |      20 |        0 | Stat Totals |
=====================================================================
|   files |   lines | growth  | shrink  | net(+/-) | filename/stats |

# Which commit messages and/or feature id was responsible?
[~/bash/bash-help:master()]$ git_line_churn_messages --after=2015-03-01 --before=2015-03-03
|             aligning |       1 |      16 |       8 |       8 |        0 |
|               adding |       3 |      24 |      12 |      12 |        0 |
===========================================================================
|              message |   files |   lines | growth  | shrink  | net(+/-) |

# How much were files modified for that date + commit message?
[~/bash/bash-help:master()]$ git_line_churn --after=2015-03-01 --before=2015-03-03 --grep aligning
|       1 |      16 |       8 |       8 |        0 | git-commit-churn.sh |
|       1 |      16 |       8 |       8 |        0 | Stat Totals |
=====================================================================
|   files |   lines | growth  | shrink  | net(+/-) | filename/stats |
```

*Note:* This will take the characters up to the first white space for commit message.
To alter the commit message prefix use *git_churn_commit_message_prefix()*.

## churn-tools.sh
Is useful for generating R graphs that plot file/line/line-growth/line-shrink/net-lines against date, filename, and commit message for a repository. The shell plot function will generate an Rscript file (.r) and an image file (.png). The Rscript file may be updated and executed to regenerate the image file. churn-tools will also generate Confluence wiki tables (for markup insertion).

###*churn plot examples:*
Here is a list of functions to generate R plots. Please note the generated Rscript file is updateable.

1. *churn_to_csv()* - group commit stats by filename
2. *churn_messages_to_csv()* - group commit stats by commit message prefix
3. *churn_dates_to_csv()* - group commit stats by date
4. *churn_R_plot()*
  * *input/output:* **-i** (input), **-o** (output, title)
  * *group type:* **-D** (date), **-F** (file), **-M** (message)
  * *sort by:* **-S** "lines" (could use "files" or "growth" or "shrink" or "net")
  * *plot:* **-f** (files), **-l** (lines), **-g** (line growth), **-s** (line shrink), **-n** (net lines)  

```shell
# Wherever the install location may be
source ~/dev/bash/bash-help/churn-tools.sh

# Generate the csv files
churn_to_csv --after=2015-03-01 > filenames.csv
churn_messages_to_csv --after=2015-03-01 > messages.csv

# Churn by commit message, sorted by lines
churn_R_plot -i messages.csv -o messages-line-sort -M -l -n -S lines

# Where 'gthumb' is a simple image viewer
gthumb messages-line-sort.png

# Churn by filename, sorted by number of line modifications
churn_R_plot -i filenames.csv -o filenames-line-sort -F -f -l -n -g -s -S lines
gthumb filenames-line-sort.png

# Churn by filename, unsorted (label problems may exist)
churn_R_plot -i filenames.csv -o filenames -F -f -l -n -g -s
gthumb filenames.png
```

## git-simple-prompt.sh
Customizes the command prompt within a git project directory. It
allows for color choice, style, and indicators/suggestions. Toggling
is available to enable/disable local (current shell) prompt customization. 
Local remote and remote branches may also be updated from their defaults 'origin' and 'master'.
Thanks to my brother for suggesting prompt modification, it was a nice diversion.

###*prompt examples:*
#####up to date 
```
[~/bash/bash-help:master()]$
```
#####new files 
```
[~/bash/bash-help:master(+)]$
```
#####modified files 
```
[~/bash/bash-help:master(*)]$
```
#####merge/rebase with remote 
```
[~/bash/bash-help:master(↓↑)]$
```
###*installation:*
Clone and update your .bashrc file

1. source "$path-to-script/git-commit-churn.sh"
2. source "$path-to-script/git-simple-prompt.sh"
3. PROMPT_COMMAND=git_simple_prompt

###*usage:*
#####*commit-churn:*
1. **churn by file:**
  - git_file_churn(), git_line_churn(), git_line_growth(), git_line_shrink()
    git_net_growth(), git_net_shrink(), git_file_sort()
2. **churn by date:**
  - git_date_churn(), git_file_churn_dates(), git_line_churn_dates(), git_line_growth_dates()
    git_line_shrink_dates(), git_net_growth_dates(), git_net_shrink_dates()
3. **churn by message:**
  - git_message_churn(), git_file_churn_messages, git_line_churn_messages()
    git_line_growth_messages(), git_line_shrink_messages(), git_net_growth_messages()
    git_net_shrink_messages()
4. **toggles:**
  - git_churn_toggle_header(), git_churn_toggle_footer(), git_churn_commit_message_prefix(),
    git_churn_toggle_total_stats()

#####*prompt:*
1. DEFAULT_PROMPT specifies prompt format for non git projects
2. git_prompt_toggle() enables/disables git prompt customization for current shell
3. git_prompt_toggle_suggestions() enables/disables prompt indicators for current shell
4. git_prompt_remote() set the remote target for current shell, default is 'origin'
5. git_prompt_remote_branch() set the remote branch for current shell, default is 'master'
