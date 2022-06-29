globals [transfer]
turtles-own [wealth ability]

to setup
  clear-all
  ask patches [
    set pcolor white
  ]
  create-turtles N [
    set xcor random-xcor
    set ycor random-ycor
    set shape "face happy"
    set wealth 1
    set ability (random-beta-mu-sigma ability_mean ability_sd)
    visualize
  ]
  let current-mean mean [ability] of turtles
  ask turtles [set ability ability - current-mean + ability_mean] ;; normalize
  set transfer tax-revenue / N
  reset-ticks
end

to go
  ask turtles [ produce-simple ]
  set transfer tax-revenue / N
  redistribute
  ask turtles [visualize]
  tick
  if (sum [wealth] of turtles > 10 ^ 15) [stop]
end

to go-fast [tmax]
  if not netlogo-web? [no-display]
  repeat tmax [
    go
  ]
  if not netlogo-web? [display]
end

;; PROCEDURES

to produce-simple
  ifelse (random-float 1) < ability
    [ set wealth (wealth * success_factor) ]
    [ set wealth (wealth * failure_factor) ]
end

to redistribute
  ask turtles [set wealth ((1 - taxrate) * wealth + transfer)]
end

to visualize
  let abilty_color_contrast 0.7
  set color scale-color red ability (0 + abilty_color_contrast / 2) (1 - abilty_color_contrast / 2)
  ifelse wealth < 0.1
   [set size 0.1]
   [set size sqrt wealth]
end

to scenario-setup [sc_class sc_num]
  set N 500
  set ability_mean ifelse-value sc_class = "A" [0.5] [0.495]
  set ability_sd ifelse-value sc_class = "A" [0] [0.03]
  set failure_factor 0.5
  set success_factor ifelse-value sc_class = "A" [1.55] [1.5]
  set adminrate ifelse-value sc_class = "A" [0.1] [0]
  set taxrate (ifelse-value (sc_num = 1) [0]  (sc_num = 2) [0.1] [0.3])
  setup
end

;; REPORTERS

to-report tax-revenue
  report (sum [wealth] of turtles) * taxrate * (1 - adminrate)
end

to-report gini
  report ( 2 * sum (map [ [x y] -> x * y ] n-values count turtles [ z -> z + 1 ] sort [wealth] of turtles) ) / (count turtles * (sum [wealth] of turtles)) - (count turtles + 1) / count turtles
end

to-report partial-sums [nums] ; cumsum (matlab) equivalent used for Lorenz curve
  report butfirst reverse reduce [ [?1 ?2] -> fput (?2 + first ?1) ?1 ] fput [0] nums
end

to-report random-beta-mu-sigma [mu sigma]
    ifelse (sigma > 0) [ report random-gamma (mu * mu / sigma ^ 2) (1 / (sigma ^ 2 / mu))  ]
                       [ report mu ]
end
@#$#@#$#@
GRAPHICS-WINDOW
389
48
827
487
-1
-1
43.0
1
10
1
1
1
0
0
0
1
0
9
0
9
1
1
1
ticks
30.0

SLIDER
85
450
225
483
taxrate
taxrate
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
230
450
368
483
adminrate
adminrate
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
100
40
370
73
N
N
10
500
500.0
10
1
NIL
HORIZONTAL

BUTTON
20
40
94
73
NIL
Setup
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
20
450
82
483
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
195
280
370
313
success_factor
success_factor
1
2
1.5
0.01
1
NIL
HORIZONTAL

SLIDER
20
280
193
313
failure_factor
failure_factor
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
20
100
193
133
ability_mean
ability_mean
0
1
0.495
0.005
1
NIL
HORIZONTAL

MONITOR
20
320
230
365
mean ability expected value (EV)
success_factor * ability_mean + failure_factor * (1 - ability_mean)
3
1
11

TEXTBOX
25
260
360
278
Factors for success and failure
12
0.0
1

MONITOR
20
370
230
415
mean ability geometric mean (GM)
exp ((ln success_factor) * ability_mean + (ln failure_factor) * (1 - ability_mean))
3
1
11

