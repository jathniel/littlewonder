import Testing
@testable import little_Wonder

struct AnimalTests {
    @Test("Every animal belongs to exactly one habitat, and that habitat lists it back")
    func habitatRoundTrips() {
        for animal in Animal.allCases {
            let habitat = animal.habitat
            #expect(habitat.animals.contains(animal))
        }
    }

    @Test("Every habitat's animals all report that habitat")
    func habitatMembershipConsistent() {
        for habitat in Habitat.allCases {
            #expect(!habitat.animals.isEmpty)
            for animal in habitat.animals {
                #expect(animal.habitat == habitat)
            }
        }
    }

    @Test("At least three habitats hold two or more animals, so Sort can pick 3 varied bins")
    func enoughMultiAnimalHabitats() {
        let eligible = Habitat.allCases.filter { $0.animals.count >= 2 }
        #expect(eligible.count >= 3)
    }

    @Test("Every animal and habitat maps to a non-empty SF Symbol name")
    func symbolsArePresent() {
        for animal in Animal.allCases { #expect(!animal.symbol.isEmpty) }
        for habitat in Habitat.allCases { #expect(!habitat.symbol.isEmpty) }
    }
}
