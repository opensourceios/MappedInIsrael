//
//  MIIViewController.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ADClusterMapView.h"
#import "GAITrackedViewController.h"

enum displayedView
{
    kMap,
    kSearch,
    kInfo
};

@interface MIIViewController : GAITrackedViewController <MKMapViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *mapV;
@property (weak, nonatomic) IBOutlet ADClusterMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *whosHiringView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *whosHiring;

- (IBAction)showCurrentLocation;

@end
