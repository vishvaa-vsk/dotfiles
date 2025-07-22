# Basic zsh configuration
setopt AUTO_CD
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Oh-My-Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

# Disable oh-my-zsh theme (we're using starship)
ZSH_THEME=""

# Oh-My-Zsh plugins
plugins=(
    git
    docker
    docker-compose
    node
    npm
    python
    pip
    colored-man-pages
    command-not-found
    copypath
    copyfile
    dirhistory
    history
    jsontools
    sudo
    zsh-autosuggestions
    zsh-completions
    fast-syntax-highlighting
)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# Autosuggestion settings
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Initialize starship prompt (this overrides oh-my-zsh prompt)
eval "$(starship init zsh)"

# Custom aliases
alias ll='eza -la --icons'
alias la='eza -A --icons'
alias ls='eza --icons'
alias g='git'
alias gp='git pull'
alias gc='git commit'
alias gpp='git push'
alias gst='git status'

# Environment variables
export GPG_TTY=$(tty)

# Additional oh-my-zsh provided aliases will be available
# You can see them with: alias | grep git

# Prompt Engineering Starship
PROMPT_NEEDS_NEWLINE=false

precmd() {
  if [[ "$PROMPT_NEEDS_NEWLINE" == true ]]; then
    echo
  fi
  PROMPT_NEEDS_NEWLINE=true
}

clear() {
  PROMPT_NEEDS_NEWLINE=false
  command clear
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export GPG_TTY=$(tty)
export GPG_AGENT_INFO=""
export GPG_TTY=$(tty)
