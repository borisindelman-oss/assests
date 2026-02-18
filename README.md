# Setting up vault sync
1. Create vault repo in github
2. clone to mac + linux
3. MAC - install obsidian, open vault folder, install git community plugin, set it up for pull every minute
4. LINUX - set up auto sync (uses crontab)
```sh
chmod +x /path/to/repo/git_sync/*.sh
/path/to/repo/git_sync/git-sync-cron-setup.sh /path/to/vault
```


# Codex setup

Link customization files
```sh
ln -s ~/git/assests/codex/AGENTS.md ~/.codex/AGENTS.md
ln -s ~/git/assests/codex/config.toml ~/.codex/config.toml
ln -s ~/git/assests/codex/skills ~/.codex/skills
ln -s ~/git/assests/codex/prompts ~/.codex/prompts
```

Add tokens for MCPs to .zshrc or .bashrc

1. Github
```sh
export GITHUB_PERSONAL_ACCESS_TOKEN=''   # github -> settings -> developer settings -> Personal access tokens (classic) -> Configure SSO
```

2. W&B
```sh
export WANDB_API_KEY=''    # https://wandb.ai/authorize
export WANDB_ENTITY=wayve-ai
```

3. Notion
```sh
bazel run //tools:codex mcp login notion
```

# 4. Databricks

Add the following to your `.zshrc` or `.bashrc`:
```sh
export DATABRICKS_API_TOKEN=''   # Databricks user settings > Generate new token
```

# 5. Buildkite

Add the following to your `.zshrc` or `.bashrc`:
```sh
export BUILDKITE_TOKEN=''   # Buildkite > User Settings > API Access Tokens
```

# 6. Datadog

Add the following to your `.zshrc` or `.bashrc`:
```sh
export DATADOG_APP_KEY=''   # Datadog > Organization Settings > Application Keys
```


