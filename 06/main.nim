import strutils
import math
import tables


type SpaceObj = object
    name*: string
    orbitedObjs*: seq[ref SpaceObj]
    parent*: ref SpaceObj

type SpaceObjRef = ref SpaceObj

proc computeSum(obj: ref SpaceObj, height: int): int =
    var accum = 0
    for i in obj.orbitedObjs:
        accum += computeSum(i, height+1)
    return accum + height

proc computePathDist(start: SpaceObjRef, dists: ref Table[string, int]) =
    let dist = dists[start.name]
    for obj in start.orbitedObjs:
        if not dists.hasKey(obj.name):
            dists.add(obj.name, dist + 1)
            computePathDist(obj, dists)


    if start.parent != nil:
        let obj = start.parent
        if not dists.hasKey(obj.name):
            dists.add(obj.name, dist + 1)
            computePathDist(obj, dists)
    for obj in start.orbitedObjs:
        if not dists.hasKey(obj.name):
            dists.add(obj.name, dist + 1)
            computePathDist(obj, dists)


var objs = initTable[string, SpaceObjRef]()

for line in lines "input.txt":
    let splitted = line.split(")")
    let obj1Name = splitted[0]
    let obj2Name = splitted[1]

    var obj1 = SpaceObjRef(name: obj1Name)
    if objs.hasKey(obj1Name):
        obj1 = objs[obj1Name]

    var obj2 = SpaceObjRef(name: obj2Name)
    if objs.hasKey(obj2Name):
        obj2 = objs[obj2Name]

    obj1.orbitedObjs.add(obj2)
    obj2.parent = obj1

    objs[obj1Name] = obj1
    objs[obj2Name] = obj2


let com = objs["COM"]
echo "sum: ", computeSum(com, 0)

var dists = newTable[string, int]()
let you = objs["YOU"]
dists["YOU"] = 0
computePathDist(you, dists)
echo "santa dist: ", dists["SAN"] - 2
