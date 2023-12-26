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
	echo "Nothing required"
endif
ifeq ($(uname_S), Linux)
	sudo apt install -y pkg-config libsqlite3-dev
endif
