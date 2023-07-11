import strformat, std/net, threadpool, os, random, strutils, times, cligen
import parsecfg, uri, config, std/tempfiles
import magic

type 
  Slug = string
const MAGIC_EXTENSION = 0x1000000
const checkTimeout: int = initDuration(minutes = 30).inMilliseconds.int

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

proc genSlug(fileext = "", maxTries = 127, startLen = 1): Slug =
  var tries = 0
  var len = startLen
  while true:
    tries.inc
    if tries > maxTries:
      tries = 0
      len.inc 
    result = genRandStr(len) 
    if not exists(result & fileext): break

proc snoopMime(path: string): string =
  let guess = guessFile(path, flags = MAGIC_EXTENSION)
  if guess == "???" or guess == "":
    result = config().mimeSnoopingDefaultExt
  else:
    result = guess.split("/")[0].strip()
  if result == "": return result 
  if result.len > 0 and (not result.startswith(".")):
    result = "." & result

proc handleClient(client: Socket, clientip: string) {.thread.} =
  var bytes = 0 
  var slug: string = ""
  let (tmpfh, tmppath) = createTempFile("nimTermbin", "upload")
  while true:
    let buf = client.recv(1024)
    bytes.inc buf.len
    if bytes > config().maxUploadBytes:
      echo fmt"[ERROR] payload to large! {clientIP}"
      tmpfh.close()
      removeFile(tmppath)
      client.close()
      return
    elif buf.len == 0 and bytes == 0:
      # We do not store empty files
      tmpfh.close()
      removeFile(tmppath)
      client.close()
      return
    elif buf.len == 0:
      tmpfh.close()
      if config().mimeSnooping:
        let ext = snoopMime(tmppath)
        slug = genSlug(ext)
        let slugWithExt = slug & ext
        moveFile(tmppath, getStore() / slugWithExt)
        slug = slugWithExt
      client.send("\n" & $(config().url / slug) & "\n")
      client.close()
      break
    else:
      {.gcsafe.}:
        tmpfh.write(buf)
  echo fmt"GOT '{bytes}' bytes from '{clientip}' stored at '{slug}'" & "\n"

proc deleteOld() {.thread.} =
  while true:
    echo "============="
    echo "DELETE OLD:"
    var curTime = getTime()
    for path in walkFiles(getStore() / "*"):
      var fileTime = getCreationTime(path)
      var age = curTime - fileTime
      if age.inDays() >= config().deleteAfterDays:
        echo "[DELETE]: ", path
        removeFile(path)
    echo "============="
    sleep(checkTimeout)

proc main() =
  randomize()
  if not dirExists(getStore()):
    echo "Create store at: ", getStore()
    createDir(getStore())
  let socket = newSocket()
  socket.bindAddr(config().port)
  socket.listen()
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

