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
local keepdecode = dkjson.decode

local function encode (object, state)
    local newobject = object
    local mixed = dkjson.mixedfield
    if mixed then
        local function savenumeric(tab)
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
                        savenumeric(subtab)
                    end
                end
            end
        end
        newobject = deepcopy(object)
        savenumeric(newobject)
    end
    return keepencode(newobject, state)
end

local function decode (string, position, null)
    local mixed = dkjson.mixedfield
    local function loadnumeric(tab)
        if type(tab) == "table" then
            if tab[mixed] then
                for key, subtab in pairs(tab[mixed]) do
                    loadnumeric(subtab)
                    tab[key+0] = subtab
                end
                tab[mixed] = nil
            else
                for _, subtab in pairs(tab) do
                    loadnumeric(subtab)
                end
            end
        end
    end

    local tab = keepdecode (string, position, null)
    if mixed then
        loadnumeric(tab)
    end
    return tab
end

--redefine encode and decode
dkjson.encode = encode
dkjson.decode = decode
