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
				"/usr/share/icons/Tango/$size/categories/",
				"/usr/share/icons/gnome/$size/status/",
				"/usr/share/pixmaps/",
				"/usr/share/icons/"
			}

categories = {}

-- {{{ get_category()
function get_category( category, menu )
	if category == nil then return nil end
	if menu == nil then return nil end

	local cats = stringsplit(category, ";")
	if cats[1] then
		if not categories[cats[1]] then
			local sub_menu = {}
			categories[cats[1]] = {cats[1], sub_menu}
			table.insert(menu, categories[cats[1]])
		end
		print(cats[1])
		return categories[cats[1]][2]
	end


	--for k,cat in pairs(categories) do
	--	print(cat)
	--end
end
-- }}}

-- {{{ get_icon()
function get_icon( icon )
	-- is icon given?
	if not icon then
		return nil
	end
	-- svg is not supported in awesome
	if icon:match(".svg$") then
		return nil
	end
	-- some weird .desktop entrys set icon to ""
	if icon == "" then
		print("was empty")
		return nil
	end
	-- does icon exist?
	if lfs.attributes(icon) then
		-- existing fullpath
		return icon
	end
	local found = false
	for k,path in ipairs(icon_pathes) do
		for k,size in ipairs(sizes) do
			local icon_path = path:gsub("$size",size)
			if lfs.attributes(icon_path..icon) then
				return icon_path..icon
			elseif lfs.attributes(icon_path..icon..".png") then
				return icon_path..icon..".png"
			elseif lfs.attributes(icon_path..icon..".xpm") then
				return icon_path..icon..".xpm"
			end
		end
	end
	return nil
end
-- }}}

-- {{{ create()
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
		if lfs.attributes(path, "mode") == "directory" then
			for file in lfs.dir(path) do
				local filepath= path..file
				if lfs.attributes(filepath, "mode") == "file" then
					local myini = ini.read(filepath)

					--ini.ini_print(myini)

					desk_sec = myini["Desktop Entry"]
					if desk_sec and desk_sec["Exec"] and desk_sec["Name"] and desk_sec["NoDisplay"] ~= "true" then
						-- valid .desktop file
						local exec = desk_sec["Exec"]
						-- remove arguments like %s from exec string
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
						icon = get_icon(icon)

						local sub_table = get_category(desk_sec["Categories"], systemmenu)
						if sub_table == nil then sub_table = systemmenu end
						table.insert(sub_table, {name, exec, icon})
						print(name, exec, icon )
						print("----")
					end
				end
			end
		end
	end
	return systemmenu
end
--}}}


