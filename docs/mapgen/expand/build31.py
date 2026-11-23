from jgrid import row, emit
S = [
'TTTTTTTTTTT'+'TTTTT'+'TTTTT'+'TLMMMMJT'+'T',
'TTTTTTTT(^^'+'^)TTT'+'TTTTT'+'TLMMMMJT'+'T',
'TTTT,*,,[~~'+'~}^^)'+'T,#,,'+'TLMMMMJ,'+'T',
'TT,,,S,,[~~'+'~~~~]'+',,*,,'+'TbmCmmn,'+'T',
'ghT,,,,,,,,'+',[~~]'+',*,,,'+'o,S.,*,,'+'T',
'ijk........'+'.....'+'.....'+'....,,,,'+'T',
'TTT======,,'+'qwwwp'+',,.,,'+',,,,,,,T'+'T',
'TTT"""""",,'+',,,,,'+',,.,T'+'T,""""TT'+'T',
'TT,""""""",'+',,*,,'+',,.,T'+'T,"""",T'+'T',
'TT,,""",,,,'+'qwwwp'+',,.,,'+',,"""",T'+'T',
'TT,========'+',#,,,'+',,.,,'+',,,,,,,T'+'T',
'TT"""""""",'+'""",,'+'#,.,T'+'TT,,*,TT'+'T',
'TTT""""",TT'+'T"",,'+',,.,T'+'TTT,,TTT'+'T',
'TTTTTTTTTTT'+'TTTTT'+'TT.TT'+'TTTTTTTT'+'T',
]
emit('route31_base.amap', [row(s) for s in S], 30,
     '# Route 31 (expanded) base grid -- see route31.amap\nref Route31\n',
     'exit S 36 27\nexit VioletGate 4 10\nexit DarkCave 48 7\n')