PLOT
835
95
1090
225
total wealth
time
wealth
0.0
10.0
0.0
10.0
true
false
"" "set-plot-x-range 0 max list 1 ticks"
PENS
"default" 1.0 0 -16777216 true "" "plot sum [wealth] of turtles"

PLOT
835
230
1090
350
inequality (gini)
time
gini
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot gini"

MONITOR
1025
45
1090
90
NIL
transfer
3
1
11

SLIDER
198
100
370
133
ability_sd
ability_sd
0
0.05
0.03
0.001
1
NIL
HORIZONTAL

PLOT
20
135
212
255
ability of individuals
ability
NIL
0.0
1.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.02 1 -16449023 true "" "histogram [ability] of turtles"

MONITOR
835
45
910
90
r
exp ((ln mean [wealth] of turtles) / ticks)
5
1
11

MONITOR
215
135
307
180
mean ability
mean [ability] of turtles
4
1
11

MONITOR
235
370
340
415
max ability GM
exp ((ln success_factor) * max [ability] of turtles + (ln failure_factor) * (1 - max [ability] of turtles))
3
1
11

MONITOR
235
320
340
365
max ability EV
success_factor * max [ability] of turtles + failure_factor * (1 - max [ability] of turtles)
3
1
11

TEXTBOX
25
80
370
98
Distribution of individual success probabilities (ability)
12
0.0
1

TEXTBOX
20
10
313
31
Input parameters
18
0.0
1

MONITOR
290
185
365
230
max ability
max [ability] of turtles
3
1
11

MONITOR
215
185
290
230
min ability
min [ability] of turtles
3
1
11

TEXTBOX
20
426
356
448
Dynamic parameters - Redistribution
18
0.0
1

TEXTBOX
395
10
815
48
agent color lightness = ability \nagent size = wealth 
12
0.0
1

TEXTBOX
835
10
1075
32
Output measures
18
0.0
1

MONITOR
915
45
965
90
NIL
Gini
3
1
11

TEXTBOX
840
355
990
376
Scenarios
18
0.0
1

BUTTON
980
420
1035
453
B 2
scenario-setup \"B\" 2
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
925
455
1090
488
go 5000 ticks fast
go-fast 5000
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
840
390
925
415
EV growth > 1\nadmin cost
10
0.0
1

BUTTON
925
385
980
418
A 1
scenario-setup \"A\" 1
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
980
385
1035
418
A 2
scenario-setup \"A\" 2
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
1035
385
1090
418
A 3
scenario-setup \"A\" 3
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
840
425
935
450
EV growth < 1 \ndiverse ability
10
0.0
1

TEXTBOX
930
365
970
383
no tax
12
0.0
1

TEXTBOX
980
365
1025
383
low tax
12
0.0
1

TEXTBOX
1035
365
1090
383
high tax
12
0.0
1

BUTTON
1035
420
1090
453
B 3
scenario-setup \"B\" 3
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
925
420
980
453
B 1
scenario-setup \"B\" 1
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

The model demonstrates surprising effects on how the redistribution of wealth can trigger the growth of societal wealth. (See "Things to notice" Section for details.)

The individual growth of wealth is modeled as a multiplicative stochastic process and redistribution through proportional taxation and equal transfer of the tax revenue. 

## HOW IT WORKS

**N** agents are initially equipped with equal *wealth*.
The wealth is represented by the size of the agent. (The spatial location does not play a role during dynamics.)
Further on, each agent is initialized with an *ability* value between zero and one drawn at random from a beta distribution with mean **ability_mean** and standard deviation **ability_sd**. The ability remains unchanged after initialization. Higher ability is visualized with a lighter color. 

### Synopsis of dynamics

In every time step, the wealth of agents individually *grows or declines randomly*.
Afterward, every agent has to pay tax proportional to wealth. The tax revenue is then *redistributed* to everyone in equal shares. Before redistribution, the tax revenue may shrink because of administrative costs. 

