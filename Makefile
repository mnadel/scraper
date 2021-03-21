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
	git pull
	$(cwd)/scrape

.PHONY: test debug scrape

