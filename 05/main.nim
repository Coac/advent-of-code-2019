import strutils
import math
from sequtils import map


proc parseParams(i:int, opcode:int, sequence: seq[int]):(int, int)=
    let index1 = sequence[i+1]
    let index2 = sequence[i+2]
    let mode1 = int(opcode / 100) %% 10
    let mode2 = int(opcode / 1000) %% 10
    let param1 = if mode1 == 1 : index1 else: sequence[index1]
    let param2 = if mode2 == 1 : index2 else: sequence[index2]

    return (param1, param2)

proc program()=
    let input = readFile("input.txt")
    var sequence = input.strip().split(",").map(parseInt)

    var i = 0
    while i < sequence.len:
        let opcode = sequence[i]
        case (opcode %% 100)
        of 1:
            let (param1, param2) = parseParams(i, opcode, sequence)
            let outputIndex = sequence[i+3]
            sequence[outputIndex] = param1 + param2
            i += 4
        of 2:
            let (param1, param2) = parseParams(i, opcode, sequence)
            let outputIndex = sequence[i+3]
            sequence[outputIndex] = param1 * param2
            i += 4
        of 3:
            let input = parseInt(readLine(stdin))
            let index1 = sequence[i+1]
            sequence[index1] = input
            i += 2
        of 4:
            let index1 = sequence[i+1]
            let mode1 = int(opcode / 100) %% 10
            let param1 = if mode1 == 1 : index1 else: sequence[index1]

            echo param1
            i += 2 
        of 5: # jump if true
            let (param1, param2) = parseParams(i, opcode, sequence)

            if param1 != 0:
                i = param2
            else:
                i += 3

        of 6: # jump if false
            let (param1, param2) = parseParams(i, opcode, sequence)
            if param1 == 0:
                i = param2
            else:
                i += 3

        of 7: # less than
            let (param1, param2) = parseParams(i, opcode, sequence)
            if param1 < param2:
                sequence[sequence[i+3]] = 1
            else:
                sequence[sequence[i+3]] = 0
            i+=4
        of 8: # equals
            let (param1, param2) = parseParams(i, opcode, sequence)
            if param1 == param2:
                sequence[sequence[i+3]] = 1
            else:
                sequence[sequence[i+3]] = 0
            i+=4

        of 99:
            break
        else:
            echo "fatal"


program()