### Detailed process description

*Individual wealth change:* The current wealth is either multiplied by the *growth factor* which is either the **success_factor** or the **failure_factor**. The success_factor is chosen randomly with a probability which is called individual **ability**. Otherwise, the failure factor is chosen. 

*Redistribution:* Each agent puts a fraction of **taxrate** of its wealth into the common pool (called *tax revenue*). The tax revenue is reduced by a fraction of **adminrate** which models a certain loss through administration (e.g., cost of redistribution, a "leaky bucket", or corruption). The remaining tax revenue is divided by the number of agents **N** and this *transfer* is given to each agent. 


## HOW TO USE IT

Click "setup" and "go". See how the wealth (= size) of agents changes through random growth or decline and redistribution. Observe if the growth rate *r* is below or above one and how the *total wealth* grows or declines in the long run. You can also observe the *Gini* coefficient, where one stands for maximal inequality and zero for maximal equality. 

The slider values of **ability_mean** and **ability_sd** only affect the setup.  
The slider values **success_factor** and **failure_factor** define the individual random growth process together with the individual ability value. In principle, they can be changed at runtime. 

The variables **taxrate** and **adminrate** define the process of redistribution and can be changed at runtime. 

### Scenarios

There are six buttons for scenario setup and a button "go 5000 ticks fast". By clicking a scenario setup, not only are new agents created but also all sliders are set to particular values. By clicking "go 5000 ticks fast", the go procedure is executed 5000 times in a row without intermediate display, which speeds up the computation a lot. (The simulation stops earlier when the total wealth reaches 10^15.)


## THINGS TO NOTICE

The six scenarios demonstrate two surprising growth phenomena (Scenario Series A and B). The tax rates in these scenarios are none (0), low (0.1), and high (0.3), for scenarios 1, 2, and 3. Both scenarios are about 500 agents. 

### Scenario Series A: Growth through lossy redistribution

Scenarios "A 1", "A 2", and "A 3" show how growth evolves through redistribution when the expected value of the growth factor is slightly above one (because the success factor increases wealth by 55% which is slightly more than the failure factor would decrease it with 50%). In this scenario, all agents have the ability of 0.5, which implies 50/50 chances for success and failure. In all scenarios the adminrate is 0.1, meaning the tax-revenue declines by 10% before redistribution. The taxrates in scenarios are 0, 0.1, and 0.3. The simulations show that only under 10% taxation the total wealth grow.

The expected growth factor in all three simulations is 1.025 when 10% of the growth is taxed and 10% of this 10% is lost, the expected lossy growth factor is still 1.01475 and above one. However, with a taxrate of 30%, the expected lossy growth factor is 0.99425 implying an unavoidable decline in the long run. With a taxrate of 0%, there is no loss through taxation, however, simulation shows a clear decline. This decline is a property of multiplicative stochastic growth in finite populations explained in the Section "Explanation of the lower effective growth rate of a multiplicative stochastic process" below. A pure multiplicative stochastic process is effectively not growing with the expected growth factor in the long run but with the geometric mean of both factors which is always lower. The empirical effective growth rate of the total wealth is shown as "r" in the output measures. 

With no taxation, total wealth declines because of the loss through risky multiplicative stochastic growth in finite societies. With taxation too high, total wealth declines because of the loss through administrative cost. Intermediate tax rates make total wealth grow. 

### Scenario Series B: Growth implied through diverse ability and redistribution

Scenarios "B 1", "B 2", and "B 3" show how growth can evolve through redistribution even when the expected average value of the growth factor is slightly below one. The adminrate in these scenarios is zero.

Growth can be triggered when the ability is diverse. In these scenarios, the growth factor increases the wealth by 50% which is as much as the failure factor decreases it. The other difference to scenario series A is that agents have different ability values and thus each agent has a different expected growth factor. The mean ability is 0.495. That means, on average agents have an expected growth factor of 0.995 which implies that wealth should decline in the long run. However, some agents have an ability larger than 0.5 and thus an expected growth factor slightly above one. Nevertheless, we know that an expected growth factor above one is not enough for an independent agent to grow. What is needed is a geometric mean larger than one (see the following Subsection). The ability standard deviation in these scenarios is 0.03 which makes it very unlikely that even the maximal ability in the sample of 500 agents has a geometric mean above one. That means every single trajectory will die out in the long run without taxation (test scenario "B 1"). 

