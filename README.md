# README

## Overview

This project is a super bare-bones link shortener.

It uses Falcon as its HTTP server and connects to a single sqlite
database for storing shortened links. The goal of this project
was to use the absolute minimal amount of dependencies.
Thus it only brings in an HTTP server and a database.
All other dependencies are gems that come with Ruby.

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
