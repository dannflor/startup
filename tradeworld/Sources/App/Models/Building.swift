import Vapor

enum Building: String, Content {
    case Academy, Armory, Blacksmith, Carpenter, Cottage, Estate, Farm, Fishery, Forest, Fort, Guild, LargeHouse, LumberCamp, MediumHouse, Mine, Mountain, NoHouse, Palace, Pasture, Quarry, SmallHouse, Tower, University, Water, Watermill, Windmill
    
    static var terrainTypes: [Building] {
        get {
            return [.Forest, .Mountain, .Water, .NoHouse]
        }
    }
    
    static func getNeighbors(index: Int) -> (Int?, Int?, Int?, Int?) {
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
