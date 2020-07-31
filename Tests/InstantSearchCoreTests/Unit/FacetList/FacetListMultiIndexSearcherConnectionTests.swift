//
//  FacetListMultiIndexSearcherConnectionTests.swift
//  
//
//  Created by Vladislav Fitc on 29/07/2020.
//

import Foundation
@testable import InstantSearchCore
import XCTest

class FacetListMultiIndexSearcherConnectionTests: XCTestCase {

  let attribute: Attribute = "Test Attribute"
  let facets: [Facet] = .init(prefix: "v", count: 3)
  
  weak var disposableSearcher: MultiIndexSearcher?
  weak var disposableInteractor: FacetListInteractor?
  
  func testLeak() {
    let searcher = MultiIndexSearcher(appID: "", apiKey: "", indexNames: [""])
    let interactor = FacetListInteractor()
    
    disposableSearcher = searcher
    disposableInteractor = interactor

    let connection = FacetListInteractor.MultiIndexSearcherConnection(facetListInteractor: interactor, searcher: searcher, queryIndex: 0, attribute: attribute)
    connection.connect()
  }
  
  override func tearDown() {
    XCTAssertNil(disposableSearcher, "Leaked searcher")
    XCTAssertNil(disposableInteractor, "Leaked interactor")
  }

  func testConnect() {
    let searcher = MultiIndexSearcher(appID: "", apiKey: "", indexNames: [""])
    let interactor = FacetListInteractor()

    let connection = FacetListInteractor.MultiIndexSearcherConnection(facetListInteractor: interactor, searcher: searcher, queryIndex: 0, attribute: attribute)
    connection.connect()

    checkConnection(interactor: interactor,
                    searcher: searcher,
                    isConnected: true)
  }

  func testConnectMethod() {
    let searcher = MultiIndexSearcher(appID: "", apiKey: "", indexNames: [""])
    let interactor = FacetListInteractor()

    interactor.connectSearcher(searcher, toQueryAtIndex: 0, with: attribute)

    checkConnection(interactor: interactor,
                    searcher: searcher,
                    isConnected: true)
  }

  func testDisconnect() {
    let searcher = MultiIndexSearcher(appID: "", apiKey: "", indexNames: [""])
    let interactor = FacetListInteractor()

    let connection = FacetListInteractor.MultiIndexSearcherConnection(facetListInteractor: interactor, searcher: searcher, queryIndex: 0, attribute: attribute)
    connection.connect()
    connection.disconnect()

    checkConnection(interactor: interactor,
                    searcher: searcher,
                    isConnected: false)
  }

  func checkConnection(interactor: FacetListInteractor,
                       searcher: MultiIndexSearcher,
                       isConnected: Bool) {
    
    var response1 = SearchResponse(hits: [TestRecord<Int>]())
    let response1Facets: [Facet] = .init(prefix: "a", count: 4)
    response1.disjunctiveFacets = [attribute: response1Facets]
    
    var response2 = SearchResponse(hits: [TestRecord<String>]())
    response2.disjunctiveFacets = ["b": .init(prefix: "b", count: 5)]

    do {
      let response = try SearchesResponse(json: ["results": [try JSON(response1), try JSON(response2)]])

      let onItemsChangedExpectation = expectation(description: "on items changed")
      onItemsChangedExpectation.isInverted = !isConnected

      interactor.onItemsChanged.subscribe(with: self) { (test, facets) in
        XCTAssertEqual(Set(response1Facets), Set(facets))
        onItemsChangedExpectation.fulfill()
      }

      searcher.onResults.fire(response)

      waitForExpectations(timeout: 5, handler: .none)

    } catch let error {
      XCTFail("\(error)")
    }
  }

}
