# README

## Overview

This project is a super bare-bones link shortener.

It uses Falcon as its HTTP server and connects to a SQLite
database for storing shortened links. The database configuration
is managed in `db/database.rb` and the connection is established
via `Database.connect`.

Key features:
- Minimal dependencies (just Falcon and SQLite3)
- Database configuration separated from application logic
- Simple REST API for creating and retrieving short links

## Setup

```bash
bin/setup
```

## Running

```bash
bin/serve
```

The server will start on http://localhost:3000 by default. You can customize the host and port:

```bash
HOST=0.0.0.0 PORT=8080 bin/serve
```

## Testing

```bash
bin/test
```
