import Apollo
import Foundation

struct RepositorySearchResult {
  let pageInfo: SearchRepositoriesQuery.Data.Search.PageInfo
  let repos: [RepositoryDetails]
}

enum SearchError: Error {
  case missingData
  case graphQLErrors([Error])
}

extension GraphQLClient {
  /// Searches for repositories mentioning the provided phrase, returning the desired results or an error.
  /// - Parameters:
  ///   - phrase: The phrase to search repositories with.
  ///   - filter: The optional filter to use when searching. By default it will fetch the first `n` results, where `n` is ``SearchRepositoriesQuery/Filter/defaultLimit``.
  ///   - contextIdentifier: An optional identifier to uniquely identify this request.
  ///   - queue: An optional queue to invoke the resultHandler on
  ///   - resultHandler: An optional handler to receive the result of the request or failure.
  /// - Returns: A cancellation token for canceling the in-progess request.
  @discardableResult
  func searchRepositories(
    mentioning phrase: String,
    filter: SearchRepositoriesQuery.Filter? = nil,
    cachePolicy: CachePolicy = .returnCacheDataAndFetch,
    contextIdentifier: UUID? = nil,
    queue: DispatchQueue = .main,
    resultHandler: @escaping (Result<RepositorySearchResult, Error>) -> Void
  ) -> Cancellable {
    let query: SearchRepositoriesQuery = filter.map {
      switch $0.direction {
      case .forward:
        return .init(query: phrase, first: $0.limit, last: nil, before: $0.cursor?.rawValue, after: nil)

      case .backward:
        return .init(query: phrase, first: nil, last: $0.limit, before: nil, after: $0.cursor?.rawValue)
      }
    } ?? .init(query: phrase, first: SearchRepositoriesQuery.Filter.defaultLimit, last: nil, before: nil, after: nil)

    return self.fetch(
      query: query,
      cachePolicy: cachePolicy,
      contextIdentifier: contextIdentifier,
      queue: queue,
      resultHandler: {
        do {
          let result = try $0.get()
            print(result)

          guard let data = result.data else {
            let error = result.errors.map { SearchError.graphQLErrors($0) }
            resultHandler(.failure(error ?? .missingData))
            return
          }

          let repos = data.search.edges
            .flatMap { $0.compactMap(\.?.node?.asRepository?.fragments.repositoryDetails) }
            ?? []
          resultHandler(.success(.init(pageInfo: data.search.pageInfo, repos: repos)))
        } catch {
          resultHandler(.failure(error))
        }
      }
    )
  }
}
