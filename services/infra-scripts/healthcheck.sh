#!/bin/sh
curl -fs http://localhost:3000/health || exit 1
