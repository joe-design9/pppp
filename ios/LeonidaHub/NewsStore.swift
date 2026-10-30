import SwiftUI

struct NewsItem: Identifiable, Hashable {
    let id: String
    let title: String
    let source: String
    let link: URL
    let date: Date

    var isOfficial: Bool { source.localizedCaseInsensitiveContains("Rockstar") }
}

/// Fetches the latest GTA VI headlines from Google News. The app shows only
/// headline, outlet and time; tapping opens the full story on the publisher's site.
@MainActor
@Observable
final class NewsStore {
    private(set) var items: [NewsItem] = []
    private(set) var lastUpdated: Date?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    /// Stories that arrived in the latest refresh (shown with a NEW tag).
    private(set) var newIDs: Set<String> = []
    /// How many new stories arrived since the News tab was last opened.
    private(set) var unseenCount = 0

    static let refreshInterval: Duration = .seconds(120)

    private static let feed = URL(string: "https://news.google.com/rss/search?q=%22GTA%206%22%20OR%20%22GTA%20VI%22%20OR%20%22Grand%20Theft%20Auto%20VI%22%20when%3A30d&hl=en-US&gl=US&ceid=US:en")!

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            var request = URLRequest(url: Self.feed, cachePolicy: .reloadIgnoringLocalCacheData)
            request.timeoutInterval = 20
            let (data, _) = try await URLSession.shared.data(for: request)
            let fresh = RSSParser.parse(data)
            guard !fresh.isEmpty else { throw URLError(.cannotParseResponse) }

            if !items.isEmpty {
                let arrived = Set(fresh.map(\.id)).subtracting(items.map(\.id))
                newIDs = arrived
                unseenCount += arrived.count
            }
            withAnimation(.smooth) { items = fresh }
            lastUpdated = .now
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't load news. Check your connection, then pull down to try again."
        }
    }

    func markSeen() { unseenCount = 0 }
}

/// Minimal RSS reader for Google News search feeds.
final class RSSParser: NSObject, XMLParserDelegate {
    private var results: [NewsItem] = []
    private var element = ""
    private var title = "", link = "", guid = "", pubDate = "", source = ""
    private var inItem = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return f
    }()

    static func parse(_ data: Data) -> [NewsItem] {
        let delegate = RSSParser()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.parse()
        var seenTitles = Set<String>()
        return delegate.results
            .sorted { $0.date > $1.date }
            .filter { seenTitles.insert($0.title.lowercased()).inserted }
            .prefix(60)
            .map { $0 }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        element = elementName
        if elementName == "item" {
            inItem = true
            title = ""; link = ""; guid = ""; pubDate = ""; source = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard inItem else { return }
        switch element {
        case "title": title += string
        case "link": link += string
        case "guid": guid += string
        case "pubDate": pubDate += string
        case "source": source += string
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?) {
        element = ""
        guard elementName == "item" else { return }
        inItem = false
        let src = source.trimmingCharacters(in: .whitespacesAndNewlines)
        var headline = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !src.isEmpty, headline.hasSuffix(" - " + src) {
            headline = String(headline.dropLast(src.count + 3))
        }
        guard !headline.isEmpty,
              let url = URL(string: link.trimmingCharacters(in: .whitespacesAndNewlines)) else { return }
        let date = Self.dateFormatter.date(from: pubDate.trimmingCharacters(in: .whitespacesAndNewlines)) ?? .distantPast
        let id = guid.isEmpty ? url.absoluteString : guid.trimmingCharacters(in: .whitespacesAndNewlines)
        results.append(NewsItem(id: id, title: headline, source: src.isEmpty ? "News" : src, link: url, date: date))
    }
}
