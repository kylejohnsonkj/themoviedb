//
//  MovieFetcherTests.swift
//  TheMovieDBTests
//
//  Created by Kyle Johnson on 7/10/23.
//

import XCTest
@testable import TheMovieDB

class MovieFetcherTests: XCTestCase {
    
    func testGetMovies() {
        let expectation = XCTestExpectation(description: "Fetch movies")
        let fetcher = MovieFetcher()
        let avengersSearchText = "Avengers"
        Task {
            do {
                let movies = try await fetcher.getMovies(searchText: avengersSearchText)
                XCTAssertFalse(movies.isEmpty, "Movies list should not be empty")
            } catch {
                XCTFail("getMovies threw an error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testGetMoviesEmptyQuery() {
        let expectation = XCTestExpectation(description: "Fetch movies")
        let fetcher = MovieFetcher()
        let emptySearchText = ""
        Task {
            do {
                let movies = try await fetcher.getMovies(searchText: emptySearchText)
                XCTAssertTrue(movies.isEmpty, "Movies list should be empty")
            } catch {
                XCTFail("getMovies threw an error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testGetMoviePoster() {
        let expectation = XCTestExpectation(description: "Fetch movie poster")
        let movieService = MovieFetcher()
        let infinityWarPosterPath = "/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg"
        Task {
            do {
                let image = try await movieService.getMoviePoster(posterPath: infinityWarPosterPath)
                XCTAssertNotNil(image, "Image should not be nil")
            } catch {
                XCTFail("getMoviePoster threw an error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
}
