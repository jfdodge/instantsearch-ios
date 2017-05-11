//
//  FacetControlViewModel.swift
//  InstantSearch
//
//  Created by Guy Daher on 11/04/2017.
//
//

import Foundation
import InstantSearchCore

internal class FacetControlViewModel: FacetControlViewModelDelegate, SearchableViewModel {
    
    // MARK: - Properties
    
    var inclusive: Bool {
        return view.inclusive
    }
    
    var attributeName: String {
        return view.attributeName
    }
    
    // MARK: - SearchableViewModel
    
    var searcher: Searcher!
    
    func configure(with searcher: Searcher) {
        self.searcher = searcher
        
        // TODO: A specific facet can have many refinements. But in the case
        // of facetControl (contrary to facetMenu), will we only have at the maximum one value?
        // Right now, taknig the first refinement in getFacetRefinement but can do better...
        // since now we ll have bugs
        if self.searcher.params.hasFacetRefinements(name: self.attributeName) {
            view.set(value: self.searcher.params.getFacetRefinement(name: attributeName)!.value)
        }
        
        view.configureView()
    }
    
    // MARK: - NumericControlViewModelDelegate
    
    weak var view: FacetControlViewDelegate!
    
    func addFacet(value: String, doSearch: Bool) {
        guard !self.searcher.params.hasFacetRefinement(name: self.attributeName, value: value) else { return }
        self.searcher.params.addFacetRefinement(name: self.attributeName, value: value, inclusive: inclusive)
        if doSearch {
            self.searcher.search()
        }
    }
    
    func updatefacet(oldValue: String, newValue: String, doSearch: Bool) {
        self.searcher.params.updatefacetRefinement(attributeName: self.attributeName,
                                                   oldValue: oldValue,
                                                   newValue: newValue,
                                                   inclusive: inclusive)
        
        if doSearch {
            self.searcher.search()
        }
    }
    
    func removeFacet(value: String) {
        self.searcher.params.removeFacetRefinement(name: self.attributeName, value: value)
        self.searcher.search()
    }
}

// MARK: - RefinableDelegate

extension FacetControlViewModel: RefinableDelegate {
    var attribute: String {
        return attributeName
    }
    
    func onRefinementChange(facets: [FacetRefinement]) {
        for facet in facets where facet.name == self.attributeName {
            view.set(value: facet.value)
            return
        }
        
        // Could not find it anymore, so need to notify!
        view.set(value: "")
    }
    
}

// MARK: - ResettableDelegate

extension SearchParameters {
    
    func getFacetRefinement(name facetName: String) -> FacetRefinement? {
        return facetRefinements[facetName]?.first
    }
    
    func getNumericRefinement(name filterName: String,
                              operation: NumericRefinement.Operator,
                              inclusive: Bool = true) -> NumericRefinement? {
        return numericRefinements[filterName]?.first(where: { $0.op == operation && $0.inclusive == inclusive})
    }
    
    func updatefacetRefinement(attributeName: String, oldValue: String, newValue: String, inclusive: Bool = true) {
        guard !hasFacetRefinement(name: attributeName, value: newValue) else { return }
        removeFacetRefinement(name: attributeName, value: oldValue)
        addFacetRefinement(name: attributeName, value: newValue, inclusive: inclusive)
    }
}
