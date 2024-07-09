globals [
  larval-deaths
  pupal-deaths
  gnot-count
  mean-initial-strength
  gnots-died-out
]

turtles-own [
  age 			;;in hours
  speed			
  initial-strength
  strength	;;
  can-reproduce
  id
  is-parent
]

to setup
  clear-all
  resize-world 0 100 0 100
  set-patch-size 4.0
  set larval-deaths 0
  set pupal-deaths 0
  set gnot-count 0
  set gnots-died-out false
  create-turtles population [
    set age 0
    set shape "dot" set size 0.8
    set strength random-normal mean-strength stddev-strength
    set initial-strength strength
    set speed 0
    setxy random-xcor random-ycor
    set can-reproduce 1
    set id who
    set is-Parent False
    set gnot-count gnot-count + 1
  ]
  reset-ticks
end

to go
  if not any? turtles [set gnots-died-out true stop]

  ask turtles[
    let c color
    let p-id id
    let p-initial-strength initial-strength
    (ifelse
      age < 36 [set speed 0 set shape "dot" set size 0.8] ;;egg
      age < 192 [set speed strength * 0.0003 set shape "bug" set size 0.8] ;;larva
      age < 240 [set speed 0 set shape "bug" set size 1.2] ;;pupa
      [
        set shape "default" set size 3
        set speed strength * 0.02 + 0.5
        if random 168 < 1 and can-reproduce = 1 [
          let patch-count count patches in-radius egg-laying-radius
          ask patches in-radius egg-laying-radius [if random patch-count < expected-egg-quantity [ sprout 1 [
          	set age 0
          	set heading random 360
          	set speed 0
            (ifelse inherit-parent-strength
              [set initial-strength random-normal p-initial-strength stddev-strength]
              [set initial-strength random-normal mean-strength stddev-strength]
            )
            set strength initial-strength
          	set color c
            set can-reproduce random 2
            set shape "dot" set size 0.8
            set id p-id
            set gnot-count gnot-count + 1
            ] ]
        	]
        	set strength strength / 2
          set is-parent True
        ]
    ])
    rt random 10
    lt random 10
    fd speed
    set strength max list (strength - 0.1) 0
    set age age + 1
    if strength = 0 [ kill-gnot ]
    if age > 36 [set strength strength - 10 * (count (turtles-on patch-here) - 1)]
  ]
  (ifelse any? turtles
    [set mean-initial-strength mean [initial-strength] of turtles]
    [set mean-initial-strength 0]
  )
  tick
end

to kill-gnot
	(ifelse
    age < 192 [set larval-deaths larval-deaths + 1]
    age < 240 [set pupal-deaths pupal-deaths + 1]
  )
  die
end

to-report gnots-died-out?
  report not any? turtles
end

to-report dynasties-remaining
  let _unique remove-duplicates [id] of turtles
  if gnots-died-out? [report -1000]
  report length _unique
end

to-report death-rate
  report (larval-deaths + pupal-deaths)
end

to-report max-initial-strength
  if gnots-died-out? [report -1000]
  report mean-initial-strength
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
622
423
-1
-1
4.0
1
10
1
1
1
0
1
1
1
0
100
0
100
1
1
1
ticks
30.0

SLIDER
30
55
200
88
population
population
20
40
40.0
1
1
NIL
HORIZONTAL

BUTTON
30
15
115
48
Setup
setup
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
120
15
200
48
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
30
95
200
128
mean-strength
mean-strength
50
60
60.0
1
1
NIL
HORIZONTAL

SLIDER
30
135
200
168
stddev-strength
stddev-strength
5
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
30
175
200
208
egg-laying-radius
egg-laying-radius
4
9
9.0
1
1
NIL
HORIZONTAL

SLIDER
30
215
200
248
expected-egg-quantity
expected-egg-quantity
3
10
10.0
1
1
NIL
HORIZONTAL

MONITOR
30
298
200
343
Dynasties Remaining
dynasties-remaining
0
1
11

MONITOR
30
348
110
393
Larval Deaths
larval-deaths
0
1
11

MONITOR
120
348
200
393
Pupal Deaths
pupal-deaths
0
1
11

MONITOR
29
398
199
443
Gnot Count
gnot-count
0
1
11

SWITCH
30
256
200
289
inherit-parent-strength
inherit-parent-strength
0
1
-1000

PLOT
628
12
828
162
Mean Initial Gnot Strength
Time
Strength
0.0
100.0
0.0
60.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean-initial-strength"

