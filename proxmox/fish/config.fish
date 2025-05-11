if status is-interactive
    # Commands to run in interactive sessions can go here
    oh-my-posh init fish --config ~/.cache/oh-my-posh/themes/tiwahu.omp.json | source
end

# Aliases
alias ls lsd
alias ll "lsd -alhtr"
alias vi vim
alias bat batcat
alias top btop
alias df dysk

# Environment Variables
set EDITOR vim
set -Ux FZF_DEFAULT_COMMAND 'find . -type f -print' # Modify fzf to seach for all files
set -x COLORTERM 24bit # set extended color support for terminal using given var

# Remove Welcome Message
set fish_greeting

# Show neofetch on Terminal Startup (only if the user has started a session and not processes like ftp or ssh)
if status --is-interactive
    neofetch
end

# Set batcat as the man pager
set -x MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | batcat -p -lman'"

# Zoxide
zoxide init fish | source
