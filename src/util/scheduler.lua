local CA = require('CA.ca')

local this = {    -- scheduler
  debug = true,
}

local function stackUpd(stack,k,data)
  if data then stack[k] = data end
  local len = #stack
  if len <= 1 then return end
  local t = data[3]
  if k == 1 then
    for i = 2,len do
      if t < stack[i][3] then
        local s = stack[i]
        stack[i] = stack[i-1]
        stack[i-1] = s
      end
    end
  elseif k == len then
    for i = k-1,1,-1 do
      if t > stack[i][3] then
        local s = stack[i]
        stack[i] = stack[i+1]
        stack[i+1] = s
      end
    end
  elseif t < stack[k+1][1] then
    for i = k+1,len do
      if t < stack[i][3] then
        local s = stack[i]
        stack[i] = stack[i-1]
        stack[i-1] = s
      end
    end
  else
    for i = k-1,1,-1 do
      if t > stack[i][3] then
        local s = stack[i]
        stack[i] = stack[i+1]
        stack[i+1] = s
      end
    end
  end
end

local function stackAdd(stack,data)
  local len = #stack
  --print('[CA] sch.stackAdd data:',data[1],data[2],data[3],data[4],data[5])
  --print('[CA] sch.stackAdd #stack:',len)
  if len == 0 then stack[1] = data
  elseif data[3] <= stack[len][3] then stack[len+1] = data
  else
    local t = data[3]
    for i = 1,len do
      if t > stack[i][3] then
        for j = len,i,-1 do stack[j+1] = stack[j] end
        stack[i] = data
        break
      end
    end
  end
end

function this.upday(stack,schlist)
  stack = {}
  for tid,t in pairs(schlist) do
    if not t.hm then
      local data = {
        [1] = t.func,
        [2] = t.args,
        [3] = 0,
        [4] = 0,
        [5] = t.period or 0,
        [6] = t.prio or 1,
      }
      stackAdd(stack,data)
    else
      for i = 1,#t.hm do
        local hm = t.hm[i]
        local data = {
          [1] = t.func,
          [2] = t.args,
          [3] = hm[1]*3600 + (hm[2] or 0)*60,
        }
        if hm[3] then data[4] = hm[3]*3600 + (hm[4] or 0)*60 else data[4] = 0 end
        data[5] = t.period or {}
        data[6] = t.prio or 1
        stackAdd(stack,data)
      end
    end
  end
end

function this.new(schlist)
  local stack = {}
  this.upday(stack,schlist)
  return stack
end

--[[  Stack values:
  [1] = function to call
  [2] = function args
  [3] = time event starts
  [4] = time event ends
  [5] = period
  [6] = priority
]]

function this:upd(stack)
  --if self.tx > CA.ctime then return 0 end
  local len = #stack   if len == 0 then return 0 end
  local s = stack[len]
  if s[4] > 0 and CA.day*86400 + s[2] < CA.ctime then
    stack[i] = nil                            -- time expired
  elseif CA.day*86400 + s[1] < CA.ctime then  -- time has come
    local cerr = stack[1](stack[2])           -- execute
    if cerr > 0 and stack[5][1] then
      stack[1] = CA.ctime + stack[5][1]*3600 + stack[5][2]*60
      stackUpd(stack,i)
    else
      stack[i] = nil
    end
  end
  return 0
end

return this

--[[
  -- teams creation
  -- waiting for shedule hour (obj.sch) has come
  --if obj.sch <= ghour then
    --obj.sch = 24
    --local gonexthour = true
local function hour(obj)

    for i = 1,#obj.sch do
      local s = obj.sch[i]
      if s.tnxt < CA.ctime then --s.hour == ghour and not s.min or s.min <= gmin
        local t = obj.team[s.teamid]
        if t.cerr == 0 and not CA.tma[t.id] then
          t.cerr = 1
          print()
          t.cerr = obj:create()
          if t.cerr == 0 then
            s.tct = CA.ctime -- team creation time
            s.tnxt = (CA.day+1)*86400 + s.hour*3600 + (s.min or 0)*60 -- team next creation time
          else
            print('[CA]',obj.id,t.id,'NOT CREATED, error #',t.cerr)
            CA.tma[t.id] = nil
          end
        end
      --else gonexthour = false
      end
    end
    --[[ searching for next minimal shedule hour
    if gonexthour then
      for i = 1,#obj.sch do
        local s = obj.sch[i]
        if s.hour > ghour and s.hour < obj.sch then obj.sch = s.hour end
      end
    end]]
--[[
  return 0
end

local function checkPL(ar)
  print('[CA] === START checkPL for',obj.id,'=== ')
  local dl = {}
  local dli = 0
  for paid,pa in pairs(obj.pl) do
    local id = pa.ref.id --CA.getId(pa.ref)
    if paid ~= id then
      if id:lower():find('imp') then
        print('[CA] ',paid,' ~= ',id,' ref CHANGED but OK')
      else
        print('[CA] ',paid,' ~= ',id,' ref DELETED ')
        dli = dli + 1
        dl[dli] = paid
        local p = obj.prof[pa.prof [1] ]
        local pidel = pa.prof[2] -- delete prof record
        local plen = #p
        if pidel < plen then
          for i = pidel+1,plen do p[i-1] = p[i] end
        elseif pidel > plen then
          print('[CA] ',obj.id,' [',pa.prof[1],'] INDEX ERROR ', plen,' ',pidel)
          break
        end
        p[plen] = nil
      end
    --else print('[CA] ',paid,' no changed ')
    end
  end
  for i = 1,dli do obj.pl[dl [i] ] = nil end
  print('[CA] === END checkPL === ')
end
]]