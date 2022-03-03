import Apollo
import Combine
import UIKit

final class RepositoriesListViewModel {
    
    private let client: GraphQLClient
    var currentPageInfo: SearchRepositoriesQuery.Data.Search.PageInfo?
    
    @Published var isLoading: Bool = false
    @Published var error: String = ""
    @Published var repositories: [RepositoryDetails] = []

    init(client: GraphQLClient = ApolloClient.shared) {
        self.client = client
    }
    
    func fetchCellViewModel(indexPath: IndexPath) -> RepositoriesListCellViewModel {
        return RepositoriesListCellViewModel(with: repositories[indexPath.row])
    }
    
    func fetchRepositoryDetails(indexPath: IndexPath) -> RepositoryDetails {
        return repositories[indexPath.row]
    }

    func search(phrase: String) {
        self.isLoading = true
        self.client.searchRepositories(mentioning: phrase) {[weak self] response in
            switch response {
                case let .failure(error):
                self?.error = error.localizedDescription
                case let .success(results):
                self?.currentPageInfo = results.pageInfo
                self?.repositories = results.repos
                self?.isLoading = false
            }
        }
    }
}

final class RepositoriesListCellViewModel {
    let userName: String
    let repositoryName: String
    let userImageUrl: URL?
    let stars: NSMutableAttributedString
    
    init(with model: RepositoryDetails) {
        self.repositoryName = "Name: \(model.name)"
        self.userName = "User: \(model.owner.login)"
        self.userImageUrl = URL(string: model.owner.avatarUrl)
        let mutableString = NSMutableAttributedString(attachment: NSTextAttachment(image: UIImage(systemName: "star")!))
        mutableString.append(NSAttributedString(string: " \(model.stargazers.totalCount)"))
        self.stars = mutableString
    }
    
}
