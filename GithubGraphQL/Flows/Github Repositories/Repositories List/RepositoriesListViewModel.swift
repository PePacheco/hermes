import Apollo
import Combine
import Foundation

final class RepositoriesListViewModel {
    
    private let client: GraphQLClient
    var currentPageInfo: SearchRepositoriesQuery.Data.Search.PageInfo?
    
    @Published var isLoading: Bool = false
    @Published var repositories: [RepositoryDetails] = []

    init(client: GraphQLClient = ApolloClient.shared) {
        self.client = client
    }
    
    func fetchCellViewModel(indexPath: IndexPath) -> RepositoriesListCellViewModel {
        return RepositoriesListCellViewModel(with: repositories[indexPath.row])
    }

    func search(phrase: String) {
        self.isLoading = true
        self.client.searchRepositories(mentioning: phrase) {[weak self] response in
            switch response {
                case let .failure(error):
                print(error)
                case let .success(results):
                self?.currentPageInfo = results.pageInfo
                self?.repositories = results.repos
                self?.isLoading = false
            }
        }
    }
}

final class RepositoriesListCellViewModel {
    let url: String
    let userName: String
    let repositoryName: String
    let userImageUrl: URL?
    
    init(with model: RepositoryDetails) {
        self.url = "URL: \(model.url)"
        self.repositoryName = "Repository name: \(model.name)"
        self.userName = "User: \(model.owner.login)"
        self.userImageUrl = URL(string: model.owner.avatarUrl)
    }
    
}
