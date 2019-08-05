//
//  FetchMoviesUseCaseTests.swift
//  CodeChallengeTests
//
//  Created by Oleh Kudinov on 01.10.18.
//

import XCTest

class FetchMoviesUseCaseTests: XCTestCase {
    
    static var moviesPages: [MoviesPage] {
        let page1 = MoviesPage(page: 1, totalPages: 2, movies: [
            Movie(id: 1, title: "title1", posterPath: "/1", overview: "overview1", releaseDate: nil),
            Movie(id: 2, title: "title2", posterPath: "/2", overview: "overview2", releaseDate: nil)])
        let page2 = MoviesPage(page: 2, totalPages: 2, movies: [
            Movie(id: 3, title: "title3", posterPath: "/3", overview: "overview3", releaseDate: nil)])
        return [page1, page2]
    }
    
    enum MoviesDataSourceSuccessTestError: Error {
        case failedFetching
    }
    
    class MoviesQueriesDataSourceMock: MoviesQueriesDataSourceInterface {
        var recentQueries: [MovieQuery] = []
        func recentsQueries(number: Int) -> [MovieQuery] {
            return recentQueries
        }
        func saveRecentQuery(query: MovieQuery) {
            recentQueries.append(query)
        }
    }
    
    class MoviesDataSourceSuccessMock: MoviesDataSourceInterface {
        func moviesList(query: MovieQuery, page: Int, with result: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
            result(.success(FetchMoviesUseCaseTests.moviesPages[0]))
            return nil
        }
    }
    
    class MoviesDataSourceFailureMock: MoviesDataSourceInterface {
        func moviesList(query: MovieQuery, page: Int, with result: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
            result(.failure(MoviesDataSourceSuccessTestError.failedFetching))
            return nil
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchMoviesUseCase_whenSuccessfullyFetchesMoviesForQuery_thenQueryIsSavedInRecentQueries() {
        // given
        let expectation = self.expectation(description: "Recent query saved")
        let moviesQueriesDataSource = MoviesQueriesDataSourceMock()
        let useCase = FetchMoviesUseCase(moviesDataSource: MoviesDataSourceSuccessMock(),
                                         moviesQueriesDataSource: moviesQueriesDataSource)
        
        // when
        let requestValue = FetchMoviesUseCaseRequestValue(query: MovieQuery(query: "title1"),
                                                          page: 0)
        _ = useCase.execute(requestValue: requestValue) { movies in
            expectation.fulfill()
        }
        // then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(moviesQueriesDataSource.recentsQueries(number: 1).contains(MovieQuery(query: "title1")))
    }
    
    func testFetchMoviesUseCase_whenFailedFetchingMoviesForQuery_thenQueryIsNotSavedInRecentQueries() {
        // given
        let expectation = self.expectation(description: "Recent query saved")
        let moviesQueriesDataSource = MoviesQueriesDataSourceMock()
        let useCase = FetchMoviesUseCase(moviesDataSource: MoviesDataSourceFailureMock(),
                                         moviesQueriesDataSource: moviesQueriesDataSource)
        
        // when
        let requestValue = FetchMoviesUseCaseRequestValue(query: MovieQuery(query: "title1"),
                                                          page: 0)
        _ = useCase.execute(requestValue: requestValue) { movies in
            expectation.fulfill()
        }
        // then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(moviesQueriesDataSource.recentsQueries(number: 1).isEmpty)
    }
}
