local this = {}

local DHM = {}
local cday = 1
local chour = 1
local cmin = 1

function this.upd(ctime)
	cday = math.floor(ctime / 86400)
	chour = math.floor((ctime % 86400) / 3600)
	cmin = math.floor((ctime % 3600) / 60)
end

function this.clear()
	for day = 1,31 do
		local d = {}
		DHM[day] = d
		for hour=1,23 do
			d[hour] = {	{},	}
		end
	end
end

this.clear()

function this.addTask(task)
	local id = task.id
	local ds = task.dhmStart
	local h = DHM[ds.day or cday][ds.hour or chour]
	local min = ds.min or cmin
	local m = h[min]
	if m[id] then
		for i = min,60 do
			m = h[i]
			if not m[id] then m[id] = task return i end
		end
		print('[CA] taskDayHourMin.addTask error: NOT CORRECT',id,'task min =',min)
	else
		m[id] = task
	end
end

function this.delTask(id,dhm)
	if not id or not dhm then
		print('[CA] taskDayHourMin.delTask error: id',id,'dhm',dhm)
		return
	end
	DHM[dhm.day or cday][dhm.hour or chour][dhm.min or cmin][id] = nil
end

function this.getTasks(dhm,id)
	local h = DHM[dhm.day or cday][dhm.hour or chour]
	if dhm.min then
		local m = h[dhm.min]
		if m then 
			if id then return m[id]
			else return m
			end
		end
	elseif id then
		local r = {}
		for i=1,60 do
			local m = h[i]
			if m and m[id] then r[i] = m[id] end
		end
		return r
	else return h
	end
	return nil
end

--function this.a() end

return this