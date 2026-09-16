import Foundation

@main
struct DailyTodoTests {
    @MainActor static func main() {
        let suite = "DailyTodoTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2026, month: 9, day: 16, hour: 12))!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let store = TodoStore(defaults: defaults)
        precondition(!store.add(" \n ", on: today))
        store.add("最早", on: today)
        store.add("中间", on: today)
        store.add(" 最新 ", on: today)
        store.add("明天", on: tomorrow)
        precondition(store.todos(on: today).map(\.title) == ["最新", "中间", "最早"])
        let latest = store.todos(on: today)[0].id
        store.toggle(latest)
        precondition(store.todos(on: today).map(\.title) == ["中间", "最早", "最新"])
        let middle = store.todos(on: today)[0].id
        store.toggle(middle)
        precondition(store.todos(on: today).map(\.title) == ["最早", "最新", "中间"])
        store.toggle(latest)
        precondition(store.todos(on: today).map(\.title) == ["最新", "最早", "中间"])
        let restored = TodoStore(defaults: defaults)
        precondition(restored.todos(on: today) == store.todos(on: today))
        precondition(restored.todos(on: tomorrow).map(\.title) == ["明天"])
        precondition(TodoStore.dayKey(for: today) == "2026-09-16")
        store.delete(latest)
        precondition(store.todos(on: today).map(\.title) == ["最早", "中间"])
        store.delete(middle)
        precondition(store.todos(on: today).map(\.title) == ["最早"])
        let afterDelete = TodoStore(defaults: defaults)
        precondition(afterDelete.todos(on: today) == store.todos(on: today))
        precondition(afterDelete.todos(on: tomorrow).map(\.title) == ["明天"])
        store.delete(UUID())
        precondition(store.todos(on: today).count == 1)
        print("PASS: deletion of active/completed items, persisted deletion, other dates preserved; empty input, creation order, completion grouping, undo, date isolation and persistence")
    }
}
