globals [payoff-matrix strategy-colors strategies colors indices score-table proportions ruis random-action]
patches-own [neighborhood strategy mean-total-payoff]

to calculate-score-table

end

to-report score-row-for [ s1 ]
  report map [ [s2] -> score-entry-for s1 s2 ] strategies
end

to-report score-entry-for [s1 s2]
  report mean n-values restarts [score-for s1 s2]
end


to-report score-for [s1 s2]
  let my-history []
  let your-history []
  let my-total-payoff 0
  repeat rounds [
    let my-action play s1 my-history your-history
    let your-action play s2 your-history my-history
    let my-payoff item your-action (item my-action payoff-matrix)
    set my-total-payoff my-total-payoff + my-payoff
    set my-history fput my-action my-history ; most recent actions go first
    set your-history fput your-action your-history;
  ]
  report my-total-payoff
end

to-report play [ some-strategy my-history your-history ]
  report ifelse-value (random-float 1.0 < noise)
  [random-action] [runresult (word some-strategy " my-history your-history") ]
end


to setup
  set payoff-matrix (list (list CC-payoff-reward     CD-payoff-sucker    )
                          (list DC-payoff-temptation DD-payoff-punishment))
  set score-table map [ [s] -> score-row-for s ] strategies
  set strategy-colors [
    ;["cooperation" black]
    ["always-cooperate" green]
    ["always-defect" red]
    ["play-randomly" grey]
    ["unforgiving" 102]
    ["tit-for-tat" violet]
    ["pessimistic-tit-for-tat" magenta]
    ["forgiving-tit-for-tat" 13]
    ["tit-for-two-tats" 23]
    ["majority" pink]
    ["eatherly" blue]
    ["Joss-5%" orange]
    ["Pavlov" brown]

  ]

  set strategies    map [ [x] -> item 0 x ] strategy-colors ; strip strategies from strategy-colors
  set colors        map [ [x] -> item 1 x ] strategy-colors ; strip colors     from strategy-colors
  set indices       n-values length strategies [ [x] -> x ] ; 0, 1, .., n-1 where n is number of strategies
  ask patches [ set neighborhood (patch-set self neighbors) ] ; 8 neighbors and myself
  initialise-run
calculate-score-table
end

to initialise-run
  clear-output
  clear-all-plots
  reset-ticks

  let strategy-bag map [ [i] -> rijtje i (1000 * run-result (word "start-" item i strategies)) ] indices
; strategy-bag now looks like [[0 0 0 ...] [1 1 ...] [2 2 2 2 2 ...] ...]
; the length of each sub-list corresponds to the start-proportion of that strategy

let strategy-pool reduce [ [x y] -> sentence x y ] strategy-bag
; strategy-pool now looks like [0 0 0 ... 1 1 ... 2 2 2 2 2 ... ...]
; and contains about 1000 indices

ask patches [
 set strategy one-of strategy-pool  ; "strategy" is a natural number; "one-of" is a Netlogo primitive
 set pcolor item strategy colors    ; give patch the color of the strategy it it assigned to
]
  foreach indices [ [i] ->
    create-temporary-plot-pen item i strategies
    set-plot-pen-color item i colors
  ]
end

to normalize-strategy-ratios
  let sum-of-strategies sum map [ [s] -> run-result (word "start-" s) ] strategies
  if abs(sum-of-strategies - 1) <= 0.001 [ stop ] ; already normalized
  foreach strategies [ [s] ->
    run (word "set start-" s " precision (start-" s " / sum-of-strategies) 2")
  ]
end

to-report rijtje [ x n ] ; e.g., rijtje 7 5 yields [7 7 7 7 7]
  report n-values n [ x ]
end

; strategy pool is a list of strategies where the multiplicity of every strategy is in accordance
; with its start ratio; this makes for a cheap and well-known way to pick elements proportionally

;;PER STRATEGIE
to-report cooperation [ my-history your-history ]
end
to-report always-cooperate [ my-history your-history ]
report 0
end
to-report always-defect [ my-history your-history ]
 report 1
end
to-report play-randomly [ my-history your-history ]
  report one-of [0 1]
end
to-report unforgiving [ my-history your-history ]
  ;ifelse my-history + your-history = 0 [report 0][report 1];; pas dit aan
  report 0
end
to-report tit-for-tat [ my-history your-history ]
  ifelse rounds = 0 [report 0][ifelse your-history = 0 [report 0][report 1]]
end
to-report pessimistic-tit-for-tat [ my-history your-history ]
  ifelse rounds = 0 [report 1][ifelse your-history = 0 [report 0][report 1]]
end
to-report forgiving-tit-for-tat [ my-history your-history ]
  ;ifelse rounds = 0 [report 0][ifelse your-history = 0 [ifelse my-action of neighb
      ;[my-history = 0] >= 5 ][report 0][report 1]][report 1]]  NOG NAAR KIJKEN

  report 0
