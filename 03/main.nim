import strutils
import math
from sequtils import map
import algorithm

proc readWires(): (seq[string], seq[string]) =
    let file = open("input.txt")
    let wire1Raw = readLine(file)
    let wire1 = wire1Raw.strip().split(",")
    let wire2Raw = readLine(file)
    let wire2 = wire2Raw.strip().split(",")

    return (wire1, wire2)

let (wire1, wire2) = readWires()


proc computePath(instructions: seq[string]): seq[(int, int, int)] =
    var coord = (0, 0, 0) # x, y, step
    var path: seq[(int, int, int)]
    for inst in instructions:
        let direction = inst[0]
        let numStep = inst[1..^1].parseInt

        var dx = 0
        var dy = 0

        case direction
        of 'D':
            dy = 1
        of 'L':
            dx = -1
        of 'R':
            dx = 1
        of 'U':
            dy = -1
        else:
            echo "Fatal"

        for i in 1..numStep:
            coord[0] += dx
            coord[1] += dy
            coord[2] += 1

            path.add(coord)

    return path


let path1 = computePath(wire1)
let path2 = computePath(wire2)


var intersections : seq[(int, int, int)]
var distances : seq[int]
var steps : seq[int]
for coord1 in path1:
    for coord2 in path2:
        if coord1[0] == coord2[0] and coord1[1] == coord2[1]:
            intersections.add(coord1)
            distances.add(abs(coord1[0]) + abs(coord1[1]))
            steps.add(coord1[2] + coord2[2])

echo intersections
sort(distances, system.cmp)
echo distances
sort(steps, system.cmp)
echo steps