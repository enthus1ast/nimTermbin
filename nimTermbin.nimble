# Package

version       = "0.5.0"
author        = "David Krause (enthus1ast)"
description   = "A termbin clone in Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["nimTermbin"]


# Dependencies

requires "nim >= 1.6.14"

# for command line arguments
# requires "cligen" # TODO

# for file mime snooping. Depends on libmagic-dev
requires "magic"

# for the index page and README.md
# taskRequires "readme", "nimib"
# taskRequires "readme", "nimja"

requires "nimib"
requires "nimja"

task readme, "update readme": # TODO path issues
  exec "nim -d:mdOutput r src/index.nim" 