@#$#@#$#@
## WHAT IS IT?

This Netlogo simulation illustrates the life cycle of Bradysia ocellaris, commonly known as the dark-winged fungus gnat, native to the Palearctic region and has also been introduced to Australia (Menzel et al, 2003). These gnats thrive in moist, humid environments with an abundance of fungi and decaying organic matter (Duarte et al, 2022). As a result, they are commonly found in greenhouses, mushroom farms, and indoor potted plants (Duarte et al, 2022).
The simulation models the four stages of a gnat's life cycle: egg, larva, pupa, and adult. For each run, it tracks the remaining dynasties, larval deaths, pupal deaths, and overall gnat count. Additionally, a graph is generated to display the average strength of the gnat population over time.

## HOW IT WORKS

Each stage of the gnots life cycle is governed by its own set of rules. The gnots will follow four main sets of rules which will determine the stage of their life cycle, reproduction, movement and death.

- The world is initially cleared, resized and the global variables ('Dynasties Remaining', 'Larval Deaths', 'Pupal Deaths', and 'Gnot Count') are set to 0. A population of gnot eggs are then produced, the number set according to the value of the 'population' variable. Each gnot has a unique ID and have their age and speed set to 0, a size set to dot of 0.8, and placed at a random position. The created gnots are set as not-parents (is-Parent False) and a reproductive value of 1 which assigns the gnot a 'sex'. Gnots are not able to lay eggs if their reproductive value is 0 and are if the value is 1, meaning all initial gnots will have the ability able to lay eggs. The strength of each gnot is set randomly based on the normal mean-strength and the standard deviation of the strength. The ensures the data obtained from the simulation is obtained from each separate run.
- The age of each gnot is determined by the number of ticks that have passed. This age dictates the stage of the gnat's lifecycle. Gnots aged 0 to 35 are in the egg stage, characterized by a speed of 0, a dot shape, and a size of 0.8. Gnots aged 36 to 191 are in the larval stage, characterized by a speed determined by its strength (this speed is 0.03% the speed at the adult stage, making it much slower), a bug shape, and a size of 1.2. Gnots aged 192 to 239 are in the pupal stage, characterized by a speed of 0, a bug shape, and a size of 1.2. Gnots aged over 240 are in the adult stage, characterized by a speed determined by its strength, a default shape, and a size of 3.
- Gnots are assigned a sex by a random value of 0, male, or 1, female, set as the variable can-reproduce. Each female gnot has a random probability to reproduce by laying eggs, set by 'random 168 < 1'. The size of the egg clutch is determined by the number of patches in the specified egg-laying-radius and the expected egg quantity. Once eggs are laid, the parent gnot is then identified as a parent by setting the variable 'is-Parent' to true. The eggs will inherit the colour of the parent-gnot.
- The initial gnot's strength of the gnots are determined using a random value obtained from the normal distribution and the specified value for the standard deviation of the mean. If the inherit-parent-strength is turned on, the gnots will inherit the initial-strength of their parent gnot, whereas if it is turned off the eggs will be given a random strength value just as the initial gnots were.
- Only gnots at the larval and adult stages are the gnots set to be able to move. The gnots are set to randomly turn left and right and their speed is determined based on their strength. The strength of each gnot decreases over time to simulate aging, and female gnots' strength is halved after laying a clutch of eggs.
- As the gnots age or have laid eggs, their strength decreases. Once the strength of the gnot reaches 0, the gnot 'dies'. If the gnot has a low initial strength, it will die in the early stages of its lifecycle. If a gnot dies while in the larval stage, the "Larval Deaths" counter increments by 1. If a gnot dies while in the pupal stage, the "Pupal Deaths" counter increments by 1. When a gnot dies, a procedure called kill-gnot is activated where the appropriate death counter is incremented and the gnot is removed from the simulation. 

## HOW TO USE IT

There are six global variables the user is able to adjust in this simulation. To adjust the initial population size of the gnots the user should use the 'population' tab. To adjust the strength of the gnots the user should use the 'mean-strength' and 'stddev-strength' tabs. To adjust the reproductive behaviour of the gnots the user should use the 'egg-laying-radius' and 'expected-egg-quantity' tabs. The strength of the laid eggs can be set to either a randomly selected value or inherited from its parent gnot.

