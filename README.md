dkjson-mixed
=========================================================
Suhada's extension to dkjson to allow mixed table indexes
Version 1.0

Without this extension dkjson encoding/decoding doesn't handle mixed table indexes.
For example decode(encode({a="x","P"})) is {a="x", ["1"] = "P"} (Note key for "P" is a string rather than a number)

Version 2.2 of dkjson is included  but search for an up to date version
main.lua does some testing and may be useful for checking usage.
utils.luz is a few procedures which are just used in main.lua
so other than dkjson.lua you just need dkjsonmixed.lua
