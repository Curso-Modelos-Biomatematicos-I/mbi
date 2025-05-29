breed [ ratones raton ]
breed [ iconos icono ]
breed [ etiquetas etiqueta ]

globals [
  celdas_generacion_1
  celdas_generacion_2
  celdas_reproduccion

  ratones_parental

  ratones_posible_descendencia

  tamanio_pob

  frec_homo_dom_p
  frec_hete_p
  frec_homo_rec_p

  frec_ale_dom_p
  frec_ale_rec_p

  frec_negros_p
  frec_cafes_p

  frec_homo_dom_d
  frec_hete_d
  frec_homo_rec_d

  frec_ale_dom_d
  frec_ale_rec_d

  frec_negros_d
  frec_cafes_d

  color_resaltar

  nuevos_progenitores

  progenitor_1
  progenitor_2
]

ratones-own [
  genotipo
]


to inicializar
  clear-all

  ;; Dividir mundo
  set celdas_generacion_1 patches with [pxcor < 25]
  set celdas_generacion_2 patches with [pxcor >= 35]
  set celdas_reproduccion patches with [pxcor >= 25 and pxcor < 35]
  colorear_celdas

  ;; Incluir íconos decorativos

  create-iconos 1 [
    setxy 27.5 14.5
    set heading 90
    set color black
    pendown
    let step 6
    fd step rt 90 fd step rt 90 fd step rt 90 fd step rt 90 fd step / 2 rt 90 fd step rt 90 fd step / 2 rt 90 fd step / 2 rt 90 fd step
    die
  ]
  create-iconos 1 [
    set shape "x"
    setxy 29.5 21
    set color white
    set size 2
  ]

  ;; Crear poblaciones de ratones
  set tamanio_pob homocigotos_dominantes + homocigotos_recesivos + heterocigotos
  let max_pob count celdas_generacion_1
  if tamanio_pob > max_pob [
    user-message (word "Estás creando un total de " tamanio_pob " individuos. El simulador solo permite crear como máximo " max_pob " individuos. Por favor disminuye el número de individuos y vuelve a inicializar el modelo")
    stop
  ]
  set-default-shape ratones "mouse side"
  create-ratones homocigotos_dominantes [
    set genotipo "AA"
  ]
  create-ratones homocigotos_recesivos [
    set genotipo "aa"
  ]
  create-ratones heterocigotos [
    set genotipo "Aa"
  ]

  ask ratones [
    colorear_raton
    move-to one-of celdas_generacion_1 with [not any? ratones-here]
  ]

  actualizar_ratones_parental

  calcular_frecuencias_p

  set color_resaltar yellow
  set nuevos_progenitores false

  init_graficas
  reset-ticks
end

to actualizar_ratones_parental
  set ratones_parental ratones-on celdas_generacion_1
end

to colorear_raton
  (ifelse
      genotipo = "AA" or genotipo = "Aa" or genotipo = "aA" [ set color brown ]
      genotipo = "aa" [ set color black ]
  )
end

to colorear_celdas
  ask celdas_reproduccion [ set pcolor gray + 3 ]
  ask celdas_generacion_1 [ set pcolor white ]
  ask celdas_generacion_2 [ set pcolor white ]
  ask etiquetas [ die ]
end

to seleccionar_progenitores
  if count ratones-on celdas_generacion_2 >= tamanio_pob [ ejecutar_acciones_nueva_generacion ]
  set ratones_posible_descendencia nobody
  ask ratones-on celdas_reproduccion [ die ]
  colorear_celdas

  set progenitor_1 one-of ratones_parental
  ask progenitor_1 [
    set progenitor_2 one-of other ratones_parental
  ]
  ask progenitor_1 [
    set pcolor color_resaltar
    hatch 1 [
      setxy 27  21
      set size 3
    ]
  ]
  ask progenitor_2 [
    set pcolor color_resaltar
    hatch 1 [
      setxy 32 21
      set size 3
    ]
  ]

  agregar_etiquetas_genotipo_padres [genotipo] of progenitor_1 [genotipo] of progenitor_2
end

