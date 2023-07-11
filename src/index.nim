import nimib
from nimib / renders import useMdBackend

import config, nimja
import parsecfg
from net import Port

when defined(mdOutput):
  echo "using Markdown backend"
  nbInitMd
else:
  nbInit
nb.title = "nimTermbin"

nbText: """
# nimTermbin
## A terminal Pastebin
(clone of [termbin](https://termbin.com)'s Fiche in [Nim](https://nim-lang.org)) 
"""


nbText: tmpls """
Usage:

```
echo just testing!  | nc {{config().url.hostname}} {{config().port}}
```


```
cat ~/some_file.txt | nc {{config().url.hostname}} {{config().port}}
```

```
ls -la | nc {{config().url.hostname}} {{config().port}}
```

"""
nbText: """
Requirements
==========

There is only one thing you need to use this service - netcat (or `ncat`, `socat` ....). 
To check if you already have it installed, type in terminal nc (or `ncat`, `socat`)

Netcat is available on most platforms, including Windows, Mac OS X and Linux.
"""

nbText: tmpls"""
Alias
=====

To make your life easier, you can add alias to your .bashrc on Linux and .bash_profile on Mac OS X. Just remember to reset your terminal session after that.

```
echo 'alias tb="nc {{config().url.hostname}} {{config().port}}"' >> .bashrc
```

```
echo 'alias tb="nc {{config().url.hostname}} {{config().port}}"' >> .bash_profile
```

```
echo less typing now! | tb
```



Acceptable use policy
====================

Please do not post any informations that may violate law (login/password lists, email lists, personal information). IP addresses are logged, so you might get banned.

Life span of single paste is  **{{config().deleteAfterDays}} day(s)**. 
Older pastes are deleted.

Max size of a single paste should not exeed **{{config().maxUploadBytes.formatSize(prefix = bpColloquial)}}**.

Hosting
==========
[nimTermbin is free software](https://github.com/enthus1ast/nimTermbin).
You can host it yourself!

Features
--------



Config
------


```
# The tcp port we listen on
port = 9999

# The (base) URL that is returned on successful upload
url = "http://localhost:8000/t/"

# Old downloads are deleted periodically
deleteAfterDays = 30

# How large the upload can be at max,
# if this is exceeded, the socket is closed.
maxUploadBytes = 30_000


# This is relative to the application,
# or absolute
storeName = "termbins"

# Enable "mimeSnooping" it tries to guess the mimetype based on the bytestream
# Then it renames the file based on the outcome.
mimeSnooping = true

# If the file is unknown use default extention
mimeSnoopingDefaultExt = txt
```


Docker
======

You can easily deploy nimTermbin using docker/docker compose.

Just run:
  ```
  docker compose build
  docker compose up
  ```

"""






when defined(mdOutput):
  nb.filename = "../README.md"
  nbSave
else:
  nbSave
