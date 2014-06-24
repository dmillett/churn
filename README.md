bash-help
=========

Customization of git prompts, code commit statistics and other beneficial bash helper files.

## git-help.sh
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
$ git churn
| 14 | 558 | git-simple-prompt.sh | 52 | 26 |
| 1 | 45 | git-help.sh | 46 |  |
| 6 | 53 | README.md | 5 | 17 |
| 1 | 202 | LICENSE-2.0 | 61 |  |
```
##### sort by file modification count 
```
$ git_file_churn_sorted
| 1 | 202 | LICENSE-2.0 | 61 |  |
| 1 | 45 | git-help.sh | 46 |  |
| 6 | 53 | README.md | 5 | 17 |
| 14 | 558 | git-simple-prompt.sh | 52 | 26 |
```
##### pass other 'git log' arguments through
```
$ git_file_churn_sorted --after="2014-01-01"
| 1 | 12 | git-simple-prompt.sh | 6 | 7 |
| 1 | 45 | git-help.sh | 46 |  |
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
Update your .bashrc file

1. source "$path-to-script/git-help.sh"
2. source "$path-to-script/git-simple-prompt.sh"
3. PROMPT_COMMAND=git_simple_prompt

###*usage:*
1. DEFAULT_PROMPT specifies prompt format for non git projects
2. git_prompt_toggle() enables/disables git prompt customization for current shell
3. git_prompt_toggle_suggestions() enables/disables prompt indicators for current shell
4. git_prompt_remote() set the remote target for current shell, default is 'origin'
5. git_prompt_remote_branch() set the remote branch for current shell, default is 'master'
