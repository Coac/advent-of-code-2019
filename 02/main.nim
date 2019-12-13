import strutils
import math
from sequtils import map

proc part1(value1: int, value2: int): int =
    let input = readFile("input.txt")
    var sequence = input.strip().split(",").map(parseInt)

    sequence[1] = value1
    sequence[2] = value2

    var i = 0
    while i < sequence.len:
        let opcode = sequence[i]
        let index1 = sequence[i+1]
        let index2 = sequence[i+2]
        let outputIndex = sequence[i+3]


        case opcode
        of 1:
            sequence[outputIndex] = sequence[index1] + sequence[index2]
        of 2:
            sequence[outputIndex] = sequence[index1] * sequence[index2]
        of 99:
            break
        else:
            echo "fatal"

        i += 4


    return sequence[0]

# let output = part1(12, 2)

for i in 0..99:
    for j in 0..99:
        let output = part1(i, j)
        if 19690720 == output:
            echo i, " ", j
            break
