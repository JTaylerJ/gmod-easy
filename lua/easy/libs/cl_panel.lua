easy("panel")

local multiScreenWidth = ScrW() / 1000
local multiScreenHeight = ScrH() / 1000

SIZE_MULTI = 1
SIZE_RATE = 2
SIZE_PX = 3

local function convertSize(value)
    local numb = tonumber(value)
    if numb then
        return numb
    elseif value:sub(-1) == "%" then
        return tonumber(value:sub(1, #sub - 1))
    elseif value:sub(-2) == "px" then
        return tonumber(value:sub(1, #sub - 2))
    end
end

local function convertVariablePrefix(value)
    local test_var = 20
    local prefix = value:sub(1,1)
    if prefix == "+" then
        return value:sub(2), true
    elseif prefix == "-" then
        return value:sub(2), false
    elseif prefix == "@" then
        return getfenv()[value:sub(2)]
    end
end

local function readPanelLvl(value)
    local lvl = #value:match("([^%a]+)")
    local name = value:sub(lvl + 1)
    return name, lvl
end

/*


CreatePanelByText([[
    @Frame w:100 h:100 x:100 y:100 +pupop +kinput name:frame Frame@
    ^DLabel dock:top:10% text:"Information its so bad!"; style:default +visible !DLabel
    ^^^EditablePanel dock:fill margin:5px:5px:5px:5px;
    ^^^DScrollPanel dock:fill
    ^^^^DPanel dock:top:10% margin:0:0:0:5px color:200:100:255
    ^DLabel:dock:left:100 margin:5px:5px:5px:5px
    ^DButton dock:bottom:10% text:A thinks it's done!
    !Frame
]])

*/