to calcular_posible_descendencia

  let gameto_1 substring ([genotipo] of progenitor_1) 0 1
  let gameto_2 substring ([genotipo] of progenitor_1) 1 2
  let gameto_3 substring ([genotipo] of progenitor_2) 0 1
  let gameto_4 substring ([genotipo] of progenitor_2) 1 2

  agrega_etiquetas_gametos gameto_1 gameto_2 gameto_3 gameto_4

  let xcors (list 29 32)
  let ycors (list 13 10)
  create-ratones 1 [
    set genotipo (word gameto_1 gameto_3)
    setxy (item 0 xcors) (item 0 ycors)
    agregar_etiquetas_cigoto genotipo xcor (ycor + 1)
    colorear_raton
    set ratones_posible_descendencia (turtle-set ratones_posible_descendencia self)
  ]
  create-ratones 1 [
    set genotipo (word gameto_1 gameto_4)
    setxy (item 1 xcors) (item 0 ycors)
    agregar_etiquetas_cigoto genotipo xcor (ycor + 1)
    colorear_raton
    set ratones_posible_descendencia (turtle-set ratones_posible_descendencia self)
  ]
  create-ratones 1 [
    set genotipo (word gameto_2 gameto_3)
    setxy (item 0 xcors) (item 1 ycors)
    agregar_etiquetas_cigoto genotipo xcor (ycor + 1)
    colorear_raton
    set ratones_posible_descendencia (turtle-set ratones_posible_descendencia self)
  ]
  create-ratones 1 [
    set genotipo (word gameto_2 gameto_4)
    setxy (item 1 xcors) (item 1 ycors)
    agregar_etiquetas_cigoto genotipo xcor (ycor + 1)
    colorear_raton
    set ratones_posible_descendencia (turtle-set ratones_posible_descendencia self)
  ]

  set nuevos_progenitores true
end

to seleccionar_descendencia
  if not nuevos_progenitores [
    user-message "No has seleccionado un nuevo par de progenitores."
    stop
  ]
  let descendencia one-of ratones_posible_descendencia
  ask descendencia [
    set pcolor color_resaltar
    ask neighbors [ set pcolor color_resaltar]
    hatch 1 [
      move-to one-of celdas_generacion_2 with [ not any? other ratones-here ]
      set pcolor color_resaltar
    ]
  ]
  set nuevos_progenitores false
end

to ejecutar_evento_reproduccion
  seleccionar_progenitores
  calcular_posible_descendencia
  seleccionar_descendencia
end

to ejecutar_acciones_nueva_generacion
  reiniciar_generaciones
  colorear_celdas
  actualizar_ratones_parental
  calcular_frecuencias_d
  calcular_frecuencias_p
end

to ejecutar_generacion
  if count ratones-on celdas_generacion_2 >= tamanio_pob [ ejecutar_acciones_nueva_generacion ]
  while [count ratones-on celdas_generacion_2 < tamanio_pob] [ ejecutar_evento_reproduccion ]
  calcular_frecuencias_d
  calcular_frecuencias_p
  tick
  graficar
end

to calcular_frecuencias_p
  set frec_homo_dom_p count ratones_parental with [genotipo = "AA"] / tamanio_pob
  set frec_hete_p count ratones_parental with [genotipo = "Aa" or genotipo ="aA"] / tamanio_pob
  set frec_homo_rec_p count ratones_parental with [genotipo = "aa"] / tamanio_pob

  set frec_ale_dom_p ((2 * count ratones_parental with [genotipo = "AA"]) + count ratones_parental with [genotipo = "Aa" or genotipo ="aA"]) / (2 * tamanio_pob)
  set frec_ale_rec_p ((2 * count ratones_parental with [genotipo = "aa"]) + count ratones_parental with [genotipo = "Aa" or genotipo ="aA"]) / (2 * tamanio_pob)
  set frec_negros_p count ratones_parental with [color = black ] / tamanio_pob
  set frec_cafes_p count ratones_parental with [color = brown ] / tamanio_pob
end

to reiniciar_generaciones
  ask ratones-on celdas_generacion_1 [ die ]
  ask ratones-on celdas_reproduccion [ die ]
  ;; se mueven los ratones de la descendencia a la zona de la parental
  ask ratones-on celdas_generacion_2 [ set xcor xcor - 35 ]
end

