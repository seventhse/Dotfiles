fpath=(
  /opt/homebrew/share/zsh/site-functions
  $ZSH_CONFIG/completion
  $fpath
)

autoload -Uz compinit

if [[ ! -f "$HOME/.cache/zsh/zcompdump" ]]; then
  compinit
else
  compinit -C -d "$HOME/.cache/zsh/zcompdump"
fi