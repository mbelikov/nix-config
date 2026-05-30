--[[ ===========================================================================
  Hammerspoon configuration

  Modifier conventions:
    hyper  = cmd + alt + ctrl
    move   = cmd + alt + ctrl + arrows   (move the focused window)
    grow   = alt + ctrl + arrows         (resize from the right/bottom edge)
    edge   = cmd + alt + arrows          (resize from the left/top edge)

  Shortcuts:
    hyper + F          Focus / launch far2l
    hyper + I          Focus / launch iTerm2
    hyper + W          Show a "Hello World!" alert (smoke test)
    hyper + L          Apply the LG ULTRAWIDE window layout
    hyper + S          Throw the focused window to the next screen
    hyper + M          Toggle maximize: maximize, or restore previous frame
    hyper + H          Toggle hide: minimize all windows, or restore them
    hyper + C          Cycle the focused window clockwise through corners
    hyper + N          Open the news sites in Safari
    hyper + Left/Right/Up/Down      Move the focused window
    hyper + shift + R  Reload this configuration

    alt + ctrl + Left/Right         Resize width  (right edge)
    alt + ctrl + Up/Down           Resize height (bottom edge)
    cmd + alt + Left/Right         Resize width  (left edge)
    cmd + alt + Up/Down            Resize height (top edge)
=========================================================================== --]]

local hyper = { "cmd", "alt", "ctrl" }

local farName =         "far2l"
local itermName =       "iTerm2"
local intellijName =    "IntelliJ IDEA"
local safariName =      "Safari"
local safariBundleID =  "com.apple.Safari"
local lgScreen =        "LG ULTRAWIDE"
local macScreen =       "Colour LCD"

local newsSites = {
  "https://medium.com",
  "https://habr.com",
  "https://www.reddit.com",
  "https://www.berliner-zeitung.de",
  "https://www.wsj.com",
}

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

  if border == true then
    dx, dy = clipDelta(max, f, dx, dy)
  end

  f.x = f.x + dx
  f.y = f.y + dy

  win:setFrame(f)

  return dx, dy
end

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

hs.hotkey.bind(hyper, "F", function()
	activateAppBy(farName)
end)

hs.hotkey.bind(hyper, "I", function()
	activateAppBy(itermName)
end)

hs.hotkey.bind(hyper, "W", function()
	hs.alert.show("Hello World!")
end)

hs.hotkey.bind(hyper, "L", function()
	local lgWindowLayout = {
		{safariName,		nil,	lgScreen, 	{0.20, 0, 0.4, 1},	nil,	nil},
		{intellijName,		nil,	lgScreen, 	{0.0, 0, 0.5, 1},	nil,	nil},
		{itermName,		nil,	lgScreen, 	{0.6, 0.3, 0.4, 0.7},	nil,	nil},
		{farName,		nil,	lgScreen, 	{0.25, 0.15, 0.5, 0.7},	nil,	nil}
	}
	hs.layout.apply(lgWindowLayout)
end)

hs.hotkey.bind(hyper, "S", function()
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  win:move(win:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
end)

-- Toggle maximize: first press maximizes (remembering the previous frame),
-- second press restores the remembered frame. State is kept in-memory only,
-- keyed by window id, so a reload starts fresh -- which is exactly what we want.
local maximizedFrames = {}

hs.hotkey.bind(hyper, "M", function()
  local win = hs.window.focusedWindow()
  if not win then return end

  local id = win:id()
  local saved = maximizedFrames[id]
  if saved then
    win:setFrame(saved)
    maximizedFrames[id] = nil
  else
    maximizedFrames[id] = win:frame()
    win:maximize(0)
  end
end)

-- Toggle hide: first press minimizes every visible window (remembering which
-- ones we touched), second press restores exactly those windows.
local hiddenWindows = nil

hs.hotkey.bind(hyper, "H", function()
  if hiddenWindows then
    for _, win in ipairs(hiddenWindows) do
      if win:isMinimized() then
        win:unminimize()
      end
    end
    hiddenWindows = nil
  else
    hiddenWindows = {}
    for _, win in ipairs(hs.window.visibleWindows()) do
      if win:isStandard() and not win:isMinimized() then
        win:minimize()
        table.insert(hiddenWindows, win)
      end
    end
  end
end)

hs.hotkey.bind(hyper, "Left", function()
  move("left", 100, true)
end)

hs.hotkey.bind(hyper, "Right", function()
  move("right", 100, true)
end)

hs.hotkey.bind(hyper, "Up", function()
  move("up", 100, true)
end)

hs.hotkey.bind(hyper, "Down", function()
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

-- move the win clockwise to 4 display corners
hs.hotkey.bind(hyper, "C", function()
  -- determine in which corner we are: leftBottom, leftUpper, rightUpper, rightBottom, nothing
  local order = {
                  nothing    = {value = "rightUpper", next = "leftBottom"},
                  leftBottom = {value = "leftBottom", next = "leftUpper"},
                  leftUpper  = {value = "leftUpper",  next = "rightUpper"},
                  rightUpper = {value = "rightUpper",  next = "rightBottom"},
                  rightBottom = {value = "rightBottom",  next = "leftBottom"}
               }

  local currentCorner = whichCorner()
  local newCorner = order[currentCorner].next

  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local sf = screen:frame()
  if newCorner == "leftBottom" then
    f.x = sf.x
    f.y = sf.y + sf.h - f.h
  elseif newCorner == "leftUpper" then
    f.x = sf.x
    f.y = sf.y
  elseif newCorner == "rightUpper" then
    f.x = sf.x + sf.w - f.w
    f.y = sf.y
  elseif newCorner == "rightBottom" then
    f.x = sf.x + sf.w - f.w
    f.y = sf.y + sf.h - f.h
  end

  win:setFrame(f)
end)


hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "R", function()
  hs.reload()
end)

-- Open the news sites, always in Safari (regardless of the default browser).
hs.hotkey.bind(hyper, "N", function()
  for _, url in ipairs(newsSites) do
    hs.urlevent.openURLWithBundle(url, safariBundleID)
  end
end)

hs.alert.show("Config loaded")
