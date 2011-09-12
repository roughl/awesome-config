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
	if icon then
		-- some weird .desktop entrys set icon to ""
		if icon == "" then
			print("was empty")
			icon = nil
		-- does icon exist?
		elseif lfs.attributes(icon) then
		-- ok it's a full path

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
	return icon
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
		if lfs.chdir(path) then
			for file in lfs.dir(path) do
				if lfs.attributes(file).mode == "file" then
					local myini = ini.read(file)

					--ini.ini_print(myini)

					desk_sec = myini["Desktop Entry"]
					if desk_sec and desk_sec["Exec"] and desk_sec["Name"] then
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
						if icon then
							table.insert(sub_table, {name, exec, icon})
							print(name, exec, icon )
						else
							print("no icon")
							table.insert(sub_table, {name, exec})
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
--}}}


