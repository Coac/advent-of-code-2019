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
let output = amp1.sendInput(0)

var i = 2
var blockcount = 0


var paddleX = 0
var ballX = 0
while i < output.len:
    if output[i] == 2:
        blockcount += 1
    if output[i] == 3:
        paddleX = output[i - 2] 
    if output[i] == 4:
        ballX = output[i - 2]
    i += 3
echo "block count:", blockcount
    
    
while not amp1.halted:
    
    let output = amp1.sendInput(ballX - paddleX)
    echo "joystick:", ballX - paddleX, " paddle:", paddleX, " ball:", ballX

    i = 5
    while i < output.len:
        if output[i] == 3:
            paddleX = output[i - 2] 
        if output[i] == 4:
            ballX = output[i - 2]
        i += 3
    
    echo output
