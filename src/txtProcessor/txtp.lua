local txtp = {} 		-- text processor
local str           -- current document string
local	csi = 0 			-- current string index
local ci = 0 				-- currend string start symbol index
local op1,op2,op3		-- operator 1,2,3
local cf = true			-- cycle flag
local	md = {} 			-- memory d
local	mdl = 0       -- memory d length
local sfmax = 0     -- string find maximum
local sfDefault = 1 -- string find default

local cerr = 0 			-- current error
local cerrcode = {
 [0] = 'OK',
 [1] = 'com error',
 [3] = 'not known code operation',
 [4] = 'str not found',
 [5] = 'sub not found',
 [6] = 'memsub not found',
}

function txtp.exit()
	str = nil
	return 0
end

function txtp.cret()
	ci = 1
	return 0
end

function txtp.strnext()
	str = io.read(); csi = csi + 1; ci = 1
	return 0
end

function txtp.out()
	io.write(op2)
	return 0
end

function txtp.outall()
	local mdout = ''
	for i = 1,mdl do
		mdout = mdout..md[i]..','
	end
	io.write(op2..mdout..op3)
	return 0
end

local function getmd(list)
	local l = #list
	if l == 1 then return md[list[1]]
	elseif l == 2 then return md[list[1]],md[list[2]]
	elseif l == 3 then return md[list[1]],md[list[2]],md[list[3]]
	elseif l == 4 then return md[list[1]],md[list[2]],md[list[3]],md[list[4]]
	elseif l == 5 then return md[list[1]],md[list[2]],md[list[3]],md[list[4]],md[list[5]]
	elseif l == 6 then return md[list[1]],md[list[2]],md[list[3]],md[list[4]],md[list[5]],md[list[6]]
	elseif l == 7 then return md[list[1]],md[list[2]],md[list[3]],md[list[4]],md[list[5]],md[list[6]],md[list[7]]
	else
		print('[txtp] error: too big getmd(list):',l)
		return ''
	end
end

function txtp.formout()
	io.write(op2:format(getmd(op3)))
	return 0
end

function txtp.strfind()
	sfmax = csi + (op3 or sfDefault)
	while str do
		local b,e = str:find(op2,ci)
		if b then ci=e+1 return 0 end
		if csi >= sfmax then
			print('[txtp] warninig: document string #',csi,'break strfind',op2,'(max)',op3 or sfiDefault)
			cf = false
			return 4
		end
		txtp.strnext()
	end
	return 0
end

function txtp.sub()
	local b,e = str:find(op2,ci)
	if b then	ci = e+1
	else cf = false return 5
	end
	return 0
end

function txtp.memsub()
	if not op2 then
		mdl = mdl + 1
		md[mdl] = str:sub(ci)
		return 0
	end
	local b,e = str:find(op2,ci)
	if b then
		mdl = mdl + 1
		md[mdl] = str:sub(b,e)
		ci = e+1
	else cf = false return 6
	end
	return 0
end

function txtp.memc()
	mdl = 0
	return 0
end

function txtp.doOnce(toc)
	if not toc or type(toc) ~= 'table' then print('[txtp] error: table of commands') return 1 end
  txtp.strnext()
  local cmd,func
  for toci = 1,#toc do
  	cmd = toc[toci]
  	if cmd then
  		op1 = cmd[1]
  		op2 = cmd[2]
  		op3 = cmd[3]
  		func = txtp[op1]
  		if not func then print('[txtp] error: not known code operation',toci) return 3 end
  		cerr = func(); --print('[txtp] cmd:',op1,'#',toci,'op2:',op2)
  		if cerr > 0 then print('[txtp] op1:',op1,'#',toci,'op2:',op2,'error: '..cerrcode[cerr],'str:',str); cerr = 0 end
  	end
  end
  return 0
 end

function txtp.cycle()
	local toc = op3
  local toci = 1
  local cmd,func
  while cf and str do
  	cmd = toc[toci]
  	if cmd then
  		op1 = cmd[1]
  		op2 = cmd[2]
  		op3 = cmd[3]
  		func = txtp[op1]
  		if not func then print('[txtp] error: not known code operation') return 3 end
  		cerr = func(); --print('[txtp] cmd:',op1,'#',toci,'op2:',op2)
  		if cerr > 0 then print('[txtp] op1:',op1,'#',toci,'op2:',op2,'error:',cerr,'str:',str); cerr = 0 end
  		toci = toci + 1
  	else toci = 1
  	end
  end
  cf = true
  return 0
end

function txtp.start(toc)
	if not toc or type(toc) ~= 'table' then print('[txtp] error: table of commands') return 1 end
  txtp.strnext()
  op3 = toc
  txtp.cycle()
  return 0
end

return txtp