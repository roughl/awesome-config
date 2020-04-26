local calendar = nil
local offset = 0
local bat_info = nil
local mem_info = nil

function pread(prog)
    file = io.popen(prog)
    output = file:read('*all')
    file:close()
    return output
end

function remove_calendar()
    if calendar ~= nil then
        naughty.destroy(calendar)
        calendar = nil
        offset = 0
    end
end

function add_calendar(inc_offset)
    local save_offset = offset
    remove_calendar()
    offset = save_offset + inc_offset
    local datespec = os.date("*t")
    datespec = datespec.year * 12 + datespec.month - 1 + offset
    datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
    local cal = pread("cal -m " .. datespec)
    local day = tonumber(os.date("%d"))
    if day < 10 then
        day = " "..day
    end
    -- remove rubbish bytes from the current day highlighting of cal
    cal = string.gsub(cal, string.char(0x5f, 0x08), "")
    cal = string.gsub(cal, "^%s*(.-%s.-)%s+(.-)%s*$", "%1\n%2")
    -- mark actual day
    if offset == 0 then
      cal = string.gsub(cal, "^%s*(%a*.-%d+.-%s*)("..day..")(.-)$", '%1<span background="'..beautiful.fg_normal..'" color="'..beautiful.bg_normal ..'">%2</span>%3', 1)
    end
    dprint(cal)
    calendar = naughty.notify({
        text = string.format('<span font_desc="%s">%s</span>', "monospace", os.date("%a, %d ")  .. cal),
        timeout = 0, hover_timeout = 0.5,
        width = 165,
    })
end

function add_bat_info()
  local bat = pread("acpi")
  bat_info = naughty.notify({ text = bat, position="top_left", timeout = 0, hover_timeout = 0.5,})
end

function remove_bat_info()
  if bat_info ~= nil then
    naughty.destroy(bat_info)
    bat_info = nil
  end
end

function add_mem_info()
  local mem = pread("free -m")
  mem = mem .. "\n"..pread(" ps -Ao comm,%mem,rss --sort rss | tail")
  mem_info = naughty.notify({
    text = string.format('<span font_desc="%s">%s</span>', "monospace", mem),
    position="top_left",
    timeout = 0,
    hover_timeout = 0.5,})
end

function remove_mem_info()
  if mem_info ~= nil then
    naughty.destroy(mem_info)
    mem_info = nil
  end
end

function add_cpu_info()
  --local cpu = pread("ps -Ao comm,pcpu --sort pcpu | tail")
  local cpu = pread("top -n1 -b | head -n20")
  cpu_info = naughty.notify({
    text = string.format('<span font_desc="%s">%s</span>', "monospace", cpu),
    position="top_left",
    timeout = 0,
    hover_timeout = 0.5,})
end

function remove_cpu_info()
  if cpu_info ~= nil then
    naughty.destroy(cpu_info)
    cpu_info = nil
  end
end

