
serve:
	mdbook serve

lint:
	npx prettier@2.7.1 --write src

run-all:
	zig build run-all --summary all
