# Scraper

Scrape a site and post a message to Slack to notify you if the site changed.

Great for getting notified of:
1. COVID vaccination slots available
1. Items becoming in-stock
1. Items going on sale

# Configruation environment variables

The `scrape` script is intended to be invoked via `cron`. If so, you'll also need a `.env` file that exports:

1. `SLACK_HOOK` to specify the Slack webhook endpoint
1. `DBPATH` (optional) to specify where to write the SQLite3 database file

# Raspberry Pi

See `Makefile` for list of dependencies.

The `scrape` script is intended to be invoked via `cron`.

# Homebrew

I run this on MacOS + Homebrew Ruby. My `zshrc` file does `BREW_PREFIX=$(brew --prefix)` to source Homebrew. For whatever reason, this isn't working, so I need to manually set `BREW_PREFIX` in a bootstrap script does this:

```
export BREW_PREFIX=/usr/local
source $HOME/.zshrc
```

I've also got a crontab entry that runs it every five minutes:

`*/5 * * * * $HOME/scraper/scrape`
