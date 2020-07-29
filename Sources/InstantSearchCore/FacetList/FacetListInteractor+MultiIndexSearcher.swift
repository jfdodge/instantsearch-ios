//
//  FacetListInteractor+MultiIndexSearcher.swift
//  
//
//  Created by Vladislav Fitc on 29/07/2020.
//

import Foundation
import AlgoliaSearchClient

public extension FacetListInteractor {
  
  struct MultiIndexSearcherConnection: Connection {
    
    public let facetListInteractor: FacetListInteractor
    public let searcher: MultiIndexSearcher
    public let queryIndex: Int
    public let attribute: Attribute
    
    public func connect() {
      // When new search results then update items

      searcher.onResults.subscribePast(with: facetListInteractor) { [queryIndex, attribute] (interactor, searchResultList) in
        let searchResults = searchResultList.results[queryIndex]
        interactor.items = searchResults.disjunctiveFacets?[attribute] ?? searchResults.facets?[attribute] ?? []
      }
      
      searcher.indexQueryStates[queryIndex].query.updateQueryFacets(with: attribute)
    }
    
    public func disconnect() {
      searcher.onResults.cancelSubscription(for: facetListInteractor)
    }
    
  }
  
}

public extension FacetListInteractor {
  
  @discardableResult func connectSearcher(_ searcher: MultiIndexSearcher,
                                          toQueryAtIndex queryIndex: Int,
                                          with attribute: Attribute) -> MultiIndexSearcherConnection {
    let connection = MultiIndexSearcherConnection(facetListInteractor: self,
                                                  searcher: searcher,
                                                  queryIndex: queryIndex,
                                                  attribute: attribute)
    connection.connect()
    return connection
  }

}