- The population tab allows you to adjust the initial number of eggs the simulation begins with. The user is able to select between 20 and 40 eggs to start the simulation.
- The mean-strength tab allows you to adjust the mean value for the normal distribution to initialize the strength of each gnot. The gnot's strength is determined by a random value drawn from the normal distribution with the selected mean-strength. The user can select a mean-strength between 50 and 60, 50 giving the lowest normal distribution of strength and 60 the highest.
- The stddev-strength tab allows you to adjust the standard deviation for the normal distribution used to initialize the strength of each gnot. The gnot's strength is determined by a random value drawn from the normal distribution with the selected standard deviation. The user can select a stddev-strength between 5 and 10, 5 giving the lowest standard deviation of strength and 10 the highest.
- The egg-laying-radius tab allows you to adjust the radius around the gnot which the gnot is able to lay eggs within. When the gnot decides to lay eggs, it will consider patches within the radius as potential locations to lay the eggs. The radius can be set between the values of 4 and 9. The smaller the radius, the less patches the gnot has to consider laying eggs within, reducing the area the gnots are able to spread their eggs. The larger the radius, the more patches the gnot has to consider laying eggs within, increasing the area the gnots are able to spread their eggs. This tab will only affect 'female' gnots.
- The expected-egg-quantity tab determines the expected number of eggs each female gnot will attempt to lay within the set egg-laying-radius. This value will influence the probability of egg-laying on each patch within the set radius. The user can select values between 3 and 10, with 3 being the lowest number of expected eggs laid within the set radius and 10 being the highest.
- If the inherit-parent-strength switch is turned on, all eggs will inherit the initial-strength of their parent gnot. If the inherit-parent-strength switch is turned off, all eggs will be given a random strength based on a random value from the normal distribution and multiplied by the standard deviation of strength.
- The speed of the simulation can be adjusted using the 'normal speed' slider at the top of the simulation. The number of ticks refers to how many time steps have passed in the simulation. The further left the slider, the slower the simulation will run with less ticks passing per second, whereas the further right the slider, the faster the simulation will run with more ticks passing per second.

## THINGS TO NOTICE

The simulation has five key data trackers: 'dynasties remaining', 'larval deaths', 'pupal deaths', 'gnot count' and 'Mean Initial Gnot Strength'. These variables are useful in gaining an understanding of the dynamics of the gnot population such as the survival rates, reproductive ability of the population, and the overall strength of the population.

- The purpose of the dynasties remaining counter is to calculate the number of unique gnot dynasties (or family lines) that are still active in the simulation. This value is particularly important for studying factors including the genetic diversity of a population, survival of dynasties, population stability, and the effect of environmental changes. A high genetic diversity indicates an ability of the population to evolving and adapting to environmental changes and overcoming problems such as disease, whereas a low genetic diversity indicates the population is vulnerable to environmental changes and/or disease. The surviving dynasties provides insight into which families are more successful in terms of survival and reproduction. By studying the dynasties remaining, researchers are able to understand the long-term stability of a population. A stable or increasing number of dynasties can indicate a healthy population, whereas a decreasing number of dynasties suggests problems within the environment such as competition or inbreeding. NetLogo does this by collecting all the IDs of the living gnots and removing any duplicates. This gives the total dynasties remaining. 
- The purpose of the larval and pupal deaths counter is to track the number of gnots that have died whilst in the larval stage of their life (aged less than 192) and gnots that have died whilst in the pupal stage of their life (aged between 192 and 240). This data is particularly useful in the study of population health and viability, resource allocation and life cycle analysis. Tracking the pupal and larval deaths provides insights into the early life-stage mortality rates within the population, where a high mortality can indicate underlying issues such as poor environmental conditions, lack of resources and/or genetic issues. Studying this data also provides an understanding of the resources necessary for each stage of the gnots life cycle which can be adjusted to ensure better survival rates. This data provides accurate and detailed information on the mortality rates at different stages of the life cycle allowing researchers to critical intervention points to improve the survival rates of the population. Understanding these factors can help in assessing the overall health and viability of the population.
- The purpose of the gnot count is to track the total number of gnots that have been created throughout the simulation which provides data on the overall population dynamics, effectiveness of the population's reproductive ability, and the impact of environmental factors on the population growth. This data is useful in tracking the overall population growth over time. By monitoring this variable, it is possible to determine whether a population is growing, stable of declining, which is vital for understanding population trends and dynamics. The data also suggests a measure of the reproductive success within the population as a high gnot count indicates the population is successfully reproducing and therefore the conditions are favourable for the population. This accurate data can be used to model the population dynamics and simulations for building and validating models that predict future trends in the population growth.
- The purpose of the mean initial gnot strength graph is to track the mean strength of the population of gnots as time increases. If the graph is increasing as time progresses, this shows the mean strength of the gnots is increasing, meaning the population is getting stronger and gnots have an increasing lifespan. If the graph is overall horizontal as time progresses, this shows the mean strength of the gnots is neither increasing nor decreasing, meaning the population has a stable lifespan. If the graph is decreasing as time progresses, this shows the mean strength of the gnots is decreasing, meaning the population is getting weaker and gnots will die quicker. A mean initial strength of 0 means the population has died out.

