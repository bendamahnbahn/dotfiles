# ~/.profile: executed by the command interpreter for login shells.
# Also sourced by ~/.zshrc so interactive zsh gets the same environment.
# Managed by GNU Stow from ~/dev/dotfiles (public). Employer-/machine-specific
# settings live in ~/.profile.d/*.sh and are sourced at the bottom.

# if running bash
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# user's private bin
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Homebrew: whichever prefix exists (Linuxbrew today, /opt/homebrew if a Mac ever shows up)
for b in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew; do
    [ -x "$b" ] && eval "$("$b" shellenv)" && break
done

command -v direnv     >/dev/null && eval "$(direnv hook zsh)"
command -v mise       >/dev/null && eval "$(mise activate zsh)"
command -v oh-my-posh >/dev/null && eval "$(oh-my-posh init zsh --config "$HOME/.config/oh-my-posh/theme.omp.json")"

# Go: GOPATH stays ~/go so ~/go/bin survives Go version bumps
export PATH="$HOME/go/bin:$PATH"
# go.dev tarball install — remove this line once mise owns go (otherwise apt's Go 1.18 wins)
[ -d /usr/local/go/bin ] && export PATH="$PATH:/usr/local/go/bin"

alias opencodeconfig="vim ~/.config/opencode/opencode.jsonc"

# employer-/machine-specific: everything in ~/.profile.d is sourced, tracked or not
for f in "$HOME"/.profile.d/*.sh; do
    [ -r "$f" ] && . "$f"
done
