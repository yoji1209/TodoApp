import SwiftUI

struct ContentView: View {
    @State private var newTask: String = ""     // 入力用テキスト
    @State private var tasks: [String] = []     // タスクを保持する配列

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("新しいタスクを入力", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button(action: {
                        if !newTask.isEmpty {
                            tasks.append(newTask)   // 配列に追加
                            newTask = ""            // 入力欄をクリア
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                }

                List {
                    ForEach(tasks, id: \.self) { task in
                        Text(task)
                    }
                }
            }
            .navigationTitle("Todoリスト")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

