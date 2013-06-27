//
//  RosiLocaViewController.m
//  rosi
//
//  Created by michael on 13-6-26.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import "RosiLocaViewController.h"
#import "AlbumEngin.h"
#import "RosiAppDelegate.h"
#import "Libraries/MBProgressHUD/MBProgressHUD.h"
#import "Alert/UIBAlertView.h"
#import "LocalCell.h"

@interface RosiLocaViewController ()

@property (strong, nonatomic) NSArray* dataSource;
@property (strong, nonatomic) AlbumEngine* engine;
@property (strong, nonatomic) MBProgressHUD* hud;

@end

@implementation RosiLocaViewController

BOOL showLoading;

- (void) initData {
    _dataSource = [[NSArray alloc] init];
    _engine = ApplicationDelegate.albumEngine;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) hubLoadingWait {
    while (showLoading) {
        sleep(1);
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([_dataSource count] == 0) {
        if (_hud != nil) {
            showLoading = false;
            [_hud removeFromSuperview];
            _hud = nil;
        } else {
            _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:_hud];
            _hud.delegate = self;
            _hud.labelText = @"加载中，请稍后...";
            showLoading = true;
            [_hud showWhileExecuting:@selector(hubLoadingWait) onTarget:self withObject:nil animated:YES];
        }
        
        [_engine albumUrl:@"showbooks" completionHandler:^(NSMutableDictionary *album) {
            if (album != nil && [album count] > 0) {
                _dataSource = album[@"data"];
                
                if (_dataSource != nil && [_dataSource count] > 0) {
                    [self.tableView reloadData];
                    showLoading = false;
                }
            }
        } postParams:@{@"category" : @"rosi", @"page" : @"0"} errorHandler:^(NSError *error) {
            showLoading = false;
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_dataSource != nil) {
        return [_dataSource count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"localCell";
    LocalCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LocalCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.downlaodProgress.hidden = true;
    cell.desc.textColor = [UIColor whiteColor];
    cell.desc.font = [UIFont boldSystemFontOfSize:20];
    cell.downloadCount.textColor = [UIColor whiteColor];
    cell.downloadCount.font = [UIFont systemFontOfSize:14];
    cell.textRegionView.backgroundColor = [UIColor colorWithCIColor:[CIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    if (_dataSource != nil && [_dataSource count] > indexPath.row) {
        NSDictionary* item = [_dataSource objectAtIndex:indexPath.row];
        if (item != nil) {
            [cell updateAlbumImage:item[@"imageUrl"] desc:item[@"description"] count:item[@"downloadCount"]];
        }
    }
    
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
