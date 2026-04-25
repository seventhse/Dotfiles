for f in $ZSH_CONFIG/functions/*; do
  [ -f "$f" ] && source "$f"
done