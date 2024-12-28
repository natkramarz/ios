import SwiftUI

enum TaskStatus: String, CaseIterable, Hashable {
    case todo = "todo"
    case inProgress = "In Progress"
    case done = "Done"
}

struct Task: Identifiable, Hashable {
    let name: String
    let description: String
    let id: UUID
    var status: TaskStatus

    init(name: String, description: String = "", status: TaskStatus = .todo) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.status = status
    }
}

struct TaskDetails: View {
    @Binding var task: Task
    
    var body: some View {
        NavigationView {
            VStack {
                Text(task.description)
                        .foregroundColor(.secondary)
                Picker("Status", selection: $task.status) {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text(task.name)
                                .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var tasks: [Task] = [
        Task(name: "Z góry określone zadania", description: "Dodać listę z góry określonych zadań"),
        Task(name: "Obraz na widoku zadania", description: "Dodać wyświetlanie obrazu na widoku zadania"),
        Task(name: "Usuwanie zadań", description: "Dodać usuwanie zadań (swipe)"),
        Task(name: "Zmiana statusu zadania", description: "Dodać zmianę statusu zadania"),
        Task(name: "Wyświetlanie statusu na liście zadań", description: "Dodać wyświetlanie statusu na liście zadań")
    ]
    
    var body: some View {
            NavigationStack {
                List {
                    ForEach($tasks) { $task in
                        NavigationLink(value: task) {
                            HStack {
                                Text(task.status.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(task.name)
                            }
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .navigationDestination(for: Task.self) { task in
                        if let binding = $tasks.first(where: { $0.id == task.id }) {
                            TaskDetails(task: binding)
                        }
                    }
                .navigationTitle("Lista zadań")
            }
    }
    
    private func deleteTask(at offsets: IndexSet) {
            tasks.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
