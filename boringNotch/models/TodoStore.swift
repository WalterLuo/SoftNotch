import Combine
import Foundation

struct DailyTodo: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    // A calendar date, not a timestamp: travelling across time zones must not move tasks.
    let day: String
    let createdAt: Date
    var isCompleted: Bool
}

@MainActor
final class TodoStore: ObservableObject {
    static let shared = TodoStore()
    @Published private(set) var items: [DailyTodo]
    private let defaults: UserDefaults
    private let key = "dailyTodos.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        items =
            defaults.data(forKey: key).flatMap {
                try? JSONDecoder().decode([DailyTodo].self, from: $0)
            } ?? []
    }

    static func dayKey(for date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
    }

    func todos(on date: Date) -> [DailyTodo] {
        let matching = items.filter { $0.day == Self.dayKey(for: date) }
        // Items are stored newest first. Stable partition preserves creation order in both groups.
        return matching.filter { !$0.isCompleted } + matching.filter { $0.isCompleted }
    }

    @discardableResult
    func add(_ title: String, on date: Date) -> Bool {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return false }
        items.insert(
            DailyTodo(
                id: UUID(), title: title, day: Self.dayKey(for: date),
                createdAt: Date(), isCompleted: false), at: 0)
        save()
        return true
    }

    @discardableResult
    func updateTitle(_ id: UUID, to title: String) -> Bool {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, let index = items.firstIndex(where: { $0.id == id }) else { return false }
        items[index].title = title
        save()
        return true
    }

    func toggle(_ id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isCompleted.toggle()
        save()
    }

    func delete(_ id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: key)
    }
}
