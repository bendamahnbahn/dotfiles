# dotfiles

Personal shell + tooling config, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a Stow *package* mirroring `$HOME`; `bootstrap.sh` symlinks them in.

| package | contents |
|---|---|
| `zsh/` | `.zshenv`, `.zshrc`, `.profile` (brew, direnv, mise, oh-my-posh, PATH; sources `~/.profile.d/*.sh`) |
| `git/` | `.gitconfig` (identity via `includeIf`), global ignore |
| `tmux/` `mise/` `k9s/` `herdr/` `ohmyposh/` | tool configs |
| `claude/` `kiro/` | generic agent definitions / prompts / status line |
| `Brewfile` | system tools (`brew bundle`) |
| `go-tools.txt` | `go install` list |

## Fresh machine
```sh
# 1. install Homebrew (https://brew.sh), then:
git clone <this repo> ~/dev/dotfiles && cd ~/dev/dotfiles && ./bootstrap.sh
```
Re-running is safe. Stow refuses to overwrite existing files — move them aside first.

## Publishing / first push
Create an empty public repo on GitHub (no README/.gitignore — this repo has them), then:
```sh
gitleaks detect --source . --no-git            # must be clean
git remote add origin git@github.com:<you>/dotfiles.git
git push -u origin main
```
Employer-specific config is *not* in this repo by design — it lives in a separate private repo that stows
into the same `$HOME` (see the `~/.profile.d` loop in `zsh/.profile`).

## Design
- **No templating, no state.** `ls -l ~` shows what's managed. Two OS-specific lines (brew prefix) are a shell loop.
- **Machine/employer-specific config** goes in `~/.profile.d/*.sh` — tracked in another repo or not at all.
  `.gitconfig` uses `includeIf` for identities, pointing at files that may live elsewhere.
- **Always `--no-folding`** so shared directories (`~/.config`, `~/.claude`) stay real directories.
- Secrets are never committed. `gitleaks detect` before every commit.

## Maintaining

**Mental model.** Each package dir mirrors `$HOME`; `stow` symlinks its contents into `~`. No state, no
apply step: `ls -la ~` *is* the state. Symlink into this repo → managed. Regular file → not.

**Edit a managed file:** just edit it (`vim ~/.profile` edits the repo file through the link), then
`git commit` here. Employer-specific lines go in `~/.profile.d/*.sh` (separate private repo) instead.

**Start managing a new file** (example `~/.config/lazygit/config.yml`):
```sh
mkdir -p lazygit/.config/lazygit
mv ~/.config/lazygit/config.yml lazygit/.config/lazygit/
stow --no-folding -t ~ lazygit
# add `lazygit` to the stow line in bootstrap.sh; gitleaks detect --source . --no-git; git add; commit
```

**Add a tool:** `Brewfile` (`brew "foo"` → `brew bundle`), `mise/.config/mise/config.toml` (→ `mise install`),
or `go-tools.txt`. Prefer adding one line by hand over `brew bundle dump` — the dump also emits cask/go/winget/npm noise.

**Stop managing a file:** `stow -D -t ~ <pkg>` removes the links (repo file stays); copy it back to `~` if wanted; `git rm`.
`stow -D` on every package + `cp -a ~/.dotfiles-backup-<date>/. ~/` is the full undo.

**After `git pull`:** contents-only changes need nothing. New files in a package → `stow --no-folding -R -t ~ <pkg>`.
Re-running `./bootstrap.sh` is always safe.

**Gotchas**
1. *"cannot stow … over existing target"* — an installer wrote a real file where a link belongs. Diff, keep what you
   want in the repo, `mv` the real file away, restow.
2. *A link turned back into a file* — some apps save via write-temp-then-rename. `ls -la` shows no `->`; `mv` it back
   into the package and restow. If a tool does it repeatedly, bootstrap should copy that file instead of stowing.
3. *Always `--no-folding`* — otherwise a not-yet-existing `~/.config/foo` becomes a link to the repo *directory* and
   every file the app writes lands in git.
4. *Machine-local / experimental / secret* → `~/.profile.d/99-local.sh`. Sourced automatically, tracked by nobody.

**Pre-commit hook (tracked, `.githooks/pre-commit`).** Runs `gitleaks` on staged changes and rejects any
employer-specific strings — this repo is public. `bootstrap.sh` activates it with `git config core.hooksPath .githooks`;
on a clone where you haven't run bootstrap, run that line once. Bypass is `git commit --no-verify` — don't.

**Health check**
```sh
stow --no-folding -n -v -R -t ~ zsh git tmux mise k9s herdr ohmyposh claude kiro   # should report nothing to do
find ~ -maxdepth 1 -type l -xtype l                                                 # broken links → none
git status --short
```
