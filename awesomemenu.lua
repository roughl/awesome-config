#!/usr/bin/lua

require "lfs"
require "ini"

module ("awesomemenu", package.seeall)

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
			if desk_sec and desk_sec["Exec"] then
				-- valid .desktop file
				exec = desk_sec["Exec"]
				if not desk_sec["Name"] then
					return 1
				end
				name = desk_sec["Name"]
				table.insert(systemmenu, {name, exec})
			end
		end
	end
	return systemmenu
end