end
to-report tit-for-two-tats [ my-history your-history ]
 ;let tftt 0
  ;ifelse rounds = 0[report 0][
  ;  while [your-history = 1]
   ; [ifelse tftt >= 2 [report 1][report 0]
   ;   set tftt tftt + 1]]; NOG NAAR KIJKEN
  report 1
end
to-report majority [ my-history your-history ]
  ;;ifelse count neighbors with [my-history = 0] >= 5 [report 0][report 1]; WEER PATCH ONLY
  report 0
end
to-report eatherly [ my-history your-history ]
  report 0
end
to-report Joss-5% [ my-history your-history ]
  report 1
end
to-report Pavlov [ my-history your-history ]
  ifelse rounds = 0[report 0][ifelse your-history = 1 [ifelse my-history = 0 [report 1][report 0]][report my-history]]
end
@#$#@#$#@
GRAPHICS-WINDOW
280
45
709
475
-1
-1
12.76
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
105
80
277
113
strategies-to-pit
strategies-to-pit
0
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
105
115
277
148
restarts
restarts
0
100
51.0
1
1
NIL
HORIZONTAL

SLIDER
105
150
277
183
rounds
rounds
0
1000
50.0
1
1
NIL
HORIZONTAL

SLIDER
105
185
277
218
noise
noise
0
1
0.15
0.05
1
NIL
HORIZONTAL

BUTTON
85
220
148
253
reset
reset
NIL
1
T
OBSERVER
NIL
R
NIL
NIL
1

BUTTON
150
220
213
253
step
step
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
215
220
278
253
go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
105
255
277
288
CC-payoff-reward
CC-payoff-reward
0
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
105
290
277
323
CD-payoff-sucker
CD-payoff-sucker
-5
5
0.0
1
1
NIL
HORIZONTAL

SLIDER
105
325
277
358
DC-payoff-temptation
DC-payoff-temptation
0
7
5.0
1
1
NIL
HORIZONTAL

SLIDER
105
360
277
393
DD-payoff-punishment
DD-payoff-punishment
-5
5
1.0
1
1
NIL
HORIZONTAL

BUTTON
30
415
107
448
strategy
strategy
NIL
1
T
OBSERVER
NIL
1
NIL
NIL
1

BUTTON
110
415
207
448
cooperation
cooperation
NIL
1
T
OBSERVER
NIL
2
NIL
NIL
1

BUTTON
210
415
277
448
payoff
payoff
NIL
1
T
OBSERVER
NIL
3
NIL
NIL
1

TEXTBOX
85
395
305
421
Display strategy, cooperation or payoff
11
0.0
1

BUTTON
215
45
277
78
recalc
calculate-score-table
NIL
1
T
OBSERVER
NIL
C
NIL
NIL
1

BUTTON
150
45
213
78
setup
setup
NIL
1
T
OBSERVER
NIL
X
NIL
NIL
1

SWITCH
45
45
148
78
pit?
pit?
0
1
-1000

PLOT
710
45
1415
285
Proportions
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"cooperation" 1.0 0 -16777216 true "" "plot count turtles"
"always-cooperate" 1.0 0 -10899396 true "" ""
"always-defect" 1.0 0 -2674135 true "" ""
"play-randomly" 1.0 0 -7500403 true "" ""
"unforgiving" 1.0 0 -15390905 true "" ""
"tit-for-tat" 1.0 0 -8630108 true "" ""
"pessimistic-tit-for-tat" 1.0 0 -5825686 true "" ""
"forgiving-tit-for-tat" 1.0 0 -8053223 true "" ""
"tit-for-two-tats" 1.0 0 -6995700 true "" ""
"majority" 1.0 0 -2064490 true "" ""
"eatherly" 1.0 0 -13345367 true "" ""
"Joss-5%" 1.0 0 -955883 true "" ""
"Pavlov" 1.0 0 -6459832 true "" ""

SLIDER
710
285
900
318
start-always-cooperate
start-always-cooperate
0
1
0.17
0.01
1
NIL
HORIZONTAL

OUTPUT
1090
285
1415
495
11

SLIDER
710
320
900
353
start-always-defect
start-always-defect
0
1
0.32
0.01
1
NIL
HORIZONTAL

SLIDER
710
355
900
388
start-play-randomly
start-play-randomly
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
710
390
900
423
start-unforgiving
start-unforgiving
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
710
425
900
458
start-tit-for-tat
start-tit-for-tat
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
710
460
900
493
start-tit-for-two-tats
start-tit-for-two-tats
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
902
285
1087
318
start-pessimistic-tit-for-tat
start-pessimistic-tit-for-tat
0
1
0.99
0.01
1
NIL
HORIZONTAL

SLIDER
902
320
1087
353
start-forgiving-tit-for-tat
start-forgiving-tit-for-tat
0
1
0.99
0.01
1
NIL
HORIZONTAL

SLIDER
905
355
1085
388
start-majority
start-majority
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
905
390
1085
423
start-eatherly
start-eatherly
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
902
425
1087
458
start-Joss-5%
start-Joss-5%
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
902
460
1087
493
start-Pavlov
start-Pavlov
0
1
1.0
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
