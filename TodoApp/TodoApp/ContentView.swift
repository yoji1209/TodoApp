import SwiftUI

// 1) モデルを定義（Identifiable + Codable）
struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isDone: Bool
    var createdAt: Date

    init(id: UUID = UUID(), title: String, isDone: Bool = false, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.createdAt = createdAt
    }
}

struct ContentView: View {
    @State private var newTask: String = ""

    // 2) 永続化されたタスクを読み書き（UserDefaults）
    @State private var tasks: [TaskItem] = [] {
        didSet { saveTasks() }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("新しいタスクを入力", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button {
                        let title = newTask.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !title.isEmpty else { return }
                        tasks.insert(TaskItem(title: title), at: 0) // 先頭に追加
                        newTask = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundStyle(.blue)
                    }
                    .padding(.trailing)
                    .accessibilityLabel("タスクを追加")
                }

                if tasks.isEmpty {
                    ContentUnavailableView("タスクはまだありません", systemImage: "checklist", description: Text("上の欄に入力して「＋」で追加"))
                        .padding(.top, 40)
                } else {
                    List {
                        ForEach($tasks) { $task in
                            HStack {
                                Button {
                                    task.isDone.toggle()
                                } label: {
                                    Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                        .imageScale(.large)
                                }
                                .buttonStyle(.plain)

                                Text(task.title)
                                    .strikethrough(task.isDone)
                                    .foregroundStyle(task.isDone ? .secondary : .primary)

                                Spacer()

                                // 簡易編集（タイトルだけ）
                                Menu {
                                    Button("タイトルを編集") { edit(task: task) }
                                    Button(role: .destructive) { delete(task: task) } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .imageScale(.large)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .onDelete { indexSet in
                            tasks.remove(atOffsets: indexSet)
                        }
                        .onMove { from, to in
                            tasks.move(fromOffsets: from, toOffset: to)
                        }
                    }
                }
            }
            .navigationTitle("Todoリスト")
            .toolbar { EditButton() }
            .onAppear(perform: loadTasks)
        }
    }

    // MARK: - 編集 / 削除ユーティリティ
    private func edit(task: TaskItem) {
        // 超シンプルな編集ダイアログ（タイトルのみ）
        var newTitle = task.title
        let alert = UIAlertController(title: "タイトルを編集", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "タイトル"
            tf.text = task.title
        }
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default, handler: { _ in
            newTitle = alert.textFields?.first?.text ?? task.title
            update(taskID: task.id, title: newTitle)
        }))

        // UIKitアラートを表示
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(alert, animated: true)
    }

    private func delete(task: TaskItem) {
        if let idx = tasks.firstIndex(of: task) {
            tasks.remove(at: idx)
        }
    }

    private func update(taskID: UUID, title: String) {
        guard let idx = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        var t = tasks[idx]
        t.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        tasks[idx] = t
    }

    // MARK: - 永続化（UserDefaults）
    private let storageKey = "TASKS_V1"

    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("保存失敗: \(error)")
        }
    }

    private func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            print("読込失敗: \(error)")
        }
    }
}

// 小さなUIKitブリッジ（編集用アラートに使用）
private extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

