#!/usr/bin/lua

require "lfs"
require "ini"

module ("awesomemenu", package.seeall)

icon_path = "/usr/share/icons/hicolor/16x16/apps/"

function create( path, terminal_cmd  )
	-- default parameters
	if path == nil then path = "/usr/share/applications/" end
	if terminal_cmd == nil then terminal_cmd = "urxvt -e " end
	local systemmenu = {}
	lfs.chdir(path)
	for file in lfs.dir(path) do
		if lfs.attributes(file).mode == "file" then
			local myini = ini.read(file)

			--ini.ini_print(myini)

			desk_sec = myini["Desktop Entry"]
			if desk_sec and desk_sec["Exec"] and desk_sec["Name"] then
				-- valid .desktop file
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
				--print(name,exec,icon)
				-- is icon given?
				if icon then
					-- does icon exist?
					if lfs.attributes(icon) then
						table.insert(systemmenu, {name, exec, icon})
					elseif lfs.attributes(icon_path..icon..".png") then
						--search icon in default path
						icon = icon_path..icon..".png"
						table.insert(systemmenu, {name, exec, icon})
					end
					--print(name, exec,icon)
				else
					table.insert(systemmenu, {name, exec})
				end
			end
		end
	end
	return systemmenu
end

