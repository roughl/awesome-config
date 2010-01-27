#!/usr/bin/lua

require "lfs"
require "ini"

module ("awesomemenu", package.seeall)

icon_path = "/usr/share/icons/hicolor/16x16/apps/"
pixmap_path="/usr/share/pixmaps/"

function create( terminal_cmd, path )
	-- default parameters
	if terminal_cmd == nil then terminal_cmd = "urxvt -e " end
	if path == nil then
	  path = os.getenv("XDG_DATA_DIRS")
	  if path == nil then path = "/usr/local/share/:/usr/share/" end
	end
	local dirs = {}
	local systemmenu = {}
	local oldpos = 0

	-- is there any better way to split a string intu substrings?
	while true do
		pos = path:find(":", oldpos+1)
		if pos == nil then
			--print(path:sub(oldpos+1))
			table.insert(dirs,path:sub(oldpos+1))
			break
		end
		--print(path:sub(oldpos,pos-1))
		table.insert(dirs,path:sub(oldpos,pos-1))
		oldpos=pos
	end
	
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
						--print(name,exec,icon)
						-- is icon given?
						if icon then
							-- some weird .desktop entrys set icon to ""
							if icon == "" then
								icon = nil
							-- does icon exist?
							elseif lfs.attributes(icon) then
							-- ok it's a full path

							--search icon in default paths
							elseif lfs.attributes(icon_path..icon) then
								icon = icon_path..icon
							elseif lfs.attributes(icon_path..icon..".png") then
								icon = icon_path..icon..".png"
							elseif lfs.attributes(pixmap_path..icon) then
								icon = pixmap_path..icon
							elseif lfs.attributes(pixmap_path..icon..".png") then
								icon = pixmap_path..icon..".png"
							else
								icon = nil
							end
						end
						if icon then
							table.insert(systemmenu, {name, exec, icon})
						--	print(name, exec, icon )
						else
							table.insert(systemmenu, {name, exec})
						--	print(name, exec)
						end
					end
				end
			end
		end
	end
	return systemmenu
end

