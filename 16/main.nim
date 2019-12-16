import strutils
import math
import sequtils
import sugar

var input = readFile("input.txt")
var sequence = input.strip().map(c => parseInt($c))

proc patternForElement(index: int, length: int): seq[int] =
    var pattern = @[0, 1, 0, -1]
    var newPattern: seq[int]

    var patternIndex = 0
    while newPattern.len < length + 1:
        for i in 1..index+1:
            newPattern.add(pattern[patternIndex])
            if newPattern.len >= length + 1:
                break

        patternIndex += 1
        patternIndex = patternIndex %% pattern.len

    # shift
    newPattern.delete(0)

    return newPattern


proc applyPatternIndex(index: int, sequence: seq[int]): int =
    let pattern = patternForElement(index, len(sequence))

    var sum = 0
    for i in index..<sequence.len:
        sum += pattern[i] * sequence[i]

    return abs(sum) %% 10

proc applyPatternToSequence(sequence: seq[int]): seq[int] =
    var newSequence: seq[int]
    for i, v in sequence:
        newSequence.add(applyPatternIndex(i, sequence))

    return newSequence

for i in 1..100:
    sequence = applyPatternToSequence(sequence)

echo "part1:", sequence[..7].join()



input = readFile("input.txt")
sequence = input.strip().map(c => parseInt($c))
let initialLen = sequence.len

for l in 1..<10000:
    for i in 0..<initialLen:
        sequence.add(sequence[i])

let offset = parseInt(input[0..6])

echo "offset: ", offset, " len: ", sequence.len
sequence = sequence[offset..^1]
echo "new len: ", sequence.len

for phase in 1..100:
    var i = sequence.len() - 2
    while i > -1:
        sequence[i] = (sequence[i] + sequence[i + 1]) mod 10
        i -= 1


echo "part2: ", sequence[0..7].join("")
