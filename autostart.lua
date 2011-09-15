#!/usr/bin/lua
-- vim:ts=4:sw=4

require "lfs"
require "ini"
require "utils"

module ("autostart", package.seeall)

showIn = { "awesome", "GNOME" }

function run_once(prg)
	if not prg then
		do return nil end
	end
	os.execute("pgrep -f -u $USER -x \"" .. prg .. "\" || (" .. prg .. ")")
end

function checkShowIn(onlyShowIn)
	-- if nil its valid for every desktop
	if onlyShowIn == nil then
		return true
	end
	for k,v in pairs(showIn) do
		if string.find(tostring(onlyShowIn), v) then
			return true
		end
	end
	return false
end

function execute(path)
	-- default parameters
	--if terminal_cmd == nil then terminal_cmd = "urxvt -e " end
	if path == nil then
	  path = os.getenv("XDG_CONFIG_DIRS")..":".. os.getenv("XDG_CONFIG_HOME")
	  if path == nil then path = "/etc/xdg/" end
	end
	local dirs = stringsplit(path, ":")

	autostart_table = {}

	for k,dir in pairs(dirs) do
		local path = dir.."/autostart/"
		print("search in "..path)
		if lfs.chdir(path) then
			for file in lfs.dir(path) do
				if lfs.attributes(file).mode == "file" then
					local myini = ini.read(file, autostart_table[file])
					desk_sec = myini["Desktop Entry"]
					if desk_sec and desk_sec["Exec"] and desk_sec["Name"] then
						-- valid .desktop file
						autostart_table[file]= myini
					end
				end
			end
		end
	end
	for k,v in pairs(autostart_table) do
		desk_sec = v["Desktop Entry"]
		local onlyShowIn = desk_sec["OnlyShowIn"]
		if checkShowIn(desk_sec["OnlyShowIn"]) then
			local exec = desk_sec["Exec"]
			local j = exec:match("(.*)%%")
			if j then
			   exec = j
			end
			local name = desk_sec["Name"]
			local icon = desk_sec["Icon"]
			if desk_sec["Terminal"] == "true" then
				exec = terminal_cmd .. exec
			end
			--print(exec)
			--os.execute("notify-send Autostart \"Starting "..name..": "..exec.."\"")
			run_once(exec)
		end
		--print(k,v)
	end
end

