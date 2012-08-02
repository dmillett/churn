bash-help
=========

Customization of git prompts and other beneficial bash helper files.

## git_simple_prompt.sh
Customizes the command prompt within a git project directory. It
allows for color choice, style, and indicators/suggestions. Toggling
is available to enable/disable local (current shell) prompt customization.

####*installation*
Update your .bashrc file
1. source "$path-to-script/git-simple-prompt.sh"
2. PROMPT_COMMAND=git_simple_prompt

####*usage*
1. DEFAULT_PROMPT specifies prompt format for non git projects
2. git_toggle_prompt() enables/disables git prompt customization for current shell
3. git_toggle_prompt_suggestions() enables/disables prompt indicators for current shell
