# Scraper

Scrape a site and post a message to Slack to notify you if the site changed.

Great for getting notified of:
1. COVID vaccination slots available
1. Items becoming in-stock
1. Items going on sale

# MacOS

I run this on MacOS + Homebrew Ruby. My `zshrc` file does `BREW_PREFIX=$(brew --prefix)` to source Homebrew. For whatever reason, this isn't working, so I need to manually set `BREW_PREFIX` in a bootstrap script that looks something like this:

```
#!/usr/local/bin/zsh

export SLACK_HOOK=https://hooks.slack.com/services/ABC/DEF/TlTrTDfaFKPUdBmM

export BREW_PREFIX=/usr/local
source $HOME/.zshrc

ruby $(dirname $0)/scrape.rb
```

I've also got a crontab entry that runs it every five minutes:

`*/5 * * * * $HOME/scraper/scrape >> $HOME/scraper/scrape.log 2>&1`

# Raspberry Pi

Dependencies:

```
> sudo apt-get install ruby
> sudo apt-get install ruby-dev
> sudo apt-get install libsqlite3-dev
> sudo gem install faraday
> sudo gem install nokogiri
> sudo gem install sqlite3
```

You can also set `DBPATH` to move where the sqlite3 db file is stored (e.g. if you want to offload it from your SD card).
