ZSH_PLUGINS="$ZSH_CONFIG/plugins"

for plugin in "$ZSH_PLUGINS"/*; do
  [ -d "$plugin" ] || continue

  # autosuggestions
  [ -f "$plugin/zsh-autosuggestions" ] && \
    source "$plugin/zsh-autosuggestions/zsh-autosuggestions.zsh"

  # syntax highlighting
  [ -f "$plugin/zsh-syntax-highlighting" ] && \
    source "$plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  # fallback
  [ -f "$plugin/init.zsh" ] && source "$plugin/init.zsh"
done