# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a minimal link shortener built with Ruby using the Falcon HTTP server. The entire application logic is contained in `config.ru` as a Rack application. It stores shortened URLs in memory using a simple hash (KEYS) and generates short codes using SHA1 hashing.

## Development Commands

**Setup:**
```bash
bin/setup
```

**Run the server:**
```bash
bin/serve
```

**Run with custom host/port:**
```bash
HOST=0.0.0.0 PORT=8080 bin/serve
```

**Run tests:**
```bash
bin/test
```

## Architecture

- **Single file application:** All logic in `config.ru`
- **Minimal dependencies:** Only uses Falcon HTTP server + Ruby stdlib
- **In-memory storage:** Uses `KEYS` hash to store URL mappings
- **Simple routing:** GET requests retrieve URLs, POST requests create short links

## API

- **POST /** with `Content-Type: text/plain` and URL in body → Returns SHA1 hash as short code
- **GET /{code}** → Returns "Redirected to {code}" message (with 10 second delay)

## Key Implementation Details

- Uses `Digest::SHA1.hexdigest(url)` for generating short codes
- Stores mappings in `KEYS[encoded] = url`
- Only accepts `text/plain` content type for POST requests
- Contains intentional 10-second delay in GET handler
- No persistence - data lost on restart