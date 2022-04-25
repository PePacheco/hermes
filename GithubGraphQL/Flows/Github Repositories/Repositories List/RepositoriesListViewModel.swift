import Apollo
import UIKit
import RxSwift
import RxRelay

final class RepositoriesListViewModel {
    
    private let client: GraphQLClient
    var currentPageInfo: SearchRepositoriesQuery.Data.Search.PageInfo?
    
    private var isLoading: BehaviorRelay<Bool> = .init(value: false)
    var isLoadingObservable: Observable<Bool> {
        return self.isLoading.asObservable()
    }
    
    private var repositories: BehaviorRelay<[RepositoryDetails]> = .init(value: [])
    var repositoriesObservable: Observable<[RepositoryDetails]> {
        return self.repositories.asObservable()
    }
    
    private var error: BehaviorRelay<String> = .init(value: "")
    var errorObservable: Observable<String> {
        return error.asObservable()
    }
    
    private var isFetchingForward: BehaviorRelay<Bool> = .init(value: false)
    var isFetchingForwardObservable: Observable<Bool> {
        return isFetchingForward.asObservable()
    }

    init(client: GraphQLClient = ApolloClient.shared) {
        self.client = client
    }
    
    func getRepositoriesCount() -> Int {
        return self.repositories.value.count
    }
    
    func searchForward(phrase: String) {
        guard let currentPageInfo = currentPageInfo, let nextCursor = currentPageInfo.endCursor else {
            return
        }
        self.isFetchingForward.accept(true)
        if currentPageInfo.hasNextPage {
            let cursor = Cursor(rawValue: nextCursor)
            let filter = SearchRepositoriesQuery.Filter.before(cursor)
            self.client.searchRepositories(mentioning: phrase, filter: filter) {[weak self] response in
                guard let self = self else { return }
                switch response {
                    case .failure:
                    self.error.accept("There are no more repositories available")
                    case .success(let results):
                    self.currentPageInfo = results.pageInfo
                    let allRepositories = self.repositories.value + results.repos
                    let repositoriesNotDoubled = self.removeDuplicateElements(repositories: allRepositories)
                    self.repositories.accept(repositoriesNotDoubled)
                    self.isFetchingForward.accept(false)
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
        self.isLoading.accept(true)
        self.client.searchRepositories(mentioning: phrase) {[weak self] response in
            self?.isLoading.accept(false)
            switch response {
                case .failure:
                self?.error.accept("The data could not be fetched, something went wrong")
                case .success(let results):
                self?.currentPageInfo = results.pageInfo
                self?.repositories.accept(results.repos)
            }
        }
    }
    
    func fetchCellViewModel(at indexPath: IndexPath) -> RepositoriesListCellViewModel {
        return RepositoriesListCellViewModel(with: self.repositories.value[indexPath.row])
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
