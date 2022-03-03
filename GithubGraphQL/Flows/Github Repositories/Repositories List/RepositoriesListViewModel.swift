import Apollo
import Combine

final class RepositoriesListViewModel {
    
    private let client: GraphQLClient
    
    @Published var isLoading: Bool = false
    @Published var currentPageInfo: SearchRepositoriesQuery.Data.Search.PageInfo?
    @Published var repositories: [RepositoryDetails] = []

    init(client: GraphQLClient = ApolloClient.shared) {
        self.client = client
    }

    func search(phrase: String) {
        self.isLoading = true
        self.client.searchRepositories(mentioning: phrase) {[weak self] response in
            switch response {
                case let .failure(error):
                print(error)
                case let .success(results):
                self?.repositories = results.repos
                self?.isLoading = false
                results.repos.forEach { repository in
                    print(repository)
                }
            }
        }
    }
}
