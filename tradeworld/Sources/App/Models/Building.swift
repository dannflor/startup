import Vapor

enum Building: String, CaseIterable, Content {
    case Academy, Armory, Blacksmith, Carpenter, Cottage, Estate, Farm, Fishery, Forest, Fort, Guild, House, LumberCamp = "Lumber Camp", Mine, Mountain, NoHouse, Palace, Pasture, Quarry, Tower, University, Water, Watermill, Windmill
    
    static var terrainTypes: [Building] {
        get {
            return [.Forest, .Mountain, .Water, .NoHouse]
        }
    }
    
    var index: Int {
        get {
            return Building.allCases.firstIndex(of: self)!
        }
    }

    init?(rawValue: String) {
      switch rawValue {
        case "Academy":
          self = .Academy
        case "Armory":
          self = .Armory
        case "Blacksmith":
          self = .Blacksmith
        case "Carpenter":
          self = .Carpenter
        case "Cottage":
          self = .Cottage
        case "Estate":
          self = .Estate
        case "Farm":
          self = .Farm
        case "Fishery":
          self = .Fishery
        case "Forest":
          self = .Forest
        case "Fort": 
          self = .Fort
        case "Guild":
          self = .Guild
        case "House":
          self = .House
        case "Lumber Camp":
          self = .LumberCamp
        case "LumberCamp":
          self = .LumberCamp
        case "Mine":
          self = .Mine
        case "Mountain":
          self = .Mountain
        case "No House":
          self = .NoHouse
        case "NoHouse":
          self = .NoHouse
        case "Palace":
          self = .Palace
        case "Pasture":
          self = .Pasture
        case "Quarry":
          self = .Quarry
        case "Tower":
          self = .Tower
        case "University":
          self = .University
        case "Water":
          self = .Water
        case "Watermill":
          self = .Watermill
        case "Windmill":
          self = .Windmill
        default:
          self = .NoHouse
      }
    }

    public func yield(neighbors: [Building], techs: [Tech], req: Request) -> [ResourceQty] {
        // Iterate over each neighbor and aggregate their return ResourceQty arrays
        var bonuses = neighbors.map {
            return $0.bonus(recipient: self, techs: techs, req: req)
        }.reduce ([ResourceQty]()) {
            return $0.add($1)
        }
        // Get the yield for this building
        let yield = getMetadata(req: req).yield

        // Get tech based yields for this building
        for tech in techs {
            for effect in tech.effects {
                guard effect.building == self else {
                    continue
                }
                bonuses = bonuses.add(effect.yield)
            }
        }
        // Add the bonuses to the yield
        return yield.add(bonuses)
    }

    public func bonus(recipient: Building, techs: [Tech], req: Request) -> [ResourceQty] {
        var bonuses = [ResourceQty]()
        for tech in techs {
            for effect in tech.effects {
                guard effect.building == recipient else {
                    continue
                }
                guard let bonus = effect.bonus[recipient.rawValue] else {
                    continue
                }
                bonuses = bonuses.add(bonus)
            }
        }
        for bonus in getMetadata(req: req).bonus[recipient.rawValue] ?? [] {
            bonuses = bonuses.add([bonus])
        }
        return bonuses
    }

