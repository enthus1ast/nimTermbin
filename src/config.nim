import parsecfg, uri, strutils, net, os
export parsecfg, uri, strutils, net, os

type
  Config* = object
    port*: Port
    url*: Uri
    deleteAfterDays*: Positive
    maxUploadBytes*: Positive
    storeName*: string
    mimeSnooping*: bool
    mimeSnoopingDefaultExt* : string

proc loadConfig*(): Config =
  let configFile = loadConfig(getAppDir() / "nimTermbin.conf")
  template g(str: string): string =
    configFile.getSectionValue("", str)
  return Config(
    port: g("port").parseInt().Port,
    url: g("url").parseUri(),
    deleteAfterDays: g("deleteAfterDays").parseInt(),
    maxUploadBytes: g("maxUploadBytes").parseInt(),
    storeName: g("storeName"),
    mimeSnooping: g("mimeSnooping").parseBool(),
    mimeSnoopingDefaultExt: g("mimeSnoopingDefaultExt").strip(),
  )

var configObj* = loadConfig()
proc config*(): Config {.gcsafe.} =
  {.gcsafe.}:
    return configObj
