dkjson-mixed Version 1.0 by Suhada
=========================================================
Extension to dkjson to allow mixed table indexing.

dkjson is a very elegant module written by David Koff which allows converting tables to and from json.
One of lua's beautiful constructs is it's ability to have mixed index tables (i.e. numeric and otherwise).
Currently dkjson doesn't handle mixed indexing consistently.
This module is an extension to dkjson which handles mixed indexing consistently.
The method was suggested  by David Koff the author of dkjson.
encode packs numeric indexes into a subtable before encoding.
decode unpack the subtable.

Without this extension dkjson encoding/decoding doesn't handle mixed table indexes. For example decode(encode({a="x","P"})) is {a="x", ["1"] = "P"} (Note key for "P" is a string rather than a number).

Version 2.2 of dkjson is included but search for an up to date version. main.lua does some testing and may be useful for checking usage. utils.luz is a few procedures which are just used in main.lua so other than dkjson.lua you just need dkjsonmixed.lua.

main.lua does some testing and may be useful for checking usage.
utils.lua is a few procedures which are just used in main.lua so other than dkjson.lua you just need dkjsonmixed.lua.
