import strformat, std/net, threadpool, os, random, strutils, times
import parsecfg, uri, config


type 
  Slug = string

randomize()



let socket = newSocket()
socket.bindAddr(config().port)
socket.listen()

# const url = "http://localhost:8000/"
# const url = "http://localhost/"
# const deleteAfterDays = 30
const checkTimeout: int = initDuration(minutes = 30).inMilliseconds.int
# const maxUploadBytes = 100_000_000
let store =
  if config().storeName.isAbsolute:
    config().storeName
  else:
    getAppDir() / config().storeName

proc getStore(): string {.gcsafe.} =
  {.gcsafe.}:
    return store

proc exists(slug: Slug): bool {.gcsafe.} =
  return fileExists(getStore() / slug)

proc genRandStr(len: int): string  {.gcsafe.} =
  for _ in 0 ..< len:
    result.add sample(Letters + Digits)

proc genSlug(maxTries = 127, startLen = 1): Slug =
  var tries = 0
  var len = startLen
  while true:
    tries.inc
    if tries > maxTries:
      tries = 0
      len.inc 
    result = genRandStr(len)
    if not exists(result): break

proc handleClient(client: Socket, clientip: string) {.thread.} =
  var bytes = 0 
  var slug = genSlug()
  var fh = open(getStore() / slug, fmWrite)
  while true:
    let buf = client.recv(1024)
    bytes.inc buf.len
    if bytes > config().maxUploadBytes:
      echo fmt"[ERROR] payload to large! {clientIP}"
      fh.close()
      removeFile(getStore() / slug)
      client.close()
      return
    elif buf.len == 0 and bytes == 0:
      # We do not store empty files
      fh.close()
      removeFile(getStore() / slug)
      client.close()
      return
    elif buf.len == 0:
      fh.close()
      client.send("\n" & $(config().url / slug) & "\n")
      client.close()
      break
    else:
      {.gcsafe.}:
        fh.write(buf)
  echo fmt"GOT '{bytes}' bytes from '{clientip}' stored at '{slug}'" & "\n"

proc deleteOld() {.thread.} =
  while true:
    echo "============="
    echo "DELETE OLD:"
    var curTime = getTime()
    for path in walkFiles(getStore() / "*"):
      var fileTime = getCreationTime(path)
      var age = curTime - fileTime
      # echo path, " ", curTime, " ", fileTime, "  age:", age, "in days: ", age.inDays()
      if age.inMinutes() >= config().deleteAfterDays:
        echo "[DELETE]: ", path
        removeFile(path)
    echo "============="
    sleep(checkTimeout)

proc main() =
  var deleteThread: Thread[void]
  createThread(deleteThread, deleteOld)
  while true:
    var client: Socket
    var address = ""
    socket.acceptAddr(client, address)
    echo "Client connected from: ", address
    spawn handleClient(client, address)

when isMainModule:
  main()
