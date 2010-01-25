#!/usr/bin/lua

require "lfs"
require "ini"

module "awesomemenu"

function create(path = "/usr/share/applications/", terminal_cmd )
	local systemmenu = {}

	for file in lfs.dir(path) do
		if lfs.attributes(file).mode == "file" then
			local myini = ini.read(file)

			--ini.ini_print(myini)

			desk_sec = myini["Desktop Entry"]
			if desk_sec then
				-- valid .desktop file
				if not desk_sec["Exec"] then
					return nil
				end
				exec = desk_sec["Exec"]
				if not desk_sec["Name"] then
					return 1
				end
				name = desk_sec["Name"]
			else
				return nil
			end

			table.insert(systemmenu, {name, exec})
			--print(name, exec)
		end
	end
	return systemmenu
end
