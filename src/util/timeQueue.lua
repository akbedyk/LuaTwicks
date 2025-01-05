local ms = {}

local function forAll(callback)
	for i=1,#ms do
		callback(ms[i])
	end
end

local function add(msg)
	local size = #ms
	local mi = size+1
	local time = msg.t
	for i=1,size do
		if ms[i].t <= time then
			mi = i
			for j=size,i,-1 do
				ms[j+1] = ms[j]
			end
			break 
		end
	end
	ms[mi] = msg
end

local function del(indx)
	local size = #ms
	if indx > size or indx < 1 then return end
	for i=indx,size-1 do
		ms[i] = ms[i+1]
	end
	ms[size] = nil
end

local function forTimeDel(time, callback)
	local size = #ms
	for i=size,1,-1 do
		local m = ms[i]
		if m.t <= time then	callback(m) else
			for j=i+1,size do
				ms[j] = nil
			end
			break
		end
	end
end

return {
	add = add,
	del = del,
	forAll = forAll,
	forTimeDel = forTimeDel,
}