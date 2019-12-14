import strutils
import math, hashes, sets, sequtils
import algorithm
import sugar
import tables

var space: seq[string]

type Asteroid = object
    x: float
    y: float
    angle*: float
    distance*: float

var asteroids: seq[Asteroid]

var y = 0
for line in lines "input.txt":

    for x, obj in line:
        if obj == '#':
            asteroids.add(Asteroid(x: float(x), y: float(y)))
    y += 1

    space.add(line)



var max = 0
var stationAsteroid = asteroids[0]
for asteroid in asteroids:
    var angles = initHashSet[float]()
    for other in asteroids:
        if asteroid == other:
            continue

        let angle = math.arctan2(other.y - asteroid.y, other.x - asteroid.x)
        angles.incl(angle)
        if len(angles) > max:
            max = len(angles)
            stationAsteroid = asteroid

echo "visible asteroids:", max, " ", stationAsteroid


asteroids.delete(asteroids.find(stationAsteroid))
for i, other in asteroids:
    if stationAsteroid == other:
        continue
        
    asteroids[i].angle = math.arctan2(other.x - stationAsteroid.x, other.y - stationAsteroid.y)
    asteroids[i].distance = math.sqrt(math.pow(other.y - stationAsteroid.y, 2) +  math.pow(other.x - stationAsteroid.x, 2))
    # echo math.PI/2 == asteroids[i].angle



proc cmpAsteroids(a: Asteroid, b:Asteroid) :int=
    let value = cmp(a.angle, b.angle)
    if value != 0:
        return value
    return cmp(b.distance, a.distance)

asteroids.sort((a, b) => cmpAsteroids(a,b), order = SortOrder.Descending)



var prevAngle = -1.000001
var i = 0
var turn = true
var nth = 0
while asteroids.len > 0:
    if prevAngle != asteroids[i].angle or turn:
        prevAngle = asteroids[i].angle

        turn = false

        nth += 1
        
        echo nth, " asteroid:", asteroids[i]

        asteroids.delete(i)
        i -= 1

    i += 1
    if i >= asteroids.len:
        turn = true
        i = 0


for asteroid in asteroids:
    echo asteroid
