# dev-env

Personal dotfiles and bootstrap for macOS: Ghostty, tmux, Neovim, zsh, and Claude config.

## First-time setup

```bash
git clone --recurse-submodules https://github.com/Francisco-BT/dev-env.git
cd dev-env
./run brew          # Homebrew packages (nvim, tmux, fzf, prettierd, …)
./dev-env           # Copy configs into ~/.config, ~/.local, ~/
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
./dev-env
```

`./dev-env` runs `git submodule update --init --recursive` automatically before syncing files.

Neovim config lives in the submodule `env/.config/nvim` → [vimconfig](https://github.com/Francisco-BT/vimconfig).

## Deploy configs

```bash
./dev-env              # Apply all configs
./dev-env --dry-run    # Print actions without changing anything
```

`--dry-run` shows copies and submodule init steps prefixed with `[DRY_RUN]:` and does not write files.

## Bootstrap scripts (`./run`)

```bash
./run brew    # Install/upgrade CLI tools via Homebrew
./run libs    # Fallback: clone junegunn/fzf to ~/personal/fzf if fzf is missing
./run --dry brew   # Dry-run any script under runs/
```

### `runs/brew`

Installs tools used across the stack:

| Package | Used by |
|---------|---------|
| `ripgrep`, `fd`, `fzf` | Telescope, tmux-sessionizer, shell |
| `fnm` | Node per project |
| `jq` | Claude statusline script |
| `prettierd`, `stylua` | Neovim conform (JS/TS + Lua format) |
| `direnv` | Optional `.envrc` per repo (hook in `.zsh_profile`) |
| `tmux`, `nvim`, `ghostty` | Terminal workflow |
| `tree-sitter-cli` | Treesitter tooling |

`dockerfmt` for Dockerfiles is not in brew here — install manually when needed.

### `runs/libs`

Legacy fallback: if `fzf` is not on `PATH`, clones [fzf](https://github.com/junegunn/fzf) to `~/personal/fzf` and runs its install script. Skip this if you use `./run brew` (recommended).

## Layout

```text
env/
  .config/   → ghostty, tmux, nvim (submodule)
  .local/    → scripts (tmux-sessionizer, …)
  .claude/   → rules, statusline
  .zshrc, .zsh_profile
dev-env      → sync script
run          → runs/* installers
```
