from jgrid import row, emit, vanilla
V = vanilla('Route36', 24)
MID = ['TT,,"",T', 'T,(^^),T', 'T,[~~],*', ',,,,,,,,', '........',
       ',*,,,"",', ',,=====,', 'T"""""",', 'TT"""",T']
EXT = ['TT', 'TT', 'TT', 'TT', '..', 'TT', 'TT', 'TT', 'TT']
rows = [row('TTTTTTT.TTTT' + 'T'*8 + 'T'*14), row('TTTTT,,.,,TT' + 'T'*8 + 'T'*14)]
for v in range(9):
    rows.append(V[v][:12] + row(MID[v]) + V[v][12:] + row(EXT[v]))
rows[10][4] = 0x02
rows[6][20] = rows[6][21] = 0x01
S = ['TTT,' + '"""""' + ',' + '(^^^)' + ',"",' + 'T',
     'TT,,' + '""""' + ',*' + '[~~~]' + '""",' + 'T',
     'T'*20]
for s in S: rows.append(row(s + 'T'*14))
emit('route36_base.amap', rows, 34,
     '# Route 36 (expanded) base grid -- see route36.amap\nref Route36\n',
     'exit E 67 12\nexit N 14 0\nexit ParkGate 6 12\nexit RuinsGate 51 17\n')
