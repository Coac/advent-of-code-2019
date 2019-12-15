import strutils
import math
from sequtils import map
import itertools
import sets
import tables
import gnuplot
import random

type Amp = object
    i*: int
    sequence*: seq[int]
    halted*: bool
    relativeBase*: int

proc parseParam(amp: ref Amp, offset: int): int =
    let opcode = amp.sequence[amp.i]
    let index1 = amp.sequence[amp.i+offset]
    let mode1 = int(opcode / int(math.pow(float(10), float(offset+1)))) %% 10
    let param1 = if mode1 == 1: index1 elif mode1 == 2: amp.sequence[
            amp.relativeBase + index1] else: amp.sequence[index1]
    return param1

proc parseParamIndex(amp: ref Amp, offset: int): int =
    let opcode = amp.sequence[amp.i]
    let index1 = amp.sequence[amp.i+offset]
    let mode1 = int(opcode / int(math.pow(float(10), float(offset+1)))) %% 10
    let param1 = if mode1 == 2: amp.relativeBase + index1 else: index1
    if mode1 == 1:
        echo "fatal parseParamIndex"
    return param1

proc sendInput(amp: ref Amp, value: int): seq[int] =
    var valuePassed = false
    var outputs: seq[int]
    while amp.i < amp.sequence.len:
        let opcode = amp.sequence[amp.i]
        case (opcode %% 100)
        of 1:
            let param1 = amp.parseParam(1)
            let param2 = amp.parseParam(2)
            let outputIndex = amp.parseParamIndex(3)
            amp.sequence[outputIndex] = param1 + param2
            amp.i += 4
        of 2:
            let param1 = amp.parseParam(1)
            let param2 = amp.parseParam(2)
            let outputIndex = amp.parseParamIndex(3)
            amp.sequence[outputIndex] = param1 * param2
            amp.i += 4
        of 3:
            if valuePassed:
                return outputs

            # let input = parseInt(readLine(stdin))
            let input = value
            let index1 = amp.parseParamIndex(1)
            amp.sequence[index1] = input
            amp.i += 2
            valuePassed = true

        of 4:
            let param1 = amp.parseParam(1)
            amp.i += 2
            # echo param1
            outputs.add(param1)
        of 5: # jump if true
            let param1 = amp.parseParam(1)
            let param2 = amp.parseParam(2)

            if param1 != 0:
                amp.i = param2
            else:
                amp.i += 3

        of 6: # jump if false
            let param1 = amp.parseParam(1)
            let param2 = amp.parseParam(2)
            if param1 == 0:
                amp.i = param2
            else:
                amp.i += 3

        of 7: # less than
            let param1 = amp.parseParam(1)
            let param2 = amp.parseParam(2)
            if param1 < param2:
                amp.sequence[amp.parseParamIndex(3)] = 1
            else:
                amp.sequence[amp.parseParamIndex(3)] = 0
            amp.i+=4
        of 8: # equals
            let param1 = amp.parseParam(1)
            let param2 = amp.parseParam(2)
            if param1 == param2:
                amp.sequence[amp.parseParamIndex(3)] = 1
            else:
                amp.sequence[amp.parseParamIndex(3)] = 0
            amp.i+=4
        of 9: # relative base update
            let param1 = amp.parseParam(1)
            amp.relativeBase += param1
            amp.i+=2

        of 99:
            amp.halted = true
            break
        else:
            echo "fatal output not recognized ", opcode

    return outputs

proc newAmp(): ref Amp =
    let a = new(Amp)
    let input = readFile("input.txt")
    var sequence = input.strip().split(",").map(parseInt)
    a.sequence = sequence

    for i in 0..1000:
        a.sequence.add(0)

    return a


let amp1 = newAmp()


type CellType = enum
    WALL, EMPTY, OXYGEN


const NORTH = 1
const SOUTH = 2
const WEST = 3
const EAST = 4

const WALLHIT = 0
const SUCCESSMOVE = 1
const SUCCESSOXYGEN = 2

var map: Table[seq[int], CellType]

let startPos = @[0, 0]
var currentPos = startPos
map[currentPos] = EMPTY

var oxyGenPos = @[0, 0]

# Explore
var previousMapLen = 0
var stepSinceNoExplore = 0
while not amp1.halted:
    let randomDirection = rand(1..4)
    let output = amp1.sendInput(randomDirection)

    var nextPos = currentPos
    if randomDirection == NORTH:
        nextPos[0] -= 1
    elif randomDirection == SOUTH:
        nextPos[0] += 1
    elif randomDirection == EAST:
        nextPos[1] += 1
    elif randomDirection == WEST:
        nextPos[1] -= 1

    if output.len != 1:
        echo "fatal output len"

    case output[0]:
    of WALLHIT:
        map[nextPos] = WALL
    of SUCCESSMOVE:
        currentPos = nextPos
        map[currentPos] = EMPTY
    of SUCCESSOXYGEN:
        currentPos = nextPos
        map[currentPos] = OXYGEN
        oxyGenPos = currentPos
    else:
        echo "fatal ouput"


    if previousMapLen != len(map):
        previousMapLen = len(map)
        stepSinceNoExplore = 0
    else:
        stepSinceNoExplore += 1
        if stepSinceNoExplore > 1000000:
            break

echo "tile explored:", len(map)
echo "oxygen pos:", oxyGenPos


# Shortest path dijkstra
proc shortestPath(startPos :seq[int], endPos: seq[int])=
    var distances : Table[seq[int], int]
    var open : seq[seq[int]]

    proc addNeighbour(neighPos : seq[int], newDist: int)=
        if map[neighPos] != WALL:
            if (distances.hasKey(neighPos) and distances[neighPos] > newDist) or (not distances.hasKey(neighPos)):
                distances[neighPos] = newDist
                open.add(neighPos)

    open.add(startPos)
    distances[startPos] = 0

    while open.len > 0:
        let pos = open.pop

        if pos == endPos:
            echo "found:", pos
            echo "distance:", distances[pos]      
            # break

        let newDist = distances[pos] + 1

        addNeighbour(@[pos[0]+1, pos[1]], newDist)
        addNeighbour(@[pos[0]-1, pos[1]], newDist)
        addNeighbour(@[pos[0], pos[1]+1], newDist)
        addNeighbour(@[pos[0], pos[1]-1], newDist)

    var maxDistanceFromStart = 0
    for k, v in distances:
        if v > maxDistanceFromStart:
            maxDistanceFromStart = v
    echo "maxDistanceFromStart:", maxDistanceFromStart


echo ""
echo "start to oxygen:"
shortestPath(startPos, oxyGenPos)

echo ""
echo "oxygen to start:"
shortestPath(oxyGenPos, startPos)


