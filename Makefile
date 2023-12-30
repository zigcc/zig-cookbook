ifeq ($(OS),Windows_NT)
	uname_S := Windows
else
	uname_S := $(shell uname -s)
endif

serve:
	mdbook serve

lint:
	npx prettier@2.7.1 --write src

run:
	zig build run-all --summary all

install-deps:
ifeq ($(uname_S), Darwin)
	# sqlite3 is preinstalled on macOS
	brew install pkg-config libpq
endif
ifeq ($(uname_S), Linux)
	sudo apt install -y pkg-config libsqlite3-dev libpq-dev
endif
