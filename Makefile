ifeq ($(OS),Windows_NT)
	uname_S := Windows
else
	uname_S := $(shell uname -s)
endif

.PHONY: serve
serve: generate-summary
	mdbook serve

.PHONY: generate-summary
generate-summary:
	node generate-summary.js

.PHONY: lint
lint:
	npx prettier@2.7.1 --write book-src

.PHONY: run
run:
	zig build run-all --summary all

.PHONY: install-deps
install-deps:
ifeq ($(uname_S), Darwin)
	# sqlite3 is preinstalled on macOS
	brew install pkgconf libpq mysql-client
endif
ifeq ($(uname_S), Linux)
	sudo apt install -y pkg-config libsqlite3-dev libpq-dev libmysqlclient-dev
endif


.PHONY: clean
clean:
	rm -rf zig-out zig-cache

EXCLUDE = --exclude "*webp" --exclude "*svg" --exclude "*gif"

.PHONY: webp
webp:
	fd -t f $(EXCLUDE) --full-path './book-src/images' --exec convert {} {.}.webp \;
	fd -t f $(EXCLUDE) --full-path './book-src/images' --exec rm {} \;
