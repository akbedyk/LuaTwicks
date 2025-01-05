--[[* CA common functions module
]]

local Core = require('openmw.core')

local function getId(ref) -- get object id
  local str = tostring(ref)
  return string.sub(str,7,string.find(str,' ') - 1)
end

local function tableCopy(from)
  local t = {}
  if not from then return t end
  for k,v in pairs(from) do
    if type(v) == 'table' then t[k] = tableCopy(v)
    else t[k] = v
    end
  end
  return t
end

local function arrayAdd(a,data,indx)
  if not data then return end
  local l = #a
  if l == 0 then a[1] = data
  elseif not indx or l < indx then a[l+1] = data
  elseif indx <= 0 then return
  else
    for i = l,indx,-1 do
      a[i+1] = a[i]
    end
    a[indx] = data
  end
end

local function arrayDel(a,indx)
  local l = #a
  if l == 0 then return end
  if not indx or l <= indx then a[l] = nil
  elseif indx <= 0 then return
  else
    for i = indx,l-1 do
      a[i] = a[i+1]
    end
    a[l] = nil
  end
end

local function deepToString(val, level, prefix)
    local prefix = prefix or ''
    local level = (level or 1) - 1
    local ok, iter, t = pcall(function() return pairs(val) end)
    if level < 0 or not ok then
        return tostring(val)
    end
    local newPrefix = prefix..'  '
    local strs = {tostring(val)..' {\n'}
    for k, v in iter, t do
      strs[#strs + 1] = newPrefix..tostring(k)..' = '..deepToString(v, level, newPrefix)..',\n'
    end
    strs[#strs + 1] = prefix..'}'
    return table.concat(strs)
end

local monthsDuration = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
local daysInWeek = 7
local daysInYear = 365
local startingYear = 427
local startingYearDay = 227
local startingWeekDay = 1

local month = 1
local function gameDHMS()
    local ts = math.floor(Core.getGameTime())
    print('[CA] com.gameDHMS day',ts/86400)
    local day = math.floor(ts/86400)
    local hour = math.floor((ts % 86400)/3600)
    local min = math.floor((ts % 3600)/60)
    local sec = ts % 60
  --local year = math.floor(day / daysInYear) + startingYear
  --local yday = (day + startingYearDay - 1) % daysInYear + 1
  --local wday = (day + startingWeekDay - 1) % daysInWeek + 1
  --month = 1
  --while day > monthsDuration[month] do
  --      day = day - monthsDuration[month]
  --      month = month + 1
  --end
    return day, hour, min, sec
end

local gameDay = function()
  return math.floor(Core.getGameTime()/86400)
end

local gameHour = function()
  return math.floor((Core.getGameTime()%86400)/3600)
end

local gameMin = function()
  return math.floor((Core.getGameTime()%3600)/60)
end

local gameSec = function()
  return math.floor(Core.getGameTime()%60)
end

local distXY = function(p1, p2)
  local dx = p1[1] - p2[1]
  local dy = p1[2] - p2[2]
  return math.sqrt(dx*dx + dy*dy)
end

local distXYZ = function(p1, p2)
  local dx = p1[1] - p2[1]
  local dy = p1[2] - p2[2]
  local dz = p1[3] - p2[3]
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local max2 = function(x1, x2)
  if x1 >= x2 then return x1 
  else return x2
  end
end

local max3 = function(x1, x2, x3)
  if x1 >= x2 then 
    if x1 >= x3 then return x1 
    else return x3
    end
  else 
    if x2 >= x3 then return x2
    else return x3
    end
  end
end

  ---=== Map func ===---

local randPosXY = function(pos,d)
  return {pos.x + math.random(2*d) - d, pos.y + math.random(2*d) - d, pos.z}
end

local randRectPoint = function(p1, p2, n)
  local x = p1[1] + (p2[1] - p1[1]) / math.random(n)
  local y = p1[2] + (p2[2] - p1[2]) / math.random(n)
  return {x,y,max2(p1[3],p2[3])}
end

local buildGroundLine = function(p1, p2, n)
  local dx = (p2[1] - p1[1]) / (n + 4)
  local dy = (p2[2] - p1[2]) / (n + 4)
  local z = math.floor(max2(p1[3],p2[3]))

  local line = {}
  local point = {}
  point[1] = math.floor(p1[1] + 2*dx)
  point[2] = math.floor(p1[2] + 2*dy)
  point[3] = z
  line[1] = point
  print("[CA] Line start: {%d %d %d}", point[1], point[2], point[3])
  for i = 2,n do
    point = {}
    point[1] = math.floor(line[i-1][1] + dx)
    point[2] = math.floor(line[i-1][2] + dy)
    point[3] = z
    line[i] = point
    print("[CA] {%d %d %d}", point[1], point[2], point[3])
  end
  line[0] = n
  return line
end

return {
  getId = getId,
  tableCopy = tableCopy,
  deepToString = deepToString,
  gameDHMS = gameDHMS,
  gameHour = gameHour,
  gameMin = gameMin,
  gameSec = gameSec,
  gameDay = gameDay,
  distXY = distXY,
  distXYZ = distXYZ,
  randPosXY = randPosXY,
  randRectPoint = randRectPoint,
  buildGroundLine = buildGroundLine,
}