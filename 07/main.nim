import strutils
import math
from sequtils import map
import itertools
import strutils

proc parseParams(i: int, opcode: int, sequence: seq[int]): (int, int) =
    let index1 = sequence[i+1]
    let index2 = sequence[i+2]
    let mode1 = int(opcode / 100) %% 10
    let mode2 = int(opcode / 1000) %% 10
    let param1 = if mode1 == 1: index1 else: sequence[index1]
    let param2 = if mode2 == 1: index2 else: sequence[index2]

    return (param1, param2)


type Amp = object
    i*: int
    sequence*: seq[int]
    halted*: bool

proc sendInput(amp: ref Amp, value: int): (int, bool) =
    var valuePassed = false
    while amp.i < amp.sequence.len:
        let opcode = amp.sequence[amp.i]
        case (opcode %% 100)
        of 1:
            let (param1, param2) = parseParams(amp.i, opcode, amp.sequence)
            let outputIndex = amp.sequence[amp.i+3]
            amp.sequence[outputIndex] = param1 + param2
            amp.i += 4
        of 2:
            let (param1, param2) = parseParams(amp.i, opcode, amp.sequence)
            let outputIndex = amp.sequence[amp.i+3]
            amp.sequence[outputIndex] = param1 * param2
            amp.i += 4
        of 3:
            if valuePassed:
                return (-1, false)
            let input = value
            let index1 = amp.sequence[amp.i+1]
            amp.sequence[index1] = input
            amp.i += 2
            valuePassed = true
        of 4:
            let index1 = amp.sequence[amp.i+1]
            let mode1 = int(opcode / 100) %% 10
            let param1 = if mode1 == 1: index1 else: amp.sequence[index1]

            # echo param1
            amp.i += 2
            return (param1, true)
        of 5: # jump if true
            let (param1, param2) = parseParams(amp.i, opcode, amp.sequence)

            if param1 != 0:
                amp.i = param2
            else:
                amp.i += 3

        of 6: # jump if false
            let (param1, param2) = parseParams(amp.i, opcode, amp.sequence)
            if param1 == 0:
                amp.i = param2
            else:
                amp.i += 3

        of 7: # less than
            let (param1, param2) = parseParams(amp.i, opcode, amp.sequence)
            if param1 < param2:
                amp.sequence[amp.sequence[amp.i+3]] = 1
            else:
                amp.sequence[amp.sequence[amp.i+3]] = 0
            amp.i+=4
        of 8: # equals
            let (param1, param2) = parseParams(amp.i, opcode, amp.sequence)
            if param1 == param2:
                amp.sequence[amp.sequence[amp.i+3]] = 1
            else:
                amp.sequence[amp.sequence[amp.i+3]] = 0
            amp.i+=4

        of 99:
            amp.halted = true
            return (-1, false)
        else:
            echo "fatal"

    echo "fatal"
    return (-1, false)

proc newAmp(value: int): ref Amp =
    let a = new(Amp)
    let input = readFile("input.txt")
    var sequence = input.strip().split(",").map(parseInt)
    a.sequence = sequence

    let (output, hasOutput) = a.sendInput(value)
    if hasOutput:
        echo "fatal"

    return a


let numbers = @[5, 6, 7, 8, 9]
var maxNum = 0
for perm in permutations(numbers):
    var out5 = 0
    let amp1 = newAmp(perm[0])
    let amp2 = newAmp(perm[1])
    let amp3 = newAmp(perm[2])
    let amp4 = newAmp(perm[3])
    let amp5 = newAmp(perm[4])
    while true:
        let (out1, hasOut1) = amp1.sendInput(out5)
        if not hasOut1 or amp1.halted:
            break
        let (out2, hasOut2) = amp2.sendInput(out1)
        if not hasOut2 or amp2.halted:
            break
        let (out3, hasOut3) = amp3.sendInput(out2)
        if not hasOut3 or amp3.halted:
            break
        let (out4, hasOut4) = amp4.sendInput(out3)
        if not hasOut4 or amp4.halted:
            break

        var hasOut5: bool
        (out5, hasOut5) = amp5.sendInput(out4)
        if not hasOut5 or amp5.halted:
            break

    if out5 > maxNum:
        maxNum = out5

echo maxNum
