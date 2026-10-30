import Foundation

struct Region: Identifiable, Hashable {
    let id: String
    let name: String
    let kind: String
    let summary: String
    let tags: [String]
    let symbol: String
}

enum HubData {
    /// Last release date Rockstar announced (19 Nov 2026, local midnight).
    static let launch: Date = {
        var c = DateComponents()
        c.year = 2026; c.month = 11; c.day = 19
        return Calendar.current.date(from: c) ?? .now
    }()

    static let regions: [Region] = [
        Region(id: "vice", name: "Vice City", kind: "Metro",
               summary: "The neon heart of Leonida, modeled on Miami. Beaches, high-rises, nightclubs and a waterfront that never sleeps.",
               tags: ["Ocean Beach", "Nightlife", "Port"], symbol: "building.2"),
        Region(id: "keys", name: "Leonida Keys", kind: "Islands",
               summary: "A chain of islands strung along a single highway. Boats, bars, tourists and smuggling routes.",
               tags: ["Bridges", "Marinas", "Reefs"], symbol: "water.waves"),
        Region(id: "grass", name: "Grassrivers", kind: "Wetland",
               summary: "The swamp country, Leonida's take on the Everglades. Airboats, alligators and very few witnesses.",
               tags: ["Airboats", "Wildlife", "Backroads"], symbol: "leaf"),
        Region(id: "port", name: "Port Gellhorn", kind: "Coast",
               summary: "A faded Gulf Coast town of motels, strip malls and industry past its prime.",
               tags: ["Motels", "Docks", "Panhandle"], symbol: "ferry"),
        Region(id: "ambrosia", name: "Ambrosia", kind: "Inland",
               summary: "Sugar country in the interior, home to refineries, biker gangs and long empty roads.",
               tags: ["Refinery", "Bikers", "Farmland"], symbol: "smoke"),
        Region(id: "kalaga", name: "Mount Kalaga", kind: "Park",
               summary: "A national park in the north with forests, trails and rivers far from the city lights.",
               tags: ["Hiking", "Rivers", "Hunting"], symbol: "mountain.2")
    ]

    static let timeline: [(date: String, title: String, detail: String)] = [
        ("Feb 2022", "Development confirmed", "Rockstar says the next Grand Theft Auto is well underway."),
        ("Dec 2023", "Trailer 1", "Reveals Vice City, Lucia and a 2025 window."),
        ("May 2025", "First delay", "Moved from Fall 2025 to 26 May 2026."),
        ("May 2025", "Trailer 2", "Introduces Jason and the wider cast."),
        ("Nov 2025", "Second delay", "Moved to 19 November 2026."),
        ("Nov 2026", "Launch day", "PlayStation 5 and Xbox Series X|S.")
    ]

    static let checklist = [
        "Pre-order or pick a store",
        "Free up about 150 GB of storage",
        "Update your console firmware",
        "Rewatch trailer 1 and trailer 2",
        "Book the day off",
        "Charge the controller"
    ]
}

/// An official image hosted by Rockstar. The app loads it from Rockstar's
/// servers at runtime; nothing is bundled.
struct Shot: Identifiable, Hashable {
    let id: String
    let title: String
    let kind: String

    private static let base = "https://www.rockstargames.com/VI/_next/static/media/"

    func url(width: Int = 1600) -> URL {
        URL(string: Self.base + id + "?akim=1&imdensity=1&imwidth=\(width)")!
    }
}

extension HubData {
    static let rockstarPage = URL(string: "https://www.rockstargames.com/VI")!

    static let shots: [Shot] = [
        Shot(id: "desktop.00.5pzu2sm-z4.jpg", title: "Vice City at dusk", kind: "Screenshot"),
        Shot(id: "desktop.0iky3x6.hl8fo.jpg", title: "Ocean Beach", kind: "Screenshot"),
        Shot(id: "mediaDesktop.11iioep6d3wsf.jpg", title: "The job", kind: "Artwork"),
        Shot(id: "VINTAGE_VICE_CITY_PACK_01.05zaof7o1uz.3.jpg", title: "Ocean View Hotel", kind: "Artwork"),
        Shot(id: "featured.0.fbrrtu5j-9_.jpg", title: "Jason & Lucia", kind: "Key art"),
        Shot(id: "musicDesktop.0zwcbzhynnsc-.jpg", title: "Vice City nights", kind: "Artwork"),
        Shot(id: "onlyInLeonidaDesktop.15y2n40f3axwo.jpg", title: "Only in Leonida", kind: "Artwork")
    ]

    static let posters: [Shot] = [
        Shot(id: "trailer-1.06b6paykx247w.jpg", title: "Trailer 1", kind: "Key art"),
        Shot(id: "trailer-2.0l.7aqib91fz6.jpg", title: "Trailer 2", kind: "Key art")
    ]
}