to calcular_frecuencias_d
  let ratones_descendencia ratones-on celdas_generacion_2
  set frec_homo_dom_d count ratones_descendencia with [genotipo = "AA"] / tamanio_pob
  set frec_hete_d count ratones_descendencia with [genotipo = "Aa" or genotipo ="aA"] / tamanio_pob
  set frec_homo_rec_d count ratones_descendencia with [genotipo = "aa"] / tamanio_pob

  set frec_ale_dom_d ((2 * count ratones_descendencia with [genotipo = "AA"]) + count ratones_descendencia with [genotipo = "Aa" or genotipo ="aA"]) / (2 * tamanio_pob)
  set frec_ale_rec_d ((2 * count ratones_descendencia with [genotipo = "aa"]) + count ratones_descendencia with [genotipo = "Aa" or genotipo ="aA"]) / (2 * tamanio_pob)
  set frec_negros_d count ratones_descendencia with [color = black ] / tamanio_pob
  set frec_cafes_d count ratones_descendencia with [color = brown ] / tamanio_pob
end

to init_graficas
  set-current-plot "frecuencias alélicas"
  set-current-plot-pen "f(A) (dom)"
  plotxy 0 frec_ale_dom_p
  set-current-plot-pen "f(a) (rec)"
  plotxy 0 frec_ale_rec_p

  set-current-plot "frecuencias génicas"
  set-current-plot-pen "f(AA) (homo dom)"
  plotxy 0 frec_homo_dom_p
  set-current-plot-pen "f(aa) (homo rec)"
  plotxy 0 frec_homo_rec_p
  set-current-plot-pen "f(Aa) (hete)"
  plotxy 0 frec_hete_p

  set-current-plot "frecuencia fenotípica"
  set-current-plot-pen "negros"
  plotxy 0 frec_negros_p
  set-current-plot-pen "cafes"
  plotxy 0 frec_cafes_p
end

to graficar
  set-current-plot "frecuencias alélicas"
  set-current-plot-pen "f(A) (dom)"
  plotxy ticks frec_ale_dom_d
  set-current-plot-pen "f(a) (rec)"
  plotxy ticks frec_ale_rec_p

  set-current-plot "frecuencias génicas"
  set-current-plot-pen "f(AA) (homo dom)"
  plotxy ticks frec_homo_dom_d
  set-current-plot-pen "f(aa) (homo rec)"
  plotxy ticks frec_homo_rec_d
  set-current-plot-pen "f(Aa) (hete)"
  plotxy ticks frec_hete_d

  set-current-plot "frecuencia fenotípica"
  set-current-plot-pen "negros"
  plotxy ticks frec_negros_d
  set-current-plot-pen "cafes"
  plotxy ticks frec_cafes_d
end

to agregar_etiquetas_genotipo_padres [genotipo_hembra genotipo_macho]
  create-etiquetas 1 [
    init_etiqueta
    set label genotipo_macho
    setxy 27 23
  ]
  create-etiquetas 1 [
    init_etiqueta
    set label genotipo_hembra
    setxy 32 23
  ]
end

to init_etiqueta
  set shape "nada"
  set label-color black
end

to agrega_etiquetas_gametos [ g1 g2 g3 g4 ]
  create-etiquetas 1 [
    init_etiqueta
    set label g1
    setxy 26 13
  ]
  create-etiquetas 1 [
    init_etiqueta
    set label g2
    setxy 26 10
  ]
  create-etiquetas 1 [
    init_etiqueta
    set label g3
    setxy 29 16
  ]
  create-etiquetas 1 [
    init_etiqueta
    set label g4
    setxy 32 16
  ]
end

