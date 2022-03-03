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
    
    func testViewModelCellFetching() {
        viewModel!.search(phrase: "graphql")
        let cellViewModel = viewModel!.fetchCellViewModel(indexPath: IndexPath(row: 1, section: 1))
        print(cellViewModel.url)
        XCTAssert(cellViewModel.url == "URL: https://github.com/peek/makeEdges(count:_:)-1")
    }

    func testPerformanceRepositoriesFetching() {
        let viewModelNotMocked = RepositoriesListViewModel()
        self.measure {
            viewModelNotMocked.search(phrase: "graphql")
        }
    }

}
