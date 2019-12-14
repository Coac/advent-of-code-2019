import strutils
import math
import sequtils

let input = readFile("input.txt").strip()
var images: seq[seq[char]]

let width = 25
let height = 6
let numImages = int(input.len / (width*height))

for i in 1..numImages:
    images.add(newSeq[char]())

var imageIndex = -1
for i, val in input:
    if i %% (width * height) == 0:
        imageIndex += 1

    echo imageIndex, " ", numImages
    images[imageIndex].add(val)


var minZero = 9999999
var imageZeroIndex = 0
for index, image in images:
    let zeroCount = image.count('0')
    if zeroCount < minZero:
        minZero = zeroCount
        imageZeroIndex = index


let part1 = images[imageZeroIndex].count('1') * images[imageZeroIndex].count('2')
echo "part1: ", part1

# Print the image
let zeroImage = images[imageZeroIndex]
for i, c in zeroImage:
    var val = '0'
    for img in images:
        if img[i] == '2':
            continue
        val = img[i]
        break

    if i %% width == 0:
        echo ""
    write(stdout, val)
echo ""



