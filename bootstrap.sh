#!/usr/bin/env bash
# Idempotent, stateless. Re-run any time. Assumes Homebrew is already installed (user step, no curl|sh here).
set -euo pipefail
cd "$(dirname "$0")"
command -v brew >/dev/null || { echo "install Homebrew first: https://brew.sh"; exit 1; }
brew bundle --file=Brewfile
git config core.hooksPath .githooks            # tracked pre-commit hook: gitleaks + no-employer-strings check
stow --no-folding -t "$HOME" zsh git tmux mise k9s herdr ohmyposh claude kiro
command -v mise >/dev/null && mise install
if command -v go >/dev/null && [ -f go-tools.txt ]; then xargs -I{} go install {}@latest < go-tools.txt; fi
echo "done — open a new shell"
