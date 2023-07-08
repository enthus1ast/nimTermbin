import strformat, std/net, threadpool, os, random, strutils, times

type 
  Slug = string

randomize()

let socket = newSocket()
socket.bindAddr(Port(9999))
socket.listen()

const url = "http://localhost:8000/"
# const url = "http://localhost/"
const deleteAfterDays = 30
const checkTimeout: int = initDuration(minutes = 30).inMilliseconds.int
let store  = getAppDir() / "termbins"

proc exists(slug: Slug): bool {.gcsafe.} =
  {.gcsafe.}:
    return fileExists(store / slug)

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
  var msg = ""
  var slug = ""
  while true:
    let buf = client.recv(1024)
    if buf.len == 0:
      slug = genSlug()
      client.send("\n" & url & slug & "\n")
      client.close()
      break
    msg.add buf
  echo fmt"GOT {msg.len} bytes from {clientip}" & "\n"
  {.gcsafe.}:
    writeFile(store / slug, msg)

proc deleteOld() {.thread.} =
  while true:
    echo "============="
    echo "DELETE OLD:"
    var curTime = getTime()
    {.gcsafe.}:
      for path in walkFiles(store / "*"):
        var fileTime = getCreationTime(path)
        var age = curTime - fileTime
        # echo path, " ", curTime, " ", fileTime, "  age:", age, "in days: ", age.inDays()
        if age.inMinutes() >= deleteAfterDays:
          echo "[DELETE]: ", path
          removeFile(path)
    echo "============="
    sleep(checkTimeout)
    

proc main() =
  var deleteThread: Thread[void]
  createThread(deleteThread, deleteOld)
  var client: Socket
  var address = ""
  while true:
    socket.acceptAddr(client, address)
    echo "Client connected from: ", address
    spawn handleClient(client, address)

when isMainModule:
  main()
