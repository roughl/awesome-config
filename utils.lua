

function stringsplit(string, char)
	-- is there any better way to split a string intu substrings?
	local oldpos = 0
	subs = {}
	while true do
		local pos = string:find(char, oldpos+1)
		if pos == nil then
			table.insert(subs,string:sub(oldpos+1))
			break
		end
		table.insert(subs,string:sub(oldpos,pos-1))
		oldpos=pos
	end
	return subs
end

