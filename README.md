bash-help
=========

Customization of git prompts, code commit statistics and other beneficial bash helper files.

## git-commit-churn.sh
Use to identify commit file/line churn for a specific git project. This is helpful for 
highlighting potentially fragile and coupled code within legacy projects by identifying:

1. How many times a specific file was updated
2. How many lines were modified for all of the file mods
3. Line additions
4. Line removals

The function will pass along other *git log* arguments and apply them. Thus it is possible
to search for commit stats with date ranges, authoring, etc. *Note* that it does combine 
stats for file moves and renames

###*churn examples:*
##### unsorted file, line, growth, shrink
```
[~/bash/bash-help:master(+,*)]$ git_churn
|    16 |   562 |   392 |   170 | git-simple-prompt.sh |
|     5 |   152 |   137 |    15 | git-commit-churn.sh |
|     3 |   108 |    54 |    54 | git-help.sh |
|    14 |   233 |   170 |    63 | README.md |
|     1 |   202 |   202 |     0 | LICENSE-2.0 |
|    39 |  1257 |   955 |   302 | Stat Totals |
```
##### sort by file modification count 
```
[~/bash/bash-help:master(+,*)]$ git_churn_toggle_header 
[~/bash/bash-help:master(+,*)]$ git_file_churn

|   file|   line|     growth|     shrink| filename |
====================================================
|     1 |   202 |   202 |     0 | LICENSE-2.0 |
|     3 |   108 |    54 |    54 | git-help.sh |
|     5 |   152 |   137 |    15 | git-commit-churn.sh |
|    14 |   233 |   170 |    63 | README.md |
|    16 |   562 |   392 |   170 | git-simple-prompt.sh |
|    39 |  1257 |   955 |   302 | Stat Totals |
```
##### pass other 'git log' arguments through
```
[~/bash/bash-help:master(+,*)]$ git_file_churn --after="2014-01-01"
|     3 |   108 |    54 |    54 | git-help.sh |
|     3 |    16 |     8 |     8 | git-simple-prompt.sh |
|     5 |   152 |   137 |    15 | git-commit-churn.sh |
|     8 |   180 |   123 |    57 | README.md |
|    19 |   456 |   322 |   134 | Stat Totals |
```
##### line growth by author and file type (file pattern last)
```
[~/bash/bash-help:master(+,*)]$ git_line_growth --author=dbmillett  -- *.sh
|     7 |   221 |   170 |    51 | git-commit-churn.sh |
|    16 |   562 |   392 |   170 | git-simple-prompt.sh |
|    23 |   783 |   562 |   221 | Stat Totals |
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
6. git_file_sorted
7. *git_churn_toggle_print_header (default 'false')*
8. *git_churn_toggle_print_tail (default 'true')*

#####*prompt:*
1. DEFAULT_PROMPT specifies prompt format for non git projects
2. git_prompt_toggle() enables/disables git prompt customization for current shell
3. git_prompt_toggle_suggestions() enables/disables prompt indicators for current shell
4. git_prompt_remote() set the remote target for current shell, default is 'origin'
5. git_prompt_remote_branch() set the remote branch for current shell, default is 'master'
