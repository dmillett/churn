bash-help
=========

Customization of git prompts, code commit statistics and other beneficial bash helper files.

## git-commit-churn.sh
Use to identify commit file/line churn for a specific git project. This is helpful for 
highlighting potentially fragile and coupled code within legacy projects by identifying:

1. How many times a specific file was updated
2. How many lines were modified for all of the file mods
3. Growth trend (code added)
4. Shrink trend (code removed)

The function will pass along other *git log* arguments and apply them. Thus it is possible
to search for commit stats with date ranges, authoring, etc. *Note* that it does combine 
stats for file moves and renames

###*churn examples:*
##### unsorted file, line, growth trend, shrink trend 
```
$ git_churn 
| 14 | 558 | git-simple-prompt.sh | 283 (+) | 13 (-) |
| 2 | 68 | git-commit-churn.sh | 68 (+) | 1 (-) |
| 3 | 108 | git-help.sh | 56 (+) | 1 (-) |
| 10 | 133 | README.md | 133 (+) | 6 (-) |
| 1 | 202 | LICENSE-2.0 | 60 (+) | 0 (-) |
```
##### sort by file modification count 
```
$ git_file_churn_sorted 
| 1 | 202 | LICENSE-2.0 | 60 (+) | 0 (-) |
| 2 | 68 | git-commit-churn.sh | 68 (+) | 1 (-) |
| 3 | 108 | git-help.sh | 56 (+) | 1 (-) |
| 10 | 133 | README.md | 133 (+) | 6 (-) |
| 14 | 558 | git-simple-prompt.sh | 283 (+) | 13 (-) |
```
##### pass other 'git log' arguments through
```
$ git_file_churn_sorted --after="2014-01-01"
| 1 | 12 | git-simple-prompt.sh | 12 (+) | 1 (-) |
| 2 | 68 | git-commit-churn.sh | 68 (+) | 1 (-) |
| 3 | 108 | git-help.sh | 56 (+) | 1 (-) |
| 4 | 80 | README.md | 80 (+) | 3 (-) |
```
##### line growth by author
```
$ git_line_growth_sorted --author=dbmillett
| 3 | 108 | git-help.sh | 56 (+) | 1 (-) |
| 1 | 202 | LICENSE-2.0 | 60 (+) | 0 (-) |
| 2 | 68 | git-commit-churn.sh | 68 (+) | 1 (-) |
| 10 | 133 | README.md | 133 (+) | 6 (-) |
| 14 | 558 | git-simple-prompt.sh | 283 (+) | 13 (-) |
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
1. git_churn
2. git_file_churn_sorted
3. git_line_churn_sorted
4. git_line_growth_sorted
5. git_line_shrink_sorted

#####*prompt:*
1. DEFAULT_PROMPT specifies prompt format for non git projects
2. git_prompt_toggle() enables/disables git prompt customization for current shell
3. git_prompt_toggle_suggestions() enables/disables prompt indicators for current shell
4. git_prompt_remote() set the remote target for current shell, default is 'origin'
5. git_prompt_remote_branch() set the remote branch for current shell, default is 'master'
