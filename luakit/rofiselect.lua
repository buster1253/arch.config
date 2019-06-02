local ipairs = ipairs
local format = string.format
local escape = require "lousy".util.escape
local concat = table.concat
local insert = table.insert

local join = function(s)
    return concat(s, '\n')
end

local rofi = 'rofi -dmenu -i -matching normal'

local _M = {}

_M.db = sqlite3{ filename = luakit.data_dir .. "/bookmarks.db" }

_M.tabs = function(w)
    local rows = {}
    for _, view in ipairs(w.tabs.children) do
        -- on reload title is not available
        if not escape(view.title) then
            insert(rows, escape(view.uri))
        else
            insert(rows, escape(view.title))
        end
    end
    local selector = io.popen(format("echo -e '%s' | %s", join(rows), rofi))
    local selected = selector:read("*line")

    for i,v in ipairs(rows) do
        if v == selected then
            w.tabs:switch(i)
        end
    end
end

_M.bookmarks = function(w, newtab)
    local bookmarks = _M.db:exec([[ SELECT * FROM (bookmarks) ]])
    local rows = {}
    for _,bookmark in ipairs(bookmarks) do
        insert(rows, bookmark.title)
    end

    local selector = io.popen(format("echo -e '%s' | %s", join(rows), rofi))
    local selected = selector:read("*line")

    for i,bookmark in ipairs(bookmarks) do
        if bookmark.title == selected then
            if newtab then
                w:new_tab(bookmarks[i].uri)
            else
                w:navigate(bookmarks[i].uri)
            end
        end
    end
end

return _M

-- vim: et:sw=4:ts=4:tw=80
