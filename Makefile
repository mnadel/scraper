pi.deps:
	apt-get install ruby ruby-dev libsqlite3-dev
	gem install faraday nokogiri sqlite3

debug:
	DEBUG=true NOSLACK=true ./scrape

test:
	DEBUG=true NOSLACK=true ./scrape 2>/dev/null

.PHONY: test debug

