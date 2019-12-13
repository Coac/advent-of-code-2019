import strutils
import math


proc calculateFuel(mass: float): float =
    let fuel = math.trunc(mass / 3) - 2
    if fuel < 0:
        return 0
    return fuel + calculateFuel(fuel)

var fuelSum = 0.0
for line in lines "input.txt":
    let mass = parseFloat(line)

    let fuel = calculateFuel(mass)
    fuelSum += fuel
echo fuelSum
