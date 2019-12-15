import strutils
import math, hashes, sets, sequtils
import algorithm
import sugar
import tables

type Moon = object
    position*: seq[int]
    velocity*: seq[int]

type MoonRef = ref Moon

proc applyGravity(moon: MoonRef, other: MoonRef) =
    moon.velocity[0] += cmp(other.position[0], moon.position[0])
    moon.velocity[1] += cmp(other.position[1], moon.position[1])
    moon.velocity[2] += cmp(other.position[2], moon.position[2])

proc applyVelocity(moon: MoonRef) =
    moon.position[0] += moon.velocity[0]
    moon.position[1] += moon.velocity[1]
    moon.position[2] += moon.velocity[2]

proc getEnergyPot(moon: MoonRef): int =
    return sum(moon.position.map(x => abs(x)))

proc getEnergyKin(moon: MoonRef): int =
    return sum(moon.velocity.map(x => abs(x)))

proc getEnergySum(moon: MoonRef): int =
    return moon.getEnergyPot() * moon.getEnergyKin()

proc hash(moon: MoonRef): Hash =
    return !$(moon.position.hash() !& moon.velocity.hash())


proc hash(moons: seq[MoonRef]): Hash =
    var h: Hash = 0
    for moon in moons:
        h = h !& moon.hash()
    result = !$h


proc hashN(moons: seq[MoonRef], n: int): Hash =
    var h: Hash = 0
    for moon in moons:
        h = h !& moon.velocity[n] !& moon.position[n]
    result = !$h


var moons: seq[MoonRef]

for line in lines "input.txt":
    var parsed = line.replace("x", "")
    parsed = parsed.replace("y", "")
    parsed = parsed.replace("z", "")
    parsed = parsed.replace("<", "")
    parsed = parsed.replace(">", "")
    parsed = parsed.replace("=", "")
    parsed = parsed.replace(" ", "")
    var coords = parsed.split(",").map(parseInt)

    moons.add(MoonRef(position: coords, velocity: @[0, 0, 0]))

for moon in moons:
    echo moon.position, " \t", moon.velocity


let startStateX = moons.hashN(0)
let startStateY = moons.hashN(1)
let startStateZ = moons.hashN(2)

# var previousState : seq[Hash]

for step in 1..46867749240:
    # echo "step:", step
    for moon in moons:
        for other in moons:
            if moon == other:
                continue
            moon.applyGravity(other)
    for moon in moons:
        moon.applyVelocity()

    # for moon in moons:
    #     echo moon.position ," \t", moon.velocity
    # echo "sum:", sum(moons.map(getEnergySum))

    # if previousState.contains(moons.hash()):
    #     echo "same state!"
    #     echo step
    #     break

    if moons.hashN(0) == startStateX:
        echo "same state X :", step
    if moons.hashN(1) == startStateY:
        echo "same state Y :", step
    if moons.hashN(2) == startStateZ:
        echo "same state Z :", step

    # previousState.add(moons.hash())

# For part 2
# Bruteforce will take years
# need to find the LCM between the X cycle, Y cycle and Z cycle.



