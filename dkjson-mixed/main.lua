

local json = require("dkjson")
--Adjust dkjson encode and decode to handle mixed indexing
require("dkjsonmixed")

local utils = require("utils")

function test(title, tab)
    print("-----------------------------------------")
    print(title)
    print(utils.tableshow(tab,"before"))
    local jsontab = json.encode(tab,{indent=true})
    print("JSONFILE is:",jsontab)
    local after = json.decode(jsontab)
    print(utils.tableshow(after,"after"))
    print(utils.deepcompare(tab,after) and "Before=After" or "Before ~= After")
    print("-----------------------------------------")
end

local mixed = {title="words","hello","goodbye"}
test("Mixed without handling of mixed indices", mixed)

json.mixedfield = "_number_"
test("Mixed with handling of mixed indices", mixed)

test("Number index:", {"NUM"})
test("String index:", {["1"]="STR"})
test("Both index:", {"NUM",["1"]="STR"})

local tab = {a="A",b="B",{1,2,3,{["1"]="XXX"}}}
test("Nesting", tab)

local tab = { ["1"]="STRING ONE",[1]="NUMBER ONE",
              ["2"]="STRING TWO",[2]="NUMBER TWO",
              ["4"]="STRING FOUR",[4]="NUMBER FOUR"
            }
test("Mixed with gap", tab)

json.mixedfield = nil
test("Simple Mixed without mixedfield:", {a="x","P"} , false)

json.mixedfield = "_number_"
test("Simple Mixed with mixedfield=_number_:", {a="x","P"} , true)

json.mixedfield = "_INDEX_"
test("Simple Mixed with mixedfield=_INDEX_:", {a="x","P"} , true)
