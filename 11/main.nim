import strutils
import math
from sequtils import map
import itertools
import sets
import tables
import gnuplot

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
    var outputs : seq[int]
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
            echo "fatal"
        
    return outputs

proc newAmp(): ref Amp =
    let a = new(Amp)
    let input = readFile("input.txt")
    var sequence = input.strip().split(",").map(parseInt)
    a.sequence = sequence

    for i in 0..1000:
        a.sequence.add(0)

    return a



type Direction = enum
        left, right, down, up
type Robot = object
    pos*: (int, int)
    direction*: Direction
    panels*: HashSet[(int, int)]
    map*: Table[(int, int), int]

proc forward(robot: ref Robot)=
    var pos = robot.pos
    case robot.direction:
        of left:
            pos = (pos[0] - 1, pos[1])
        of right:
            pos = (pos[0] + 1, pos[1])
        of up:
            pos = (pos[0], pos[1] - 1)
        of down:
            pos = (pos[0], pos[1] + 1)

    robot.pos = pos
    robot.panels.incl(robot.pos)


proc paint(robot: ref Robot, color :int)=
    robot.map[robot.pos] = color

proc getColor(robot: ref Robot):int=
    if not robot.map.hasKey(robot.pos):
        return 0
    return robot.map[robot.pos]

proc turn(robot: ref Robot, turn:int)=
    if turn == 0:
        case robot.direction:
            of left:
                robot.direction = down
            of right:
                robot.direction = up
            of up:
                robot.direction = left
            of down:
                robot.direction = right
    elif turn == 1:
        case robot.direction:
            of left:
                robot.direction = up
            of right:
                robot.direction = down
            of up:
                robot.direction = right
            of down:
                robot.direction = left
    else:
        echo "fatal turn"

let amp1 = newAmp()


type RobotRef = ref Robot
let robot = RobotRef(direction:up)

# For part1 comment this line
robot.map[(0,0)] = 1

while not amp1.halted:
    let output = amp1.sendInput(robot.getColor())
    let color = output[0]
    let turnDirection = output[1]

    robot.paint(color)
    robot.turn(turnDirection)
    robot.forward()


echo "panels paint only once: ", len(robot.panels) - 1




# Draw
var x :seq[float]
var y :seq[float]

for k,v in robot.map:
    if v == 1:
        x.add(float(k[0]))
        y.add(float(k[1]))
echo x
echo y
set_style(Dots)
cmd "set size ratio -1"
plot x, y
discard readChar stdin