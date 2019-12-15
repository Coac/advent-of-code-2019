import strutils
import math, hashes, sets, sequtils
import algorithm
import sugar
import tables

type Chemical = object
    name: string
    quantity: int


proc parseChemical(str : string): Chemical =
    var split = str.strip().split(" ")
    return Chemical(name: split[1], quantity:split[0].parseInt)

type Reaction = object
    inputs: seq[Chemical]
    output: Chemical


var reactions : seq[Reaction]

for line in lines "input.txt":
    var split = line.split(",")
    let lastInputAndOutput = split[^1].split("=>")

    var output = lastInputAndOutput[1]
    split[^1] = lastInputAndOutput[0]

    reactions.add(Reaction(inputs:split.map(parseChemical), output:parseChemical(output)))


# Was lazy to implement binary search, so manually and finish using the loop
for i in 2250000..3000000:
    var reactionsMap: Table[string, Reaction]
    var leftOvers: Table[string, int]
    leftOvers["ORE"] = 0
    for reaction in reactions:
        reactionsMap[reaction.output.name] = reaction
        leftOvers[reaction.output.name] = 0


    proc oreCost(name : string, wantedQuantity: int): int=
        if name == "ORE": return wantedQuantity
        var reaction = reactionsMap[name]

        var multiplier = 1
        if wantedQuantity < reaction.output.quantity:
            multiplier = 1
        elif wantedQuantity > reaction.output.quantity:
            multiplier = int(math.ceil(float(wantedQuantity) / float(reaction.output.quantity)))

        leftOvers[name] += multiplier * reaction.output.quantity - wantedQuantity
        
        var sumOre = 0
        for input in reaction.inputs:
            var wantedQuantityInput  = input.quantity*multiplier

            let leftOverQuantityUsed = min(wantedQuantityInput, leftOvers[input.name])
            leftOvers[input.name] -= leftOverQuantityUsed
            wantedQuantityInput -= leftOverQuantityUsed
            if wantedQuantityInput == 0:
                continue
            sumOre += oreCost(input.name, wantedQuantityInput) 

        return sumOre

    let ore = oreCost("FUEL", i)

    if ore > 1000000000000:
        echo "ore:", ore, " fuel:", i
        break

