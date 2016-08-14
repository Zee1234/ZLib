local ZLib = {}
--[[-- Lua implementation of the curry function
-- Developed by tinylittlelife.org
-- released under the WTFPL (http://sam.zoy.org/wtfpl/

-- reverse(...) : take some tuple and return a tuple of	elements in reverse order
--
-- e.g.	"reverse(1,2,3)" returns 3,2,1--]]
function ZLib.reverse(...)
   
   --reverse args by building a function to do it, similar to the unpack() example
   local function reverse_h(acc, v, ...)
      if 0 == select('#', ...) then
      	 return v, acc()
      else
         return reverse_h(function () return v, acc() end, ...)
      end
   end
   
   -- initial acc is the end of	the list
   return reverse_h(function () return end, ...)
end

function ZLib.curry(func, num_args)
  
   -- currying 2-argument functions seems to be the most popular application
   num_args = num_args or 2
  
   -- helper
   local function curry_h(argtrace, n)
      if 0 == n then
      	 -- reverse argument list and call function
         return func(ZLib.reverse(argtrace()))
      else
         -- "push" argument (by building a wrapper function) and decrement n
         return function (onearg)
                   return curry_h(function () return onearg, argtrace() end, n - 1)
                end
      end
   end
   
   -- no sense currying for 1 arg or less
   if num_args > 1 then
      return curry_h(function () return end, num_args)
   else
      return func
   end
end



--[[Split String Function
--This function is pretty simple: it will split a string into an array.
--If separator is undefined (function used like stringSplit(string), or is defined as false or nil), then the string will be split at every character.
--If separator is defined, a new array element will be made every time the separator is found.
--Example:
--local stringy = "This, Is, A, List"
--ZLib.stringSplit(stringy,", ")
-->{1 = "This", 2 = "Is", 3 = "A", 4 = "List"}
--local stringy2 = "ABCD"
--ZLib.stringSplit(stringy2)
-->{1= "A", 2 = "B", 3 = "C", 4 = "D"}--]]
local function stringSplit(a_str,a_sep)
  local arr = {}
  if a_sep and a_sep ~= "" then
    local iter = 1
    for i in string.gmatch(a_str,a_sep) do
      arr[iter] = i
      iter = iter + 1
    end
  else
    for i = 1, a_str:len() do
      arr[i] = a_sep:sub(i,i)
    end
  end
  return arr
end

--[[Honestly there are very few places others will need this.
--If they do, the name is probably enough to tip them off.
--It's long because I don't plan on using it often, and would rather not forget what it does.--]]
function ZLib.byteString2ByteArray(a_bytestring)
  local arr = {}
  for i = 1, a_bytestring:len() do
    arr[i] = a_bytestring:byte(i)
  end
  return arr
end

--[[Honestly there are very few places others will need this.
--If they do, the name is probably enough to tip them off.
--It's long because I don't plan on using it often, and would rather not forget what it does.--]]
function ZLib.byteArray2ByteString(a_bytearray)
  local arr = {}
  local str = ""
  for i = 1, #a_bytearray do
    arr[i] = string.char(a_bytearray[i])
    str = str .. string.char(a_bytearray[i])
  end
  return table.concat(arr,""), str
end

--[[Filter from Javascript, but applies to non-array-tables.
--a_tab is the table, a_func is the callback.
--If the callback returns true, then the value being proccessed gets inserted into the return.
--A false return will drop that piece.
--All elements in the return will be at the same index they were in the inputted object.--]]
function ZLib.filter(a_tab,a_func)
  local ret = {}
  for k,v in pairs(a_tab) do
    if a_func(v) then
      ret[k] = v
    end
  end
  return ret
end

--[[Filter from Javascript (ignores non-array elements)
--a_tab is the table, a_func is the callback.
--If the callback returns true, then the value being proccessed gets inserted into the return.
--A false return will drop that piece.
--All elements in the return will be at inserted into the lowest unused array slot (think table.insert)--]]
function ZLib.ifilter(a_tab,a_func)
  local ret = {}
  for _,v in ipairs(a_tab) do
    if a_func(v) then
      ret[#ret+1] = v
    end
  end
  return ret
end

--[[Map from Javascript, but applies to non-array-tables.
--a_tab is the input table, a_func is the callback.
--Every element is transformed into the return from a_func,
--where the input to a_func is the element
--All elements in the return will be at the same index they were in the inputted object.--]]
function ZLib.map(a_tab,a_func)
  local ret = {}
  for k,v in pairs(a_tab) do
    ret[k] = a_func(v)
  end
  return ret
end

--[[Map from Javascript (ignores non-array elements)
--a_tab is the input table, a_func is the callback.
--Every element is transformed into the return from a_func,
--where the input to a_func is the element
--All elements in the return will be at the lowest possible array index (table.insert basically)--]]
function ZLib.imap(a_tab,a_func)
  local ret = {}
  local temp
  for i,v in pairs(a_tab) do
    temp = a_func(v)
    ret[i] = temp ~= nil and temp or false
    temp = nil
  end
  return ret
end

--[[Reduce from Javascript, but applies to non-array-tables.
--a_func is the callback, and has the signature (a_ret,table_value)--]]
function ZLib.reduce(a_tab,a_func,a_ret)
  for k,v in pairs(a_tab) do
    a_ret = a_func(a_ret,v,k)
  end
  return a_ret
end

--[[Reduce from Javascript (ignores non-array values)
--a_func is the callback, and has the signature (a_ret,table_value)--]]
function ZLib.ireduce(a_tab,a_func,a_ret)
  for _,v in ipairs(a_tab) do
    a_ret = a_func(a_ret,v)
  end
  return a_ret
end

--[[Search for a table containing a key in a table of tables
--Works with any table
--Note that because table keys have no order, this will essentially choose a random table that has the key, if any--]]
function ZLib.searchForFirstTableWith(a_list,a_key)
  for _,v in pairs(list) do
    if v[a_key] then return v end
  end
  return nil
end

--[[Search for a table containing a key in an array of tables--]]
function ZLib.isearchForFirstTableWith(a_list,a_key)
  for _,v in ipairs(list) do
    if v[a_key] then return v end
  end
  return nil
end

--[[Search for all tables containing a key in a table of tables
--Works with all of any table--]]
function ZLib.searchForTablesWith(a_list,a_key)
  local ret = {}
  for k,v in pairs(list) do
    if v[a_key] then ret[k] = v end
  end
  return next(ret) and ret or nil
end

--[[Search for all tables containing a key in an array of tables
--Only parses the array section, so it's ordered--]]
function ZLib.isearchForTablesWith(a_list,a_key)
  local ret = {}
  for _,v in ipairs(list) do
    if v[a_key] then ret[#ret+1] =  v end
  end
  return next(ret) and ret or nil
end

--[[Search for a a key in a table of tables
--Works with any table
--Note that because table keys have no order, this will essentially choose a random key, if any--]]
function ZLib.searchInTablesForFirst(a_list,a_key)
  for _,v in pairs(list) do
    if v[a_key] then return v[a_key] end
  end
  return nil
end

--[[Search for a key in an array of tables--]]
function ZLib.isearchInTablesForFirst(a_list,a_key)
  for _,v in ipairs(list) do
    if v[a_key] then return v[a_key] end
  end
  return nil
end

--[[Search for all of a key in a table of tables
--Works with all of any table--]]
function ZLib.searchInTablesFor(a_list,a_key)
  local ret = {}
  for k,v in pairs(list) do
    if v[a_key] then ret[k] = v[a_key] end
  end
  return next(ret) and ret or nil
end

--[[Search for all of a key in an array of tables
--Only parses the array section, so it's ordered--]]
function ZLib.isearchForTablesWith(a_list,a_key)
  local ret = {}
  for _,v in ipairs(list) do
    if v[a_key] then ret[#ret+1] =  v[a_key] end
  end
  return next(ret) and ret or nil
end
--[[Essentially: class composition
--Arguments are a table each, with each table being a part of the base class.--]]
function ZLib.createMultiInheritanceClass (...)
  local classy = {}
  local arg = {...}
  setmetatable(c, {__index = function (t, k)
    return ZLib.isearchInTablesForFirst(arg,k)
  end})
  classy.__index = classy
  function classy:new (o)
    o = o or {}
    setmetatable(o, classy)
    return o
  end
  return c
end

--[[Escapes magic characters--]]
function ZLib.escapeMagicCharacters(a_string)
  return a_string:gsub("([%-%.%+%[%]%(%)%$%^%%%?%*])","%%%1")
end
--[[Takes a pattern, returns one that is case insensitive--]]
function ZLib.caseInsensitivePattern(a_string)
  return a_string:gsub("%a",function(c)
      return string.format("[%s%s]",string.lower(c),string.upper(c))
    end
  )
end
--[[
--=======================================A simple rounding utility--]]
function ZLib.round(a_num,a_decimal)
  a_decimal = a_decimal or 0
  a_decimal = 10 ^ a_decimal
  a_num = a_num * a_decimal * 10
  return math.floor(a_num) % 10 < 5 and math.floor(a_num/10)/a_decimal or math.ceil(a_num/10)/a_decimal
end

--[[
--=======================================Creates an __Index metamethod out of multiple __Index metamethods
--Makes a lot of classes into one, essentially.--]]
function ZLib.multiIndexer(...)
  obj = {...}
  return function(t,a_key)
    for _,v in ipairs(obj) do
      if type(v) == "table" then
        if v[a_key] ~= nil then return v[a_key] end
      elseif type(v) == "function" then
        local test = v(a_tab,a_key)
        if test ~= nil then return test end
      end
    end
    return nil
  end
end





--This is the function that allows you to grab a specific ZLib function without having to grab them all.
function getFunction(a_function)
  return ZLib[a_function]
end

return getFunction
