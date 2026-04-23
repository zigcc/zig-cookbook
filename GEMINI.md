# Zig Cookbook - Project Context

## Project Overview
`zig-cookbook` is a multilingual collection of Zig (0.16.x) programming recipes and examples. It demonstrates common programming tasks using Zig's standard library and specialized packages. The project generates a static documentation website using the [zine](https://zine-ssg.io) static site generator.

## Key Technologies
- **Zig (0.16.0)**: The primary programming language.
- **Zine**: Static site generator for documentation.
- **Docker**: Used for running databases (Postgres, MySQL) required by some examples.
- **system dependencies**: Some examples link against C libraries like `libpq`, `mysqlclient`, and `sqlite3`.

## Directory Structure
- `assets/src/`: Contains all Zig example source files (e.g., `01-01.zig`).
- `src/`: Contains localized documentation in Super Markdown (`.smd`) format, organized by language (`en-US`, `zh-CN`).
- `lib/`: C header files and helper source code for C interop examples.
- `layouts/`: Templates and UI components for the documentation website.
- `i18n/`: Internationalization configuration files (`.ziggy`).

## Building and Running
The project uses the standard Zig build system.

### Running Examples
- **Specific Example**: `zig build run-{chapter}-{seq}` (e.g., `zig build run-01-01`).
- **All Examples**: `zig build run-all`.
- **Compile Check**: `zig build check`.

### Local Documentation
- **Preview Site**: `make serve` (starts `zine` on port 1313).
- **Zine Preview**: Alternatively, use `zine` directly.

### Dependencies & Environment
- **Install System Libraries**: `make install-deps` (supports macOS via brew and Linux via apt).
- **Databases**: `docker-compose up -d` to start the required Postgres and MySQL instances.
- **Environment Variables**: `source env.sh` may be required on some systems to set `PKG_CONFIG_PATH` for database clients.

## Development Conventions
- **Zig Version**: Targets Zig 0.16.x. Adheres to modern Zig idioms like `std.Io` and `std.process.Init` entry points.
- **Testing**: Many examples include `std.testing` assertions within their `main` or as helper blocks to verify correctness.
- **C Interop**: Uses `b.addTranslateC` in `build.zig` to interface with C libraries.
- **Formatting**: The project uses `prettier` for linting `.smd` files (via `make lint`).

## Project-Specific Tips
- When adding a new recipe:
  1. Add the Zig code to `assets/src/`.
  2. Create corresponding `.smd` files in `src/en-US/` and `src/zh-CN/`.
  3. Update `build.zig` if the example has special library dependencies.
- Use `std.debug.print` for output in examples as they are meant for learning.
