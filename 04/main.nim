import strutils
import math
import sequtils
import macros

let min = 245182
let max = 790572

const MAX_DIGIT = 6

proc adjacentDigits(digits: array[MAX_DIGIT, int]): bool =
    for i in 0..MAX_DIGIT-2:
        if digits[i] == digits[i+1]:
            return true

    return false

proc increasingDigits(digits: array[MAX_DIGIT, int]): bool =
    for i in 0..MAX_DIGIT-2:
        if digits[i] > digits[i+1]:
            return false

    return true

proc adjacentGroupDigits(digits: array[MAX_DIGIT, int]): bool =
    for i in 0..MAX_DIGIT-2:
        if digits[i] == digits[i+1] and count(digits, digits[i]) == 2:
            return true

    return false

var count = 0
for num in min..max:
    var digits = [0, 0, 0, 0, 0, 0]
    digits[0] = int(num / 100000)%%10
    digits[1] = int(num / 10000)%%10
    digits[2] = int(num / 1000)%%10
    digits[3] = int(num / 100)%%10
    digits[4] = int(num / 10)%%10
    digits[5] = num %% 10

    if not adjacentGroupDigits(digits):
        continue
    if not increasingDigits(digits):
        continue

    count += 1
    echo digits

echo count
