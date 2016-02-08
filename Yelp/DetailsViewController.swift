//
//  DetailsViewController.swift
//  Yelp
//
//  Created by Veronika Kotckovich on 2/7/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var streets: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var rewiewsCountLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var Neigbourhood: UILabel!
    
    @IBOutlet weak var Phone: UILabel!
    
    var business: Business! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         navigationController!.navigationBar.titleTextAttributes = ([NSFontAttributeName: UIFont(name: "BradleyHandITCTT-Bold", size: 36)!, NSForegroundColorAttributeName: UIColor(red: 235.0/255.0, green: 222.0/255.0, blue: 190.0/255.0, alpha: 1)])

        nameLabel.text = business.name
        if let imageUrl = business.imageURL {
            thumbImageView.setImageWithURL(imageUrl)
        }
        streets.text = business.crossStreets
        Phone.text = business.phone
        categoriesLabel.text = business.categories
        //Neigbourhood.text = business.neighborhoods
        addressLabel.text = business.address
        rewiewsCountLabel.text = "\(business.reviewCount!) Reviews"
        ratingImageView.setImageWithURL(business.ratingImageURL!)
        distanceLabel.text = business.distance
        
        thumbImageView.layer.cornerRadius = 4
        thumbImageView.clipsToBounds = true
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        
        
        let coordinate = CLLocationCoordinate2D(latitude: (business?.coordinate.0)!, longitude: (business?.coordinate.1)!)
        addAnnotationAtCoordinate(latitude: (business?.coordinate.0)!, longitude: (business?.coordinate.1)!, title: business!.name! )
        
        let centerLocation = CLLocation(latitude: (business?.coordinate.0)!, longitude: (business?.coordinate.1)!)
        goToLocation(centerLocation)
        
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.008, 0.008)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //implementing map
    
    func addAnnotationAtCoordinate(latitude latitude: Double, longitude: Double, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        annotation.title = business.name
        mapView.addAnnotation(annotation)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "customAnnotationView"
        
        // custom image annotation
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        else {
            annotationView!.annotation = annotation
        }
        annotationView!.image = UIImage(named: "customAnnotationImage")
        
        return annotationView
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
