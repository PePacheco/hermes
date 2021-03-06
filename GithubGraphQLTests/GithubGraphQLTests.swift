@testable import GithubGraphQL
import XCTest

class GithubGraphQLTests: XCTestCase {
    
    var viewModel: RepositoriesListViewModel?

    override func setUp() {
        super.setUp()
        let mockedResponse = SearchRepositoriesQuery.Data(search: .init(
            pageInfo: .init(startCursor: "startCursor", endCursor: nil, hasNextPage: false, hasPreviousPage: false),
            edges: makeEdges(count: 3)
        ))
        viewModel = RepositoriesListViewModel(client: MockGraphQLClient<SearchRepositoriesQuery>(response: mockedResponse))
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }

    func testViewModelInitDisplayAttributes() {
        XCTAssert(viewModel!.isLoading == false)
        XCTAssert(viewModel!.error.isEmpty)
    }
    
    func testViewModelInitSearchAttributes() {
        XCTAssert(viewModel!.repositories.isEmpty)
        XCTAssert(viewModel!.currentPageInfo == nil)
    }
    
    func testViewModelFetching() {
        viewModel!.search(phrase: "graphql")
        XCTAssert(viewModel!.repositories.count == 3)
        XCTAssert(viewModel!.currentPageInfo != nil)
    }
    
    func testViewModelRemovingDuplicates() {
        let repositories = [
            RepositoryDetails(name: "Test Name", url: "Test URL", owner: RepositoryDetails.Owner.init(unsafeResultMap: ["avatarUrl": "https://d2z5w7rcu7bmie.cloudfront.net/assets/images/logo.png", "__typename": "Organization", "login": "Test Login"]), stargazers: RepositoryDetails.Stargazer.init(totalCount: 8)),
            RepositoryDetails(name: "Test Name2", url: "Test URL2", owner: RepositoryDetails.Owner.init(unsafeResultMap: ["avatarUrl": "https://d2z5w7rcu7bmie.cloudfront.net/assets/images/logo.png", "__typename": "Organization", "login": "Test Login2"]), stargazers: RepositoryDetails.Stargazer.init(totalCount: 10)),
            RepositoryDetails(name: "Test Name", url: "Test URL", owner: RepositoryDetails.Owner.init(unsafeResultMap: ["avatarUrl": "https://d2z5w7rcu7bmie.cloudfront.net/assets/images/logo.png", "__typename": "Organization", "login": "Test Login"]), stargazers: RepositoryDetails.Stargazer.init(totalCount: 8))
        ]
        let repositoriesWithoutDuplicates = viewModel!.removeDuplicateElements(repositories: repositories)
        XCTAssert(repositoriesWithoutDuplicates.count == 2)
        
    }
    
    func testViewModelCellFetching() {
        viewModel!.search(phrase: "graphql")
        let cellViewModel = viewModel!.fetchCellViewModel(indexPath: IndexPath(row: 1, section: 1))
        XCTAssert(cellViewModel.repositoryName == "Name: makeEdges(count:_:)-1")
        XCTAssert(cellViewModel.url == "URL: https://github.com/peek/makeEdges(count:_:)-1")
    }

    func testPerformanceRepositoriesFetching() {
        let viewModelNotMocked = RepositoriesListViewModel()
        self.measure {
            viewModelNotMocked.search(phrase: "graphql")
        }
    }

}
