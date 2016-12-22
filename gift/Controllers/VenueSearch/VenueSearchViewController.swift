//
// Created by Matan Lachmish on 21/12/2016.
// Copyright (c) 2016 GiftApp. All rights reserved.
//

import Foundation
import UIKit

class VenueSearchViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {

    //Injections
    private var appRoute: AppRoute
    private var venueService: VenueService
    private var locationManager: LocationManager
    private var venueSearchResultsViewController: VenueSearchResultsViewController

    //Views
    private var venueSearchView: VenueSearchView!

    //Controllers
    private var searchController: UISearchController!

    //Private Properties
    private var nearbyVenues: Array<Venue> = [] {
        didSet {
            venueSearchView.update()
        }
    }

    private var currentLocation: (lat: Double, lng: Double)! {
        didSet {
            venueSearchView.update()
        }
    }

    private var searchPaceTimer: Timer?

    //-------------------------------------------------------------------------------------------
    // MARK: - Initialization & Destruction
    //-------------------------------------------------------------------------------------------
    internal dynamic init(appRoute: AppRoute,
                          venueService: VenueService,
                          locationManager: LocationManager,
                          venueSearchResultsViewController: VenueSearchResultsViewController) {
        self.appRoute = appRoute
        self.venueService = venueService
        self.locationManager = locationManager
        self.venueSearchResultsViewController = venueSearchResultsViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Lifecycle
    //-------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addCustomViews()
    }

    private func addCustomViews() {
        if searchController == nil {
            searchController = UISearchController(searchResultsController: venueSearchResultsViewController)
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
        }

        if venueSearchView == nil {
            venueSearchView = VenueSearchView(searchView: searchController.searchBar)
            venueSearchView.tableViewDataSource = self
            venueSearchView.tableViewDelegate = self
            self.view = venueSearchView
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationBar()
        updateCustomViews()
    }

    //TODO: consider extension
    private func setupNavigationBar() {
        self.title = "VenueSearchViewController.Title".localized

        self.navigationController!.navigationBar.barStyle = .black
        self.navigationController!.navigationBar.barTintColor = UIColor.gftWaterBlueColor()
        self.navigationController!.navigationBar.tintColor = UIColor.gftWhiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.gftNavigationTitleFont()!, NSForegroundColorAttributeName: UIColor.gftWhiteColor()]

        let cancelBarButtonItem = UIBarButtonItem(title: "NavigationViewController.Cancel".localized, style: .plain, target: self, action: #selector(didTapCancel))
        cancelBarButtonItem.tintColor = UIColor.gftWhiteColor()
        cancelBarButtonItem.setTitleTextAttributes([NSFontAttributeName: UIFont.gftNavigationItemFont()!, NSForegroundColorAttributeName: UIColor.gftWhiteColor()], for: .normal)
        self.navigationItem.rightBarButtonItem = cancelBarButtonItem
    }

    private func updateCustomViews() {
        getNearbyVenues()
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Private
    //-------------------------------------------------------------------------------------------
    func didTapCancel() {
        self.appRoute.dismiss(controller: self, animated: true)
    }

    func getNearbyVenues() {
        locationManager.getCurrentLocation(
                success: { (location) in
                    self.currentLocation = (location.coordinate.latitude, location.coordinate.longitude)

                    self.venueService.findVenuesByLocation(
                            lat: location.coordinate.latitude,
                            lng: location.coordinate.longitude,
                            success: { (venues) in
                                Logger.debug("Successfully got nearby venues \(venues)")
                                self.nearbyVenues = venues
                                self.venueSearchView.shouldPresentEmptyPlaceholder(shouldPresent: venues.count == 0)
                            },
                            failure: { (error) in
                                Logger.error("Failed to get nearby venues list \(error)")
                                self.venueSearchView.shouldPresentEmptyPlaceholder(shouldPresent: true)
                            })

                }, failure: { (error) in
            Logger.error("Failed to get location \(error)")
            self.venueSearchView.shouldPresentEmptyPlaceholder(shouldPresent: true)
        })
    }

    func getSearchResultVenues() {
        Logger.debug("Updating search results")
        venueSearchResultsViewController.activityAnimation(shouldAnimate: true)

        let keyword = searchController.searchBar.text!
        venueService.findVenuesByKeyword(keyword: keyword,
                success: { (venues) in
                    Logger.debug("Successfully got searched venues \(venues)")
                    self.venueSearchResultsViewController.activityAnimation(shouldAnimate: false)
                    self.venueSearchResultsViewController.searchResultVenues = venues
                    self.venueSearchResultsViewController.currentLocation = self.currentLocation
                    self.venueSearchResultsViewController.shouldPresentEmptyPlaceholder(shouldPresent: venues.count == 0)
                }, failure: { (error) in
            Logger.error("Failed to search venues \(error)")
            self.venueSearchResultsViewController.activityAnimation(shouldAnimate: false)
            self.venueSearchResultsViewController.shouldPresentEmptyPlaceholder(shouldPresent: true)
        })
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - UISearchResultsUpdating
    //-------------------------------------------------------------------------------------------
    func updateSearchResults(`for` searchController: UISearchController) {
        searchPaceTimer?.invalidate()

        if (searchController.searchBar.text?.isEmpty)! {
            venueSearchResultsViewController.clearSearchResults()
        } else {
            searchPaceTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.getSearchResultVenues), userInfo: nil, repeats: false)
        }
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - UITableViewDataSource
    //-------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "VenueSearchViewController.Nearby".localized
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyVenues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:VenueCell = tableView.dequeueReusableCell(withIdentifier: VenueCellConstants.reuseIdentifier, for: indexPath) as! VenueCell

        let venue = nearbyVenues[indexPath.item];
        cell.venueName = venue.name
        cell.venueAddress = venue.address
        cell.venueImageUrl = venue.imageUrl
        cell.distanceAmount = LocationUtils.distanceBetween(lat1: currentLocation.lat, lng1: currentLocation.lng, lat2: (venue.latitude)!, lng2: (venue.longitude)!)
        cell.distanceUnit = DistanceUnit.kiloMeter

        return cell
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - UITableViewDelegate
    //-------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VenueCellConstants.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}