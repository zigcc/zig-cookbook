# Roadmap

This roadmap focuses on practical Zig recipes that can be added to the cookbook. The examples
should remain small, focused, and runnable independently.

## Command-Line Tools

- Read environment variables and configuration files.
- Print JSON, tables, and colored terminal output.
- Build progress bars and interactive prompts.
- Handle signals and exit gracefully.

## Files and Directories

- Work with paths and platform-specific path separators.
- Create, copy, move, and remove files and directory trees.
- Recursively list and filter directory entries with file metadata.
- Process large files with direct streaming or memory-mapped I/O.
- Watch files and directories with platform-specific APIs.
- Create temporary files and perform atomic writes.
- Compress and extract ZIP and TAR archives.

## Data Formats

- Read and write CSV files.
- Load and save TOML configuration files.
- Interoperate with YAML.
- Define and parse a custom binary protocol.
- Encode and decode MessagePack or CBOR.

## Networking

- Add timeouts, retries, and connection reuse to an HTTP client.
- Build HTTP routes and middleware.
- Implement a WebSocket client and server.
- Handle TCP message framing and packet boundaries.
- Perform DNS lookups.
- Build a TLS client.

## Concurrency and Tasks

- Implement a producer-consumer queue.
- Build a bounded task queue.
- Add concurrency limits and timeouts.
- Cancel running tasks.
- Traverse directories in parallel.
- Schedule recurring tasks.

## Databases

- Use transactions and rollbacks.
- Execute prepared statements.
- Build database migrations.
- Implement paginated queries.
- Create a database connection pool.
- Use an in-memory SQLite database for tests.

## Text Processing

- Process Unicode strings.
- Validate and truncate UTF-8 safely.
- Parse structured log files.
- Build a small template engine.
- Sanitize Markdown or HTML.
- Add practical regular-expression examples.

## System and Engineering Practices

- Configure logging levels and structured logs.
- Design application configuration.
- Model errors with dedicated error types.
- Write unit tests, integration tests, and benchmarks.
- Detect memory leaks.
- Handle paths and processes across platforms.
- Run external commands and capture their output.

## Suggested Starting Set

The following recipes are good candidates for the next additions:

1. Configuration files.
2. CSV processing.
3. HTTP client retries.
4. A producer-consumer queue.
5. Database transactions.
6. Structured logging.
7. Unit testing and benchmarking.
