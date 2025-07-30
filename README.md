# README

## Overview

This project is a super bare-bones link shortener.

It uses Falcon as its HTTP server and connects to a SQLite
database for storing shortened links. The database configuration
is managed in `db/database.rb` and the connection is established
via `Database.connect`.

## Setup

```bash
bin/setup
```

## Running

```bash
bin/serve
```

The server will start on <http://localhost:3000> by default. You can customize the host and port:

```bash
HOST=0.0.0.0 PORT=8080 bin/serve
```

## API

- **POST /**

  - Content-Type: `text/plain` required
  - Request body: URL to shorten
  - Response: shortened url

- **GET /{short_link}**
  - 301 Redirect to original URL if found
  - 404 Not Found if short link doesn't exist

## Testing

```bash
bin/test
```
