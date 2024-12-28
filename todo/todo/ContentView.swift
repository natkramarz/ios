import SwiftUI

private struct Task: Identifiable, Hashable {
    let name: String
    let description: String
    let id: UUID
    
    init(name: String, description: String = "") {
        self.name = name
        self.description = description
        self.id = UUID()
    }
}

struct TaskDetails: View {
    let name: String
    let description: String
    let id: UUID
    
    init(name: String, description: String, id: UUID) {
        self.name = name
        self.description = description
        self.id = id
    }
    
    var body: some View {
        NavigationView {
            VStack {
                    Text(description)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    Spacer()
            }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(systemName: "star")
                            Text(name)
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
        Task(name: "Obrazu na widoku zadania", description: "Dodać wyświetlanie obrazu na widoku zadania"),
        Task(name: "Usuwanie zadań", description: "Dodać usuwanie zadań (swipe)"),
        Task(name: "Zmiana statusu zadania", description: "Dodać zmianę statusu zadania"),
        Task(name: "Wyświetlanie statusu na liście zadań", description: "Dodać wyświetlanie statusu na liście zadań")
    ]
    
    var body: some View {
            NavigationStack {
                List {
                    ForEach(tasks) { task in
                        NavigationLink(value: task) {
                            Text(task.name)
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .navigationDestination(for: Task.self) { task in
                    TaskDetails(name: task.name, description: task.description, id: task.id)
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
