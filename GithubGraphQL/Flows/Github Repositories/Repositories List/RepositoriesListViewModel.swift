import Apollo
import Combine
import UIKit

final class RepositoriesListViewModel {
    
    private let client: GraphQLClient
//    private let queue = DispatchQueue(label: "ViewModelQueue", target: .global())
    var currentPageInfo: SearchRepositoriesQuery.Data.Search.PageInfo?
    
    @Published var isLoading: Bool = false
    @Published var error: String = ""
    @Published var repositories: [RepositoryDetails] = []
    @Published var isFetchingForward: Bool = false

    init(client: GraphQLClient = ApolloClient.shared) {
        self.client = client
    }
    
    func fetchCellViewModel(indexPath: IndexPath) -> RepositoriesListCellViewModel {
        return RepositoriesListCellViewModel(with: repositories[indexPath.row])
    }
    
    func fetchRepositoryDetails(indexPath: IndexPath) -> RepositoryDetails {
        return repositories[indexPath.row]
    }
    
    func searchForward(phrase: String) {
        guard let currentPageInfo = currentPageInfo, let nextCursor = currentPageInfo.endCursor else {
            return
        }
        self.isFetchingForward = true
        if currentPageInfo.hasNextPage {
            let cursor = Cursor(rawValue: nextCursor)
            let filter = SearchRepositoriesQuery.Filter.before(cursor)
            self.client.searchRepositories(mentioning: phrase, filter: filter) {[weak self] response in
                guard let self = self else { return }
                switch response {
                    case .failure:
                    self.error = "There are no more repositories available"
                    case .success(let results):
                    self.currentPageInfo = results.pageInfo
                    self.repositories.append(contentsOf: results.repos)
                    self.repositories = self.removeDuplicateElements(repositories: self.repositories)
                    self.isFetchingForward = false
                }
            }
        }
    }
    
    func removeDuplicateElements(repositories: [RepositoryDetails]) -> [RepositoryDetails] {
        var uniqueRepositories = [RepositoryDetails]()
        for repository in repositories {
            if !uniqueRepositories.contains(where: { $0.name == repository.name && $0.owner.login == repository.owner.login && $0.stargazers.totalCount == repository.stargazers.totalCount  }) {
                uniqueRepositories.append(repository)
            }
        }
        return uniqueRepositories
    }

    func search(phrase: String) {
        self.isLoading = true
        self.client.searchRepositories(mentioning: phrase) {[weak self] response in
            self?.isLoading = false
            switch response {
                case .failure:
                self?.error = "The data could not be fetched, something went wrong"
                case .success(let results):
                print(results)
                self?.currentPageInfo = results.pageInfo
                self?.repositories = results.repos
            }
        }
    }
}

final class RepositoriesListCellViewModel {
    let url: String
    let repositoryName: String
    let userImageUrl: URL?
    let stars: NSMutableAttributedString
    
    init(with model: RepositoryDetails) {
        self.repositoryName = "Name: \(model.name)"
        self.url = "URL: \(model.url)"
        self.userImageUrl = URL(string: model.owner.avatarUrl)
        let mutableString = NSMutableAttributedString(attachment: NSTextAttachment(image: UIImage(systemName: "star")!))
        mutableString.append(NSAttributedString(string: " \(model.stargazers.totalCount)"))
        self.stars = mutableString
    }
    
}
