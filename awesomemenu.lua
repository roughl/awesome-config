#!/usr/bin/lua
-- vim:ts=4:sw=4

require "lfs"
require "ini"
require "utils"

module ("awesomemenu", package.seeall)

-- array of sizes; order matters
sizes = { "16x16", "32x32", "64x64", "128x128" }
icon_pathes = { "/usr/share/icons/hicolor/$size/apps/",
				"/usr/share/icons/Tango/$size/devices/",
				"/usr/share/icons/Tango/$size/apps/",
				"/usr/share/pixmaps/"
			}

function create( terminal_cmd, path )
	-- default parameters
	if terminal_cmd == nil then terminal_cmd = "urxvt -e " end
	if path == nil then
	  path = os.getenv("XDG_DATA_DIRS")
	  if path == nil then path = "/usr/local/share/:/usr/share/" end
	end

	local systemmenu = {}
	local dirs = stringsplit(path, ":")

	for k,dir in pairs(dirs) do
		local path = dir.."/applications/"
		--print("search in "..path)
		if lfs.chdir(path) then
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
						print(name,exec,icon)
						-- is icon given?
						if icon then
							-- some weird .desktop entrys set icon to ""
							if icon == "" then
								print("was empty")
								icon = nil
							-- does icon exist?
							elseif lfs.attributes(icon) then
							-- ok it's a full path

							--search icon in default paths
							--elseif lfs.attributes(pixmap_path..icon) then
							--	icon = pixmap_path..icon
							--elseif lfs.attributes(pixmap_path..icon..".png") then
						--		icon = pixmap_path..icon..".png"
							else
								local found = false
								for k,path in ipairs(icon_pathes) do
									for k,size in ipairs(sizes) do
										local icon_path = path:gsub("$size",size)
										if lfs.attributes(icon_path..icon) then
											icon = icon_path..icon
											found = true
											break
										elseif lfs.attributes(icon_path..icon..".png") then
											icon = icon_path..icon..".png"
											found = true
											break
										end
									end
									if found then break end
								end
								if not found then icon = nil end
							end
						end
						if icon then
							table.insert(systemmenu, {name, exec, icon})
							print(name, exec, icon )
						else
							print("no icon")
							table.insert(systemmenu, {name, exec})
							print(name, exec)
						end
						print("----")
					end
				end
			end
		end
	end
	return systemmenu
end


