--[==[
=========================================================
Suhada's extension to dkjson to allow mixed table indexes
*Version 1.0
=========================================================
Without this extension dkjson encoding/decoding doesn't handle mixed table indexes.
For example decode(encode({a="x","P"})) is {a="x", ["1"] = "P"} (Note key for "P" is a string rather than a number)
=========================================================
Usage:
  Run as an extension to dkjson by:

  local json = require ("dkjson")
  require("dkjsonmixed")
  json.mixedfield = "_number_"  --The setting of this variable is what enables mixed index handling by encode and decode
  The suggested value for mixedfield is "_number_" but any value that will not be used in any tables will be fine.
  To disable mixed index handling just set dkjson.mixedfield=nil.

dkjson.encode packs all values with numeric indices into a subtable before turning into json.
  The key of the subtable is dkjson.mixedfield.
  With dkjson.mixedfield="_number_":
  encode({a="x","P"}) is {"a":"x","_number_":{"1":"P"}} which decodes correctly.

dkjson.decode looks for tables named dkjson.mixedfield and unpacks them.
  With dkjson.mixedfield="_number_":
  decode({"a":"x","_number_":{"1":"P"}}) = {a="x","P"}
=========================================================
]==]

local dkjson = require ("dkjson")

local function deepcopy(t)
    if type(t) ~= 'table' then return t end
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = deepcopy(v)
        end
        res[k] = v
    end
    setmetatable(res,mt)
    return res
end

local keepencode = dkjson.encode
local function encode (object, state)
    local newobject = object
    local mixed = dkjson.mixedfield
    if mixed then
        local function packnumeric(tab)
            if type(tab) == "table" then
                --Seperate numeric indices
                for key, subtab in pairs(tab) do
                    --Didn't use ipairs because that doesn't work for sparse arrays
                    if type(key)=="number" then
                        --If needed then create table for numeric indices
                        if tab[mixed] == nil then tab[mixed] = {} end
                        --Copy numeric indices into mixed numeric table
                        tab[mixed][key..""] = subtab
                        --remove from the table
                        tab[key] = nil
                        --recurse
                        packnumeric(subtab)
                    end
                end
            end
        end
        newobject = deepcopy(object)
        packnumeric(newobject)
    end
    return keepencode(newobject, state)
end
dkjson.encode = encode

local keepdecode = dkjson.decode
local function decode (string, position, null)
    local mixed = dkjson.mixedfield
    local function unpacknumeric(tab)
        if type(tab) == "table" then
            if tab[mixed] then
                for key, subtab in pairs(tab[mixed]) do
                    unpacknumeric(subtab)
                    tab[key+0] = subtab
                end
                tab[mixed] = nil
            else
                for _, subtab in pairs(tab) do
                    unpacknumeric(subtab)
                end
            end
        end
    end

    local tab = keepdecode (string, position, null)
    if mixed then
        unpacknumeric(tab)
    end
    return tab
end
dkjson.decode = decode
