mkfile := $(abspath $(lastword $(MAKEFILE_LIST)))
cwd := $(shell dirname $(mkfile))

pi.deps:
	apt-get install ruby ruby-dev libsqlite3-dev
	gem install faraday nokogiri sqlite3

debug:
	DEBUG=true NOSLACK=true ./scrape

test:
	DEBUG=true NOSLACK=true ./scrape 2>/dev/null

scrape:
	[ ! -f $(cwd)/.env ] && touch $(cwd)/.env
	source $(cwd)/.env && git pull > ${LOGPATH:-/var/log/scrape}/scrape.log 2>&1
	source $(cwd)/.env && $(cwd)/scrape >> ${LOGPATH:-/var/log/scrape}/scrape.log 2>&1

.PHONY: test debug scrape