However, with a taxrate of 0.1, the total wealth grows in the long run, but with an even higher taxrate of 0.3, we see a decline (test scenarios "B 2" and "B 3"). How can growth appear through taxation? The agents with high ability have a good chance to have several successes in a row, and by the multiplicative nature of the process, this would accumulate a sizable amount of wealth. The multiplicative nature, however, also implies that these agents will lose wealth in the long run. Redistribution can "save" part of this wealth for all individuals. Of course, agents with lower ability have a slightly higher chance to lose this wealth but the loss of currently rich agents counts much more as a proportion of the total wealth. When the taxrate is 0.3, the redistribution equalizes the different individual growth factors so much, that high-ability agents cannot accumulate enough wealth in short streaks of good luck anymore and the expected average growth factor below one kicks in. 


### Explanation of the lower effective growth rate of a multiplicative stochastic process

The most unintuitive property of multiplicative stochastic processes is the fact that the expected growth factor in one time step does not determine the growth of a single realization in the long run. Instead, the weighted arithmetic mean of growth and success factor (which is how the expected value is computed) of the effective growth factor, in the long run, is the geometric mean. The geometric mean is the exponential of the weighted means of the logarithms of growth and failure factor. Mathematically, it is always less than the arithmetic mean. 

Why this is the case can be demonstrated with an example for a success factor of 1.5 and a failure factor of 0.5 with an ability of 0.5:

When we consider successes (S) and failures (F) and two time steps there are four possible outcomes: 

`SS --> 1.5*1.5 = 2.25`
`SF --> 1.5*0.5 = 0.75`
`SF --> 0.5*1.5 = 0.75`
`FF --> 0.5*0.5 = 0.25`
`and the average factor is (2.25 + 0.75 + 0.75 + 0.25)/4 = 1.`

For three time steps we have:
`SSS --> 3.375`
`SSF, SFS, FSS --> 1.125`
`FFS, FSF, SFF --> 0.375`
`FFF --> 0.375 --> 0.125 `
`and the average factor is (3.375 + 3*1.125 + 3*0.375 + 0.125)/8 = 1.`

For four time steps we have: 
`SSSS --> 5.0625`
`4 permutations of SSSF --> 1.6875`
`6 permutations of SSFF --> 0.5625`
`4 permutations of FFFS --> 0.1875`
`FFFF --> 0.0625`
and the average factor is, of course, one. 
In this example we see what is happening: 11 out of 16 potential growth factors are way below one and the fact that average remains at one depend to a large extent on the one lucky streak which delivers a growth factor above five. Both of these properties will become more extreme as time steps progress. An increasingly larger share of potential growth factors will be below one and an increasingly larger share of the average growth factor will be determined by one lucky streak. In the long run, every real trajectory after t times steps will be close to the most likely trajectory: 
`0.5^(t/2)*1.5^(t/2)` and it is easy to see that this is equal to the geometric mean of 0.5 and 1.5 to the power of t. The geometric mean of 0.5 and 1.5 is approximately 0.866. 
That is why we will see a decline. 

## CREDITS AND REFERENCES

Developed and implemented by Jan Lorenz 
https://orcid.org/0000-0002-5547-7848
http://janlo.de

The model is available at http://github.com/janlorenz/AbilityGrowthRedistribution
Please cite the model if you use it in an academic context. 

The effects of scenario series A are also shown in 

Lorenz, J., Paetzel, F., & Schweitzer, F. (2013). Redistribution spurs growth by using a portfolio effect on risky human capital. PLoS One, 8(2), e54904. https://doi.org/10.1371/journal.pone.0054904
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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
