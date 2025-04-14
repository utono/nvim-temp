#!/usr/bin/env bash

USER_DIR="$HOME/.config/nvim"
REPO_DIR="$HOME/Documents/repos/dam9000/kickstart-modular.nvim"

# Relative paths or patterns to exclude
exclude_paths=(
  ".gitignore"
  ".stylua.toml"
  "LICENSE.md"
  "README.md"
  "lazy-lock.json"
  "lua/options-tokyonight.lua"
  "after/ftplugin/lua.lua"
  "after/ftplugin/python.lua"
)

# Build grep pattern
exact_exclude_pattern=$(printf "%s\n" "${exclude_paths[@]}" | sed 's|.|\\&|g' | paste -sd '|' -)
exclude_pattern="^doc/|^\\.git/|^\\.github/|$exact_exclude_pattern"

# Filter only common files that are not in the exclude list
common_files=$(comm -12 \
  <(cd "$USER_DIR" && find . -type f | sort) \
  <(cd "$REPO_DIR" && find . -type f | sort) |
  sed 's|^\./||')

# Exclude unwanted files
for path in "${exclude_paths[@]}"; do
  common_files=$(printf "%s\n" "$common_files" | grep -vF "$path")
done

# Also exclude folders like .git, .github, and doc
common_files=$(printf "%s\n" "$common_files" | grep -Ev '^doc/|^\.git/|^\.github/')

# Temp file for Neovim commands
tmpfile=$(mktemp)
echo "set noswapfile" >> "$tmpfile"
echo "set statusline=%F" >> "$tmpfile"

# Set diff options: vertical layout, 3 lines of context, no fold column
# echo "set diffopt+=context:3,internal,algorithm:histogram,indent-heuristic" >> "$tmpfile"

first=1
for relpath in $common_files; do
  user_file="$USER_DIR/$relpath"
  repo_file="$REPO_DIR/$relpath"

  # Only diff if the files are different
  if ! cmp -s "$user_file" "$repo_file"; then
    [[ $first -eq 1 ]] && first=0 || echo "tabnew" >> "$tmpfile"

    echo "edit $user_file" >> "$tmpfile"
    echo "split $repo_file" >> "$tmpfile"
    echo "wincmd j | diffthis" >> "$tmpfile"
    echo "wincmd k | diffthis" >> "$tmpfile"
  fi
done

# Launch Neovim if any diffs exist
if [[ $first -eq 0 ]]; then
  nvim -c "source $tmpfile"
else
  echo "✅ All matching files are identical — no diffs to show."
fi

rm "$tmpfile"
