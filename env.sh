#!/usr/bin/env bash

# This script is primarily intended for macOS users using Homebrew.
# It sets up PKG_CONFIG_PATH for database client libraries.

if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew (brew) is not installed." >&2
    return 1 2>/dev/null || exit 1
fi

if ! brew list libpq &>/dev/null; then
    echo "Error: libpq is not installed. Please run 'make install-deps' to install it." >&2
    return 1 2>/dev/null || exit 1
fi

if ! brew list mysql-client &>/dev/null; then
    echo "Error: mysql-client is not installed. Please run 'make install-deps' to install it." >&2
    return 1 2>/dev/null || exit 1
fi

PREFIX=$(brew --prefix)
export PKG_CONFIG_PATH="${PREFIX}/opt/libpq/lib/pkgconfig:${PREFIX}/opt/mysql-client/lib/pkgconfig"
