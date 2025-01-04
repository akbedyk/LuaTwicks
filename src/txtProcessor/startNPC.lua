local txtp = require('txtProcessor.txtp')
local cstart = {
  [1] = {'out','return {\n'},
}
local cyc = {
  [1] = {'strfind','Record: NPC_ "',300},
  [2] = {'memsub','[^"]+',},
  [3] = {'sub','0x'},
  [4] = {'memsub','%d+',},
  [5] = {'formout','{recordID="%s",flags=%s,',{1,2}},
  [6] = {'memc'},
  [7] = {'strfind','NAME: ID:',2},
  [8] = {'memsub',},
  [9] = {'strfind','FNAM: Name:',2},
  [10] = {'memsub',},
  [11] = {'strfind','RNAM: Race:',2},
  [12] = {'memsub',},
  [13] = {'formout','id="%s",name="%s",race="%s",\n',{1,2,3}},
  [14] = {'memc'},
  [15] = {'strfind','CNAM: Class:',2},
  [16] = {'memsub',},
  [17] = {'strfind','Faction:',2},
  [18] = {'memsub',},
  [19] = {'strfind','Level:',5},
  [20] = {'memsub','%d+',},
  --[21] = {'strfind','Reputation:',3},
  --[22] = {'memsub','%d+',},
  [21] = {'strfind','FactionIndex:',5},
  [22] = {'memsub','%d+',},
  [23] = {'memsub','%d+',},
  [24] = {'formout','class="%s",fact="%s",lvl=%s,faci=%s,rank=%s,\n',{1,2,3,4,5}},
  [25] = {'memc'},
  [26] = {'strfind','AIDT:',300},
  [27] = {'memsub','%d+',},
  [28] = {'sub','Fight:'},
  [29] = {'memsub','%d+',},
  [30] = {'memsub','%d+',},
  [31] = {'memsub','%d+',},
  [32] = {'formout','hello=%s,fight=%s,flee=%s,alarm=%s},\n',{1,2,3,4}},
  [33] = {'memc'},
}
local cend = {
  [1] = {'out','}'},
}

local function doFiles(fin,fout)
  io.input(fin)
  io.output(fout)
  print('---=== txtp.start',fin,'===--- \n')
  txtp.doOnce(cstart)
  txtp.start(cyc)
  txtp.doOnce(cend)
  print('---=== txtp.end',fout,'===--- \n')
end

doFiles('txtProcessor/npc_morrowind.txt', 'txtProcessor/morrowind_npc.lua')
doFiles('txtProcessor/npc_tribunal.txt', 'txtProcessor/tribunal_npc.lua')
doFiles('txtProcessor/npc_bloodmoon.txt', 'txtProcessor/bloodmoon_npc.lua')
--doFiles('txtProcessor/npc_mfr.txt', 'txtProcessor/mfr_npc.lua')