## THINGS TO TRY

You can adjust several variables to affect the results of each run. Try adjusting these variables to see the effects each variable has on the dynamics of the population. Attempt to:
1. Maximise / minimise the dynasties remaining over a set number of ticks (e.g. 2000)
2. Maximise / minimise the larval deaths over a set number of ticks (e.g. 2000)
3. Maximise / minimise the pupal deaths over a set number of ticks (e.g. 2000)
4. Maximise the gnot count over a set number of ticks (e.g. 2000)
5. See what conditions would cause the population to become extinct
6. Maximise / minimise the mean initial gnot strength over a set number of ticks (e.g. 2000)

- Adjust the starting population of gnots. By adjusting the number of eggs the simulation starts with, the user can experiment to see how the population size impacts the population growth, dynasties remaining and the mortality rates at the larval and pupal stages. 
- Adjust the mean and standard deviation of strength. By adjusting the overall strength of the gnots, the user can experiment to see how this effects the survival and reproductive ability of the population. For example, a higher average strength may result in a longer average lifespan and therefore more successful reproduction and a higher population growth. The user can use this data to evaluate how varying strength levels affect gnot movement and interactions, and whether the strength value effects the gnot's ability to reproduce.
- Adjust the egg-laying radius. By adjusting the radius within which female gnots can lay eggs, the user can see how this affects the distribution and density of new gnots. Larger radii may result in a more dispersed population, whereas smaller radii may result in more crowded conditions.
- Adjust the expected egg quantity. By adjusting the expected egg quantity from female gnots, the user can experiment with this parameter to see how it affects the population growth of the gnots. Higher expected egg quantities can lead to a rapid population growth, but this could impact other factors such as over-crowding and resource depletion.
- Observe life stage transitions. The user can pause the simulation after a set period of gnots to track how quickly or slowly the population is transitioning through their stages of the life cycle and can track individual gnots to see how long each one spends during each stage.
- Monitor dynasty survival. Adjust the variables available in an attempt to maximise and minimise the number of surviving dynasties and determine how the different settings affect the survival of the distinct family lines over time.
- Monitor mortality rates. Adjust the variables available in an attempt to maximise and minimise the mortality of gnots during the larval and pupal stages of their life cycle and determine how the different settings affect the survival of these stages.
- Monitor mean-initial-strength. Adjust the variables in an attempt to maximise the mean initial gnot strength of the population of gnots over a set time to see what their optimum conditions are for thriving and strengthening, thus increasing their life span and ability to reproduce. Adjust the variables in an attempt to see what conditions are required for the population to die out. Try finding a variety of combinations and listing the reasons behind the decline.

## EXTENDING THE MODEL

There are several real-life factors that affect the population growth of Bradysia ocellaris which this simulation does not consider. Implementing one or more of the variables listed below would make the simulation closer to a real-life population and give a more accurate representation of what would happen to the growth of the population and the rates by which they reproduce, survive and die.

- Incorporate resource availability. Food and water are necessary resources for all living organisms where availability will drastically affect the population growth. By implementing patches which can have varying levels of food resources, this will give the user another variable which they can adjust alongside the current variables to achieve more accurate and detailed results.
- Incorporate predators. In the wild, Bradysia ocellaris has natural predators such as the nematodes Steinernema feltiae and predatory mite Hypoaspis miles which predate on the larvae in the soil. Predators are often used as a biological control measure for population growth and therefore are an important factor to consider. The user could implement the ability to introduce a varying number of predator agents to the simulation to see how this would affect the data of the population of gnots, in particular the survival of larvae and pupae as these are the dominant prey items. 
- Incorporate disease dynamics. Disease is a natural control for any population. Implementing the ability to introduce disease at a varying level will allow the user to obtain more accurate data on the affects it has on the population growth, survival and reproductive ability of the population at each stage of the gnots life cycle.
- Implement genetic variation and inheritance. The simulation has a basic level of inheritance where the colour can be inherited from the parent which does not affect the data in any way, and the strength of the offspring is inherited from the parent. The user could add genetic traits that influence survival and reproduction with inheritance mechanisms. 
- Enhance reproductive mechanics. Currently female gnots are able to lay eggs under any circumstance, whereas in real-life the gnats would need to mate and there would be an energy cost to the female gnat after laying the eggs. These features would make the simulation more complicated but give a more accurate representation of how the population would act under these constraints. Females would only be able to reproduce once they've mated and in order to do so and to lay eggs they would need a specified level of energy. This would pair well with the implementation of food and resources.

