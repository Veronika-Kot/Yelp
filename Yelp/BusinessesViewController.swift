//
//  BusinessesViewController.swift
//  Yelp
//

//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, FiltersViewControllerDelegate, UIScrollViewDelegate {

    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var status: Bool = false
    var isMoreDataLoading = false
    
    var loadMoreOffset = 20
    var selectedCategories: [String]?
    var moreData: InfiniteScrollActivityView?
    
    // creating searchBar
    var searchController: UISearchController!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = UIColor(red: 250.0/255.0, green: 102.0/255.0, blue: 72.0/255.0, alpha: 1)
        navigationController!.navigationBar.tintColor = UIColor(red: 102.0/255.0, green: 36.0/255.0, blue: 67.0/255.0, alpha: 1)
        
        //Serach bar
        
        filteredBusinesses = businesses
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
        
       
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        moreData = InfiniteScrollActivityView(frame: frame)
        moreData!.hidden = true
        tableView.addSubview(moreData!)

        Business.searchWithTerm("Restaurants", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.filteredBusinesses = businesses
            self.tableView.reloadData()
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
                print(business.distance!)
                print(business.categories!)
            }
        })
 //Example of Yelp search with more search options specified
//        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
//            self.businesses = businesses
//            
//            for business in businesses {
//                print(business.name!)
//                print(business.address!)
//            }
//        }

        updateSearchResultsForSearchController(searchController)
    
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if filteredBusinesses == nil {
            print("onCancel")
            filteredBusinesses = businesses
            tableView.reloadData()
        }
        if let searchText = searchController.searchBar.text {
            if(searchText == "") {
                print("onUpdate")
                filteredBusinesses = businesses
                tableView.reloadData()
            } else {
                filteredBusinesses = searchText.isEmpty ? businesses : businesses?.filter({ (business:Business) -> Bool in
                    business.name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
                });
                tableView.reloadData()
           }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredBusinesses != nil {
            print("on search")
            return filteredBusinesses!.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = filteredBusinesses[indexPath.row]
        return cell
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                moreData?.frame = frame
                moreData!.startAnimating()
                
                loadMoreData()
            }
        }
    }
    
    
    func loadMoreData() {
        Business.searchWithTerm("Restaurants", sort: nil, categories: selectedCategories, deals: nil, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            if error != nil {
                    self.moreData?.stopAnimating()
                    //TODO: show network error
            } else {
                
                    self.loadMoreOffset += 20
                    self.filteredBusinesses.appendContentsOf(businesses)
                    self.tableView.reloadData()
                    self.moreData?.stopAnimating()
                    self.isMoreDataLoading = false
            }
        })
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "details" {
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(sender as! BusinessCell)?.row
            
            let business = filteredBusinesses![indexPath!]
            let detailViewController = segue.destinationViewController as! DetailsViewController
            
            detailViewController.business = business
            print("Prepare for segue")
        } else if segue.identifier == "filters" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            
            filtersViewController.delegate = self
        }
    }
    
    
    func filtersViewController(fltersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
        let categories = filters["categories"] as? [String]
        selectedCategories = categories
        self.filteredBusinesses = []
        
        Business.searchWithTerm("Restaurants", sort: nil, categories: categories, deals: nil) {(businesses: [Business]!, error: NSError!) -> Void in
            self.filteredBusinesses = businesses
            self.tableView.reloadData()
            
        }
    }
    

}
