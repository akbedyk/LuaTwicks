local txtp = require('txtProcessor.txtp')
local cstart = {
  [1] = {'out','return {\n'},
}
local cyc = {
  [1] = {'strfind','Record: PGRD "',5},
  [2] = {'memsub','[^"]+',},
  [3] = {'strfind','DATA:',5},
  [4] = {'memsub','%d+',},
  [5] = {'memsub','%d+',},
  [6] = {'formout','{x=%s,y=%s,name="%s",pnt={\n   ',{2,3,1}},
  [7] = {'memc'},
  [8] = {'strfind','PGRP: Points:',2},
  [9] = {'cycle','while',{
      [1] = {'strfind','x:',1},
      [2] = {'memsub','%d+',1},
      [3] = {'memsub','%d+',2},
      [4] = {'memsub','%d+',3},
      [5] = {'formout','{%s,%s,%s},',{1,2,3}},
      [6] = {'memc'},
    },
  },
  [10] = {'out','\n  },'},
  [11] = {'strfind','PGRC: Connections:'},
  [12] = {'out','cn={',},
  [13] = {'cycle','while',{
      [1] = {'strfind','->'},
      [2] = {'cycle','while',{
        [1] = {'memsub','%d+'},
        },
      },
      [3] = {'outall','{','},'},
      [4] = {'memc'},
    },
  },
  [14] = {'out','\n  }},\n'},
}
local cend = {
  [1] = {'out','\n  }},\n}'},
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

doFiles('Data/_PGRD_morrowind.txt', 'txtProcessor/morrowind_pgrd.lua')
doFiles('Data/_PGRD_tribunal.txt', 'txtProcessor/tribunal_pgrd.lua')
doFiles('Data/_PGRD_bloodmoon.txt', 'txtProcessor/bloodmoon_pgrd.lua')
doFiles('Data/_PGRD_mfr.txt', 'txtProcessor/mfr_pgrd.lua')