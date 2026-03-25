import Foundation
import Combine

final class AppDataStore: ObservableObject {
    @Published var members: [Member] = Member.mockMembers
    @Published var projects: [Project] = Project.mockProjects
}
