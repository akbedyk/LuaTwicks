local txtp = require('txtProcessor.txtp')
local cstart = {
  [1] = {'out','return {\n'},
}
local cyc = {
  [1] = {'mem',t.x,1},
  [2] = {'mem',t.y,2},
  [3] = {'mem',t.name,3},
  [4] = {'formout','{x=%s,y=%s,name="%s",pnt={\n ',{1,2,3}},
  [5] = {'memc'},
  [6] = {'cycle',t.pnt,{
      [1] = {'mem',1,1},
      [2] = {'mem',2,2},
      [3] = {'mem',3,3},
      [4] = {'formout','{%s,%s,%s},',{1,2,3}},
    },
  },
  [7] = {'out','\n},cn={'},
  [8] = {'cycle',t.cn,{
      [1] = {'mem',1,1},
      [2] = {'mem',2,2},
      [3] = {'mem',3,3},
      [4] = {'forout','{%s,%s,%s},',{1,2,3}},
    },
  },
  [9] = {'out','\n },\n},',},
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
