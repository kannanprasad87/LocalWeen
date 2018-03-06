//
//  SearchViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/6/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

/*
 * Copyright 2017 Google Inc. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import UIKit
import GooglePlaces

class SearchViewController: UIViewController {
        
        var resultsViewController: GMSAutocompleteResultsViewController?
        var searchController: UISearchController?
        var resultView: UITextView?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            resultsViewController = GMSAutocompleteResultsViewController()
            resultsViewController?.delegate = self as GMSAutocompleteResultsViewControllerDelegate
            
            searchController = UISearchController(searchResultsController: resultsViewController)
            searchController?.searchResultsUpdater = resultsViewController
            
            // Put the search bar in the navigation bar.
            searchController?.searchBar.sizeToFit()
            navigationItem.titleView = searchController?.searchBar
            
            // When UISearchController presents the results view, present it in
            // this view controller, not one further up the chain.
            definesPresentationContext = true
            
            // Prevent the navigation bar from being hidden when searching.
            searchController?.hidesNavigationBarDuringPresentation = false
        }
    }
    
    // Handle the user's selection.
    extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
        func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                               didAutocompleteWith place: GMSPlace) {
            searchController?.isActive = false
            // Do something with the selected place.
            print("Place name: \(place.name)")
            print("Place address: \(String(describing: place.formattedAddress))")
            print("Place attributions: \(String(describing: place.attributions))")
        }
        
        func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                               didFailAutocompleteWithError error: Error){
            // TODO: handle the error.
            print("Error: ", error.localizedDescription)
        }
        
        // Turn the network activity indicator on and off again.
        func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
}
