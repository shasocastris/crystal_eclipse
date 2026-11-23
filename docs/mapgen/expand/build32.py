from jgrid import row, emit, vanilla
V = vanilla('Route32', 10)
R = {0:'TTTT',1:'TTTT',2:',TTT',3:',,TT',4:'TTTT',5:'"",T',6:'""TT',7:'"",T',8:',,,T',9:',#TT',
     10:'TTTT',11:'TTTT'}
for y in range(12, 20): R[y] = 'TTTT'
R[20] = '^^^^'
for y in range(21, 45): R[y] = '~~~~'
R[22] = '~o~~'; R[26] = '~~o~'; R[32] = '~~~o'
for y in range(40, 45): R[y] = 'TTTT'
X1 = ['TT,"""""",,,TT',
      'T,""""(^^),,,T',
      'T,""""[~~],*,T',
      'T==="",,,,,,,T',
      'TT,,,,,,,,,TTT']
X2 = ['T.,,"""",,,,TT',
      'T.,"",cd,*,TTT',
      'T.,"",ef,,,TTT',
      'T.,,,,.,,,,TTT']
X4 = ['T,.,""",' + '[' + '~~~~~',
      'T,.,"""*' + '[' + '~~o~~',
      'T,......' + 'BBB' + '~~~',
      'T,.,,*,T' + '[' + '~~~~~']
rows = []
for y in range(45):
    if y == 12: rows += [row(s) for s in X1]
    if y == 20: rows += [row(s) for s in X2]
    if y == 35: rows += [row(s) for s in X4]
    rows.append(V[y] + row(R[y]))
assert len(rows) == 58, len(rows)
emit('route32_base.amap', rows, 14,
     '# Route 32 (expanded) base grid -- see route32.amap\nref Route32\n',
     'exit N 12 0\nexit RuinsGate 4 3\nexit PokeCenter 11 99\nexit UnionCave 6 105\nexit Cabin 13 55\n')
