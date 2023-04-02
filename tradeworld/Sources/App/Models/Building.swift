import Vapor

enum Building: String, CaseIterable, Content {
    case Academy, Armory, Blacksmith, Carpenter, Cottage, Estate, Farm, Fishery, Forest, Fort, Guild, House, LumberCamp, Mine, Mountain, NoHouse, Palace, Pasture, Quarry, Tower, University, Water, Watermill, Windmill
    
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
        let bonuses = neighbors.map {
            return bonus(recipient: $0, techs: techs, req: req)
        }.reduce ([ResourceQty]()) {
            return $0.add($1)
        }
        // Get the yield for this building
        let yield = getMetadata(req: req).yield
        // Add the bonuses to the yield
        return yield.add(bonuses)
    }

    public func bonus(recipient: Building, techs: [Tech], req: Request) -> [ResourceQty] {
        var bonuses = [ResourceQty]()
        for tech in techs {
            for effect in tech.effects {
                guard effect.building == self else {
                    continue
                }
                guard let bonus = effect.bonus[recipient.rawValue] else {
                    continue
                }
                bonuses = bonuses.add(bonus)
            }
        }
        return bonuses
    }

    public func getMetadata(req: Request) -> BuildingMetadata {
        guard let buildings = decodeFile(req: req, "buildingMetadata", [String: BuildingMetadata].self) else {
            return BuildingMetadata(yield: [], bonus: [:], bonusDescription: "", score: 0)
        }
        return buildings[self.rawValue] ?? BuildingMetadata(yield: [], bonus: [:], bonusDescription: "", score: 0)
    }
    
    
    static func getNeighbors(_ index: Int) -> (Int?, Int?, Int?, Int?) {
        switch (index) {
            case 0:
              return (nil, nil, 1, 2)
            case 1:
              return (nil, 0, 3, 4)
            case 2:
              return (0, nil, 4, 5)
            case 3:
              return (nil, 1, 6, 7)
            case 4:
              return (1, 2, 7, 8)
            case 5:
              return (2, nil, 8, 9)
            case 6:
              return (nil, 3, 10, 11)
            case 7:
              return (3, 4, 11, 12)
            case 8:
              return (4, 5, 12, 13)
            case 9:
              return (5, nil, 13, 14)
            case 10:
              return (nil, 6, 15, 16)
            case 11:
              return (6, 7, 16, 17)
            case 12:
              return (7, 8, 17, 18)
            case 13:
              return (8, 9, 18, 19)
            case 14:
              return (9, nil, 19, 20)
            case 15:
              return (nil, 10, 21, 22)
            case 16:
              return (10, 11, 22, 23)
            case 17:
              return (11, 12, 23, 24)
            case 18:
              return (12, 13, 24, 25)
            case 19:
              return (13, 14, 25, 26)
            case 20:
              return (14, nil, 26, 27)
            case 21:
              return (nil, 15, nil, 28)
            case 22:
              return (15, 16, 28, 29)
            case 23:
              return (16, 17, 29, 30)
            case 24:
              return (17, 18, 30, 31)
            case 25:
              return (18, 19, 31, 32)
            case 26:
              return (19, 20, 32, 33)
            case 27:
              return (20, nil, 33, nil)
            case 28:
              return (21, 22, nil, 34)
            case 29:
              return (22, 23, 34, 35)
            case 30:
              return (23, 24, 35, 36)
            case 31:
              return (24, 25, 36, 37)
            case 32:
              return (25, 26, 37, 38)
            case 33:
              return (26, 27, 38, nil)
            case 34:
              return (28, 29, nil, 39)
            case 35:
              return (29, 30, 39, 40)
            case 36:
              return (30, 31, 40, 41)
            case 37:
              return (31, 32, 41, 42)
            case 38:
              return (32, 33, 42, nil)
            case 39:
              return (34, 35, nil, 43)
            case 40:
              return (35, 36, 43, 44)
            case 41:
              return (36, 37, 44, 45)
            case 42:
              return (37, 38, 45, nil)
            case 43:
              return (39, 40, nil, 46)
            case 44:
              return (40, 41, 46, 47)
            case 45:
              return (41, 42, 47, nil)
            case 46:
              return (43, 44, nil, 48)
            case 47:
              return (44, 45, 48, nil)
            case 48:
              return (46, 47, nil, nil)
          
            default:
              return (nil, nil, nil, nil)
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
