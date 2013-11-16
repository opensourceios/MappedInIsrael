//
//  MIITableViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/12/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIITableViewController.h"

@interface MIITableViewController () <MIIDataDelegate>
{
    UISearchBar *_searchBar;
    NSArray *_clusterAnnotationFiltered;
}
@end

@implementation MIITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.screenName = @"MIITableViewController";
    self.data.delegate = self;
    
    // NavigationBar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    // SearchBar
    _searchBar = [UISearchBar new];
    [_searchBar sizeToFit];
    _searchBar.delegate = self;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.placeholder = @"Search companies...";
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor colorWithHexString:@"#61a9ff" alpah:1.0]];
        
    if (self.clusterAnnotation) {
        self.navigationItem.title = [NSString stringWithFormat:@"%d companies", [self.clusterAnnotation count]];
    } else {
        self.navigationItem.titleView = _searchBar;
    }
    
    // updateFilter every UIControlEventValueChanged
    [self.whosHiring addTarget:self action:@selector(updateFilter:) forControlEvents:UIControlEventValueChanged];
    _clusterAnnotationFiltered = self.clusterAnnotation;
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)updateFilter:(id)sender
{
    NSLog(@"Search: %@, SegmentIndex: %d", _searchBar.text, self.whosHiring.selectedSegmentIndex);

    if (self.whosHiring.selectedSegmentIndex == 0) {
        if (self.clusterAnnotation) {
            _clusterAnnotationFiltered = self.clusterAnnotation;
        } else {
            [self.data setSearch:_searchBar.text setWhosHiring:NO];
        }
    } else {
        if (self.clusterAnnotation) {
            _clusterAnnotationFiltered = [MIIData whosHiring:self.clusterAnnotation];
        } else {
            [self.data setSearch:_searchBar.text setWhosHiring:YES];
        }
    }
    
    [self.tableView reloadData];
}

- (void)showMap:(id)sender
{
    [self performSegueWithIdentifier:@"showMap:" sender:sender];
}

- (void)companyIsReady:(MIICompany *)company
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"showCompany:" sender:company];
    });
}

#pragma mark - searchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self updateFilter:searchBar];
}
 
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_clusterAnnotationFiltered) {
        return 1;
    } else {
        return [[MIIData getAllFormatedCategories] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_clusterAnnotationFiltered) {
        return @"";
    } else {
        return [self.data getCompaniesInCategory:[[MIIData getAllFormatedCategories] objectAtIndex:section]].count ? [[MIIData getAllFormatedCategories] objectAtIndex:section] : nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_clusterAnnotationFiltered) {
        return [_clusterAnnotationFiltered count];
    } else {
        NSString *category = (NSString *)[[MIIData getAllFormatedCategories] objectAtIndex:section];
        return [self.data getCompaniesInCategory:category].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MIICompany *company;
    if (_clusterAnnotationFiltered) {
        company = ((MIIPointAnnotation *)[_clusterAnnotationFiltered objectAtIndex:indexPath.row]).company;
    } else {
        NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
        company = [self.data category:category companyAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = company.companyName;
    cell.detailTextLabel.text = company.companySubCategory;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showMap:" sender:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MIICompany *company;
    if (_clusterAnnotationFiltered) {
        company = ((MIIPointAnnotation *)[_clusterAnnotationFiltered objectAtIndex:indexPath.row]).company;
    } else {
        NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
        company = [self.data category:category companyAtIndex:indexPath.row];
    }
    
    [self.data getCompany:company.id];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCompany:"]) {
        if ([sender isKindOfClass:[MIICompany class]]) {
            MIICompany *company = (MIICompany *)sender;
            MIICompanyViewController *controller = (MIICompanyViewController *)segue.destinationViewController;
            controller.company = company;
        }
    }
    
    if ([segue.identifier isEqualToString:@"showMap:"]) {
        MIIViewController *controller = (MIIViewController *)segue.destinationViewController;
        if ([sender isKindOfClass:[NSIndexPath class]]) { // With Zoom
            NSIndexPath *indexPath = (NSIndexPath *)sender;
            MIICompany *company;
            if (_clusterAnnotationFiltered) {
                company = ((MIIPointAnnotation *)[_clusterAnnotationFiltered objectAtIndex:indexPath.row]).company;
            } else {
                NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
                company = [self.data category:category companyAtIndex:indexPath.row];
            }
            controller.company = company;
        }
    }
}

@end
