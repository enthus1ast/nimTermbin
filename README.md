
# nimTermbin
## A terminal Pastebin
(clone of [termbin](https://termbin.com)'s Fiche in [Nim](https://nim-lang.org)) 


Usage:

```
echo just testing!  | nc localhost 9999
```


```
cat ~/some_file.txt | nc localhost 9999
```

```
ls -la | nc localhost 9999
```


Requirements
==========

There is only one thing you need to use this service - netcat (or `ncat`, `socat` ....). 
To check if you already have it installed, type in terminal nc (or `ncat`, `socat`)

Netcat is available on most platforms, including Windows, Mac OS X and Linux.


Alias
=====

To make your life easier, you can add alias to your .bashrc on Linux and .bash_profile on Mac OS X. Just remember to reset your terminal session after that.

```
echo 'alias tb="nc localhost 9999"' >> .bashrc
```

```
echo 'alias tb="nc localhost 9999"' >> .bash_profile
```

```
echo less typing now! | tb
```



Acceptable use policy
====================

Please do not post any informations that may violate law (login/password lists, email lists, personal information). IP addresses are logged, so you might get banned.

Life span of single paste is  **30 day(s)**. 
Older pastes are deleted.

Max size of a single post should not exeed **29.297kB**.

