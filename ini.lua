#!/usr/bin/lua

local ini = {}

local function read(filename)
  local inifile = io.open(filename)
  local ini_table = {}
  local section = nil
  if not inifile then
    dprint("file does not exist")
    return nil
  end
  for line in inifile:lines() do
    local newsection = line:match("^%[(.*)%]") 
    if newsection then
      dprint("found section: "..newsection)
      ini_table[newsection] = {}
      section = newsection
    elseif section then
      dprint(line)
      local key,value=line:match("(.-)=(.*)")
      if key and value then
        ini_table[section][key] = value
      end
    end
  end

  return ini_table
end
ini.read = read

local function ini_print(ini_table)
  for k,v in pairs(ini_table) do
    if type(v) == "table" then
      dprint("---".. k.."---")
      for k,v in pairs(v) do
        dprint(k,v)
      end
    else
      dprint(k,v)
    end
  end
end
ini.ini_print = ini_print

return ini
