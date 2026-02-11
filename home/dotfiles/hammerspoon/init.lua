local farName =	        "far2l"
local itermName =       "iTerm2"
local rocketName =      "Rocket.Chat"
local intellijName =    "IntelliJ IDEA"
local safariName =      "Safari"
local lgScreen =        "LG ULTRAWIDE"
local macScreen =       "Colour LCD"

local function activateAppBy(appName)
	hs.application.launchOrFocus(appName)
	local app = hs.appfinder.appFromName(appName)
	app:activate(true)
end

function stringStarts(String,Start)
   return string.sub(String,1,string.len(Start)) == Start
end

local function clipDelta(superFrame, frame, dx, dy)
  dx = math.max(dx, superFrame.x - frame.x)
  dx = math.min(dx, (superFrame.x + superFrame.w) - (frame.x + frame.w))

  dy = math.max(dy, superFrame.y - frame.y)
  dy = math.min(dy, (superFrame.y + superFrame.h) - (frame.y + frame.h))

  return dx, dy
end

local function howToD(how, delta)
  local res = delta
  if (stringStarts(how, "inc")) then
    res = delta
  else
    res = -delta
  end
  return res
end

local function resize(how, delta)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if how == "incW" then
    f.w = f.w + delta
  elseif how == "decW" then
    f.w = f.w - delta
  elseif how == "incH" then
    f.h = f.h + delta
  elseif how == "decH" then
    f.h = f.h - delta
  end
  win:setFrame(f)
end

local function move(dir, delta, border)
  local dx = 0
  local dy = 0
  if dir == "left" then
    dx = -delta
  elseif dir == "right" then
    dx = delta
  elseif dir == "up" then
    dy = -delta
  elseif dir == "down" then
    dy = delta
  end

  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  -- old version
  -- local nx = f.x + dx
  -- local ny = f.y + dy

  -- screen end: max.x + max.w
  -- win end   : nx    + f.w
  -- nx: [min, max]: math.max(max.x, nx), math.min(max.x + max.w, nx + f.w) - f.w

  -- if border == true then
    -- nx = math.max(max.x, nx)
    -- nx = math.min(max.x + max.w, nx + f.w) - f.w

    -- ny = math.max(max.y, ny)
    -- ny = math.min(max.y + max.h, ny + f.h) - f.h
  -- else
    -- nx = nx
  -- end

  -- f.x = nx
  -- f.y = ny

  if border == true then
    dx, dy = clipDelta(max, f, dx, dy)
  else
    dx = dx
  end

  f.x = f.x + dx
  f.y = f.y + dy

  win:setFrame(f)

  return dx, dy
end

local bar

local function resizeLeft(how, delta)
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local max = screen:frame()
  local f = win:frame()
  local dx, dy = clipDelta(max, f, -howToD(how, delta), -howToD(how, delta))

  if how == "incW" then
    f.x = f.x + dx
    f.w = f.w + math.abs(dx)
  elseif how == "decW" then
    f.x = f.x + dx
    f.w = f.w - math.abs(dx)
  elseif how == "incH" then
    f.y = f.y + dy
    f.h = f.h + math.abs(dy)
  elseif how == "decH" then
    f.y = f.y + dy
    f.h = f.h - math.abs(dy)
  end
  win:setFrame(f)
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "F", function()
	activateAppBy(farName)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "I", function()
	activateAppBy(itermName)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
	activateAppBy(rocketName)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
	hs.alert.show("Hello World!")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "L", function()
	local lgWindowLayout = {
		{rocketName,		nil,	lgScreen, 	{0.76, 0, 0.24, 0.5},	nil,	nil},
		{safariName,		nil,	lgScreen, 	{0.20, 0, 0.4, 1},	nil,	nil},
		{intellijName,		nil,	lgScreen, 	{0.0, 0, 0.5, 1},	nil,	nil},
		{itermName,		nil,	lgScreen, 	{0.6, 0.3, 0.4, 0.7},	nil,	nil},
		{farName,		nil,	lgScreen, 	{0.25, 0.15, 0.5, 0.7},	nil,	nil}
	}
	hs.layout.apply(lgWindowLayout)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", function()
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  win:move(win:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
  -- win:move(win:frame(), screen:next(), true, 0)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl", }, "M", function()
  local win = hs.window.focusedWindow()
  win:maximize(2)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function()
  move("left", 100, true)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", function()
  move("right", 100, true)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up", function()
  move("up", 100, true)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Down", function()
  move("down", 100, true)
end)

