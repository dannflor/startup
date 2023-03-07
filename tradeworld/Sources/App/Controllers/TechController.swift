import Vapor
import CoreFoundation
import Fluent

func techController(tech: RoutesBuilder) {
    tech.get { req async throws -> View in
        return try await req.view.render("tech")
    }
    tech.get("unresearched") { req async throws -> [Tech] in
        var techs: [Tech] = []
        let arr = Array(1...10)
        for element in arr {
            let tech =
                Tech(
                    id: element,
                    title: "Tech Number \(element)",
                    description: "Description for tech number \(element)",
                    price: element*10
                )
            techs.append(tech)
        }
        return techs
    }
}