to agregar_etiquetas_cigoto [etiq corx cory ]
  hatch-etiquetas 1 [
    init_etiqueta
    set label etiq
    setxy corx cory
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
257
10
1191
404
-1
-1
15.433333333333334
1
12
1
1
1
0
1
1
1
0
59
0
24
0
0
1
ticks
30.0

BUTTON
6
124
251
162
NIL
inicializar
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
184
251
217
NIL
seleccionar_progenitores
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
254
251
287
NIL
seleccionar_descendencia
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
10
251
43
homocigotos_dominantes
homocigotos_dominantes
0
400
200.0
10
1
NIL
HORIZONTAL

SLIDER
5
44
252
77
homocigotos_recesivos
homocigotos_recesivos
0
400
200.0
10
1
NIL
HORIZONTAL

SLIDER
5
79
252
112
heterocigotos
heterocigotos
0
400
200.0
10
1
NIL
HORIZONTAL

BUTTON
6
379
251
417
NIL
ejecutar_generacion
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
319
251
358
NIL
ejecutar_evento_reproduccion
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
439
251
478
simular varias generaciones
ejecutar_generacion
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
260
450
330
495
f(AA)
frec_homo_dom_p
2
1
11

MONITOR
330
450
400
495
f(Aa)
frec_hete_p
2
1
11

MONITOR
400
450
470
495
f(aa)
frec_homo_rec_p
2
1
11

MONITOR
260
405
330
450
f(A)
frec_ale_dom_p
2
1
11

MONITOR
330
405
400
450
f(a)
frec_ale_rec_p
2
1
11

PLOT
1191
10
1570
182
frecuencias alélicas
t
frecuencia
0.0
3.0
0.0
1.0
true
true
"" ""
PENS
"f(A) (dom)" 1.0 0 -13791810 true "" ""
"f(a) (rec)" 1.0 0 -2674135 true "" ""

PLOT
1192
182
1570
356
frecuencias génicas
t
frecuencia
0.0
3.0
0.0
1.0
true
true
"" ""
PENS
"f(AA) (homo dom)" 1.0 0 -8630108 true "" ""
"f(Aa) (hete)" 1.0 0 -5825686 true "" ""
"f(aa) (homo rec)" 1.0 0 -2064490 true "" ""

PLOT
1192
356
1571
528
frecuencia fenotípica
t
frecuencia
0.0
3.0
0.0
1.0
true
true
"" ""
PENS
"negros" 1.0 0 -16777216 true "" ""
"cafes" 1.0 0 -6459832 true "" ""

MONITOR
260
495
325
540
f(negros)
frec_negros_p
2
1
11

MONITOR
325
495
395
540
f(cafes)
frec_cafes_p
2
1
11

MONITOR
800
405
870
450
f(A)
frec_ale_dom_d
2
1
11

MONITOR
870
405
940
450
f(a)
frec_ale_rec_d
2
1
11

MONITOR
800
450
870
495
f(AA)
frec_homo_dom_d
2
1
11

MONITOR
870
450
940
495
f(Aa)
frec_hete_d
2
1
11

MONITOR
940
450
1010
495
f(aa)
frec_homo_rec_d
2
1
11

MONITOR
800
495
870
540
f(negros)
frec_negros_d
2
1
11

MONITOR
870
495
940
540
f(cafes)
frec_cafes_d
2
1
11

TEXTBOX
260
550
410
568
PROGENITORES
12
0.0
1

TEXTBOX
805
545
955
563
DESCENDENCIA
12
0.0
1

MONITOR
260
570
317
615
N
tamanio_pob
0
1
11

MONITOR
805
570
862
615
N
count ratones-on celdas_generacion_2
0
1
11

BUTTON
6
219
251
252
NIL
calcular_posible_descendencia
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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

hembra
false
0
Circle -1 true false 74 14 152
Circle -7500403 true true 108 48 85
Rectangle -1 true false 135 150 165 285
Rectangle -1 true false 90 195 210 225

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

macho
false
0
Circle -1 true false 59 89 152
Circle -7500403 true true 93 123 85
Rectangle -1 true false 255 15 285 105
Rectangle -1 true false 195 15 270 45
Polygon -1 true false 255 30 165 105 195 135 255 75 270 45 270 15

mouse side
false
0
Polygon -7500403 true true 38 162 24 165 19 174 22 192 47 213 90 225 135 230 161 240 178 262 150 246 117 238 73 232 36 220 11 196 7 171 15 153 37 146 46 145
Polygon -7500403 true true 289 142 271 165 237 164 217 185 235 192 254 192 259 199 245 200 248 203 226 199 200 194 155 195 122 185 84 187 91 195 82 192 83 201 72 190 67 199 62 185 46 183 36 165 40 134 57 115 74 106 60 109 90 97 112 94 92 93 130 86 154 88 134 81 183 90 197 94 183 86 212 95 211 88 224 83 235 88 248 97 246 90 257 107 255 97 270 120
Polygon -16777216 true false 234 100 220 96 210 100 214 111 228 116 239 115
Circle -16777216 true false 246 117 20
Line -7500403 true 270 153 282 174
Line -7500403 true 272 153 255 173
Line -7500403 true 269 156 268 177

nada
true
0

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

suit heart
false
0
Circle -7500403 true true 135 43 122
Circle -7500403 true true 43 43 122
Polygon -7500403 true true 255 120 240 150 210 180 180 210 150 240 146 135
Line -7500403 true 150 209 151 80
Polygon -7500403 true true 45 120 60 150 90 180 120 210 150 240 154 135

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
NetLogo 6.4.0
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