hs.hotkey.bind({"alt", "ctrl"}, "Left", function()
  resize("decW", 50)
end)

hs.hotkey.bind({"alt", "ctrl"}, "Right", function()
  resize("incW", 50)
end)

hs.hotkey.bind({"alt", "ctrl"}, "Down", function()
  resize("incH", 50)
end)

hs.hotkey.bind({"alt", "ctrl"}, "Up", function()
  resize("decH", 50)
end)



hs.hotkey.bind({"cmd", "alt"}, "Left", function()
  resizeLeft("incW", 50)
end)

hs.hotkey.bind({"cmd", "alt"}, "Right", function()
  resizeLeft("decW", 50)
end)

hs.hotkey.bind({"cmd", "alt"}, "Down", function()
  resizeLeft("decH", 50)
end)

hs.hotkey.bind({"cmd", "alt"}, "Up", function()
  resizeLeft("incH", 50)
end)


local function whichCorner()
  local corner = "nothing"

  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  local x = f.x
  local y = f.y
  local w = f.w
  local h = f.h

  local minX = max.x
  local minY = max.y
  local maxW = max.w
  local maxH = max.h
  local maxX = minX + maxW
  local maxY = minY + maxH

  -- local foo = y + h

  -- print(x .. ", " .. y .. "   ;   " .. (x + w) .. ", " .. (y + h))
  -- print(minX ..", " .. minY .. "  ;  " .. maxX .. ", " .. maxY)

  if (x == minX) and (y + h == maxY) then
    corner = "leftBottom"
  elseif (x == minX) and (y == minY) then
    corner = "leftUpper"
  elseif (x + w == maxX) and (y == minY) then
    corner = "rightUpper"
  elseif (x + w == maxX) and (y + h == maxY) then
    corner = "rightBottom"
  end

  return corner
end

-- move the win clocwise to 4 display corners
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
  -- derermine in which corner we are: leftBottom, leftUpper, rightUpper, rightBottom, nothing
  local order = {
                  nothing    = {value = "rightUpper", next = "leftBottom"},
                  leftBottom = {value = "leftBottom", next = "leftUpper"},
                  leftUpper  = {value = "leftUpper",  next = "rightUpper"},
                  rightUpper = {value = "rightUpper",  next = "rightBottom"},
                  rightBottom = {value = "rightBottom",  next = "leftBottom"}
               }

  local currentCorner = whichCorner() -- "nothing" -- add here a logic
  local newCorner = order[currentCorner].next

  -- hs.alert.show("current: " .. currentCorner .. ", next: " .. newCorner)

  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local sf = screen:frame()
  if newCorner == "leftBottom" then
    --
    f.x = sf.x
    f.y = sf.y + sf.h - f.h
  elseif newCorner == "leftUpper" then
    --
    f.x = sf.x
    f.y = sf.y
  elseif newCorner == "rightUpper" then
    --
    f.x = sf.x + sf.w - f.w
    f.y = sf.y
  elseif newCorner == "rightBottom" then
    --
    f.x = sf.x + sf.w - f.w
    f.y = sf.y + sf.h - f.h
  end

  win:setFrame(f)
end)


hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "N", function()
  hs.urlevent.openURL("https://exler.ru")
  hs.urlevent.openURL("https://meduza.io")
  hs.urlevent.openURL("https://echo.msk.ru")
end)

--[[
local lgScreen = "LG ULTRAWIDE"
local lgWindowLayout = {
	{"Rocket.Chat",		nil,	lgScreen, 	{0, 0, 0.24, 0.5},	nil,	nil},
	{"Safari",		nil,	lgScreen, 	{0.24, 0, 0.26, 1},	nil,	nil},
	{"IntelliJ IDEA",	nil,	lgScreen, 	{0.5, 0, 0.5, 1},	nil,	nil},
	{"iTerm2",		nil,	lgScreen, 	{0, 0.3, 0.4, 0.7},	nil,	nil},
	{"far2l.orig",		nil,	lgScreen, 	{0.25, 0.15, 0.5, 0.7},	nil,	nil}
}
hs.layout.apply(lgWindowLayout)
--]]
