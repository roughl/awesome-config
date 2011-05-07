#!/usr/bin/lua

module( "ini", package.seeall)

function read(filename)
  local inifile = io.open(filename)
  local ini_table = {}
  local section = nil
  if not inifile then
    print("file does not exist")
    return nil
  end
  for line in inifile:lines() do
    local newsection = line:match("^%[(.*)%]") 
    if newsection then
      --print("found section: "..newsection)
      ini_table[newsection] = {}
      section = newsection
    elseif section then
      --print(line)
      local key,value=line:match("(.-)=(.*)")
      if key and value then
        ini_table[section][key] = value
      end
    end
  end

  return ini_table
end

function ini_print(ini_table)
  for k,v in pairs(ini_table) do
    if type(v) == "table" then
      print("---".. k.."---")
      for k,v in pairs(v) do
        print(k,v)
      end
    else
      print(k,v)
    end
  end
end