    public func getMetadata(req: Request) -> BuildingMetadata {
        guard let buildings = decodeFile(req: req, "buildingMetadata", [String: BuildingMetadata].self) else {
            print("Could not decode")
            return BuildingMetadata(yield: [], bonus: [:], bonusDescription: "", score: 0)
        }
        return buildings[self.rawValue] ?? BuildingMetadata(yield: [], bonus: [:], bonusDescription: "", score: 0)
    }
    
//     var corner_vectors = [Vector2i(1,-1),Vector2i(-1,-1),Vector2i(-1,1),Vector2i(1,1)]
// var side_directions = [Vector2i(-1,0),Vector2i(0,1),Vector2i(1,0),Vector2i(0,-1)]
// func _ulam_spiral(n) -> Vector2i:
// 	if n == 0:
// 		return Vector2i(0,0)
// 	var k = int(ceil(floor(sqrt(n))/2))
// 	var distance_from_cycle_start = n - (4*k*(k-1) + 1)
// 	# Identify which of the four sides (straight sections)
// 	# of the cycle n is in:
// 	var side_length = 2*k
// 	var side = int(floor(distance_from_cycle_start / side_length))
// 	var distance_along_side = 1 + distance_from_cycle_start % side_length
// 	var ref_position = k * corner_vectors[side]
// 	return ref_position + distance_along_side * side_directions[side]

// # Return the value of n such that f(n) has the given coordinates
// func _sequence_number(p: Vector2i) -> int:
// 	var x = p.x
// 	var y = p.y
// 	var k = max(x, y, -x, -y) # the cycle number
// 	var side = (3 if x == k
// 			else 2 if y == k
// 			else 1 if x == -k
// 			else 0)
// 	var ref_position = k * corner_vectors[side]
// 	var n = (4*k*(k-1) + 1) + side * 2*k + max(abs(ref_position[0] - p[0]), abs(ref_position[1] - p[1])) - 1
// 	return n

// func get_neighbors(n: int) -> Array:
// 	var p = _ulam_spiral(n)
// 	var neighbors = []
// 	for i in range(4):
// 		var neighbor = p + side_directions[i]
// 		var index: int = _sequence_number(neighbor)
// 		if index < buildings.size():
// 			neighbors.append(index)
// 	return neighbors
    static func getNeighbors(_ index: Int, _ req: Request) async throws -> [Int] {
        let cornerVectors: [(Int, Int)] = [ (1, -1), (-1, -1), (-1, 1), (1, 1) ]
        let sideDirections: [(Int, Int)] = [ (-1, 0), (0, 1), (1, 0), (0, -1) ]

        let p = ulamSpiral(index)
        var neighbors = [Int]()
        for i in 0..<4 {
            let neighbor = (p.0 + sideDirections[i].0, p.1 + sideDirections[i].1)
            let index = sequenceNumber(neighbor)
            guard let layout = try await req.auth.require(User.self).$layout.get(on: req.db)?.layout else {
                throw Abort(.internalServerError)
            }
            if index < layout.count {
                neighbors.append(index)
            }
        }
        
        return neighbors

        func ulamSpiral(_ index: Int) -> (Int, Int) {
            if index == 0 {
                return (0, 0)
            }
            let k = Int(ceil(floor(sqrt(Double(index)))/2))
            let distanceFromCycleStart = index - (4*k*(k-1) + 1)
            let sideLength = 2*k
            let side = Int(floor(Double(distanceFromCycleStart) / Double(sideLength)))
            let distanceAlongSide = 1 + distanceFromCycleStart % sideLength
            let refPosition = (k * cornerVectors[side].0, k * cornerVectors[side].1)
            return (refPosition.0 + distanceAlongSide * sideDirections[side].0, refPosition.1 + distanceAlongSide * sideDirections[side].1)
        }
        func sequenceNumber(_ p: (Int, Int)) -> Int {
            let x = p.0
            let y = p.1
            let k = max(x, y, -x, -y)
            let side = (3 == x ? 3 : 2 == y ? 2 : 1 == x ? 1 : 0)
            let refPosition = (k * cornerVectors[side].0, k * cornerVectors[side].1)
            let n = (4*k*(k-1) + 1) + side * 2*k + max(abs(refPosition.0 - p.0), abs(refPosition.1 - p.1)) - 1
            return n
        }
    }
}

extension Array where Element == ResourceQty {
    func add(_ other: [ResourceQty]) -> [ResourceQty] {
        var result = self
        for qty in other {
            if let index = result.firstIndex(where: { $0.name == qty.name }) {
                result[index] = ResourceQty(name: qty.name, count: result[index].count + qty.count)
            } else {
                result.append(qty)
            }
        }
        return result
    }
}