## NETLOGO FEATURES

This NetLogo model uses several interesting features to simulate the population growth and reproductive ability of Bradysia ocellaris, such as:

- Using global variables (i.e. larval deaths, pupal deaths and gnot count) as a means of tracking data across the simulation.
- Each turtle has its own attributes (i.e. age, speed, strength and sex) which allows for individual modelling of agents as well as population modelling.
- The agents go through stages of their lifecycle (i.e. egg, larva, pupa and adult). Each gnot goes through these stages at different rates depending on individual factors and each gnot as a result has a different survival rate and speed due to its individual strength value. 
- Adult female gnots are able to lay eggs based on random chance and find suitable laying spots within a radius determined by the user which demonstrates how the gnats must consider adequate areas within their vicinity to lay their eggs.
- The model tracks the number of gnot deaths across the simulation and separate this data according to the age of the gnot at the time of its death which adds an additional layer of detail to the mortality when tracking the mortality rates in the simulation. 
- The model is able to track runs where the gnot population dies out. It does this by tracking the number of gnots on screen. The variable 'gnots-died-out' is initially set to false, where it will change to true if all gnots die.

The model also has a number of features used as workarounds for missing features, such as:

- NetLogo does not naturally reset the counters between simulations, so this model manually clears this data between simulations making the data obtained specific to each simulation run with the specific variables chosen.
- NetLogo does not have built-in support for many statistical distributions, so this model uses the random-normal function to initialize the strength of each gnot which is useful for modelling the real-world variability of each gnat.
- NetLogo does not have built-in support for decay mechanisms, so this model uses a manual implementation to decay the strength of the gnot where the strength reduces over time and also reduced by the presence of close gnots due to competition.
- NetLogo does not have a direct or straightforward way to track the number of dynasties remaining, so this model makes use of the 'remove-duplicates' feature on the ID to track this data.
- NetLogo lacks built-in spatial density functions, so this model manually calculates the patch density for egg-laying which is then used to determine the likelihood of laying eggs.
- NetLogo does not have a standard method of identifying when all agents have 'died' in the run, so this model makes use of a Boolean called 'gnots-died-out' which tracks whether there are gnots alive or not, meaning if the population has survived or died out.

## RELATED MODELS

- The 'Termites' model simulates the actions of termite colonies where behaviours such as foraging and interactions between agents can be studied. This is of interest if studying the behaviour of inspect populations.
- The 'Wolf Sheep' model simulates the predator-prey dynamics between wolves, sheep and grass. This may be of interest as this is a simulation to monitor population growth of specific species similar to that of the gnats, and tracks the number total number of grasses, sheep and wolves at each point of the simulation, plotting a time-density graph for each of the species, showing how the population levels affect each other.
- The 'Ants' model is another simulation based on the behaviours of insects where the ants forage for food and leave pheromones as a trail for other ants to follow. The model is predominantly based on how the population size affects the behaviour of the colony and is another simulation modelling the effects of population size.

## CREDITS AND REFERENCES
Duarte, A. F., Pazini, J. B., Padilha, A. C., Fagundes, J. P. R., Duarte, J. L. P., Cunha, U. S., & Bernardi, D. (2022). Biological Activity of Insecticides Against Bradysia ocellaris Larvae (Diptera: Sciaridae): A New Pest of Strawberry Crops. Journal of Economic Entomology, 115(5), 1601–1606.
Menzel, F., Smith, J. E., & Colauto, N. B. (2003). Bradysia difformis Frey and Bradysia ocellaris (Comstock): Two Additional Neotropical Species of Black Fungus Gnats (Diptera: Sciaridae) of Economic Importance: A Redescription and Review. Annals of the Entomological Society of America, 96(4), 448–457.
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
0
@#$#@#$#@
