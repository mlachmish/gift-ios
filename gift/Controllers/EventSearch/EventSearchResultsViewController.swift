//
// Created by Matan Lachmish on 18/12/2016.
// Copyright (c) 2016 GiftApp. All rights reserved.
//

import Foundation
import UIKit

class EventSearchResultsViewController: UIViewController, EventSearchResultsViewDelegate, UITableViewDataSource, UITableViewDelegate {

    //Injections
    private var appRoute: AppRoute

    //Views
    private var eventSearchResultsView: EventSearchResultsView!

    //Public Properties
    public var searchResultEvents: Array<Event> = [] {
        didSet {
            eventSearchResultsView.update()
        }
    }

    public var currentLocation: (lat: Double, lng: Double)! {
        didSet {
            eventSearchResultsView.update()
        }
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Initialization & Destruction
    //-------------------------------------------------------------------------------------------
    internal dynamic init(appRoute: AppRoute) {
        self.appRoute = appRoute
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
        if eventSearchResultsView == nil {
            eventSearchResultsView = EventSearchResultsView()
            eventSearchResultsView.delegate = self
            eventSearchResultsView.tableViewDataSource = self
            eventSearchResultsView.tableViewDelegate = self
            self.view = eventSearchResultsView
        }
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Public
    //-------------------------------------------------------------------------------------------
    func clearSearchResults() {
        searchResultEvents.removeAll()
    }

    func activityAnimation(shouldAnimate: Bool) {
        eventSearchResultsView.activityAnimation(shouldAnimate: shouldAnimate)
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - EventSearchResultViewDelegate
    //-------------------------------------------------------------------------------------------
    func didTapEventIsNotInTheList() {
        Logger.debug("User tapped event is not in the list")
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - UITableViewDataSource
    //-------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:EventCell = tableView.dequeueReusableCell(withIdentifier: EventCellConstants.reuseIdentifier, for: indexPath) as! EventCell

        let event = searchResultEvents[indexPath.item]

        cell.eventName = event.title
        cell.venueName = event.venue?.name
        cell.distanceAmount = LocationUtils.distanceBetween(lat1: currentLocation.lat, lng1: currentLocation.lng, lat2: (event.venue?.latitude)!, lng2: (event.venue?.longitude)!)
        cell.distanceUnit = EventCellDistanceUnit.kiloMeter

        return cell
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - UITableViewDelegate
    //-------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EventCellConstants.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Logger.debug("User tapped on event")
    }

}
