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
#import "Fileutils.h"
#import "StringUtils.h"
#import "ZipHelperUtils.h"
#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "ZipHelperUtils.h"
#import "Objective-Zip/ZipFile.h"
#import "Objective-Zip/ZipException.h"
#import "Objective-Zip/FileInZipInfo.h"
#import "Objective-Zip/ZipWriteStream.h"
#import "Objective-Zip/ZipReadStream.h"
#import <QuartzCore/CALayer.h>

@interface RosiLocaViewController ()

@property (strong, nonatomic) NSMutableArray* dataSource;
@property (strong, nonatomic) AlbumEngine* engine;
//@property (strong, nonatomic) MBProgressHUD* hud;
@property (strong, nonatomic) MBProgressHUD* unzipHud;
@property (strong, nonatomic) NSFileManager* fm;
@property (strong, nonatomic) NSMutableArray* photos;
@property (strong, nonatomic) UIButton* footer;
@property (strong, nonatomic) NSMutableDictionary* downloadStatusDic;

@end

@implementation RosiLocaViewController

BOOL showLoading;

BOOL hasMore = NO;

int currentPage = 0;

NSString* NO_MORE = @"没有更多了\n每天晚上八点都会更新哦~~";
NSString* LOADING_MORE = @"点击加载更多\n每天晚上八点都会更新哦~~";

- (void) initData {
    _dataSource = [[NSMutableArray alloc] init];
    _engine = ApplicationDelegate.albumEngine;
    _fm = [NSFileManager defaultManager];
    _photos = [[NSMutableArray alloc] init];
    
    CGRect rect = CGRectMake(0, 5, 320, 40);
    _footer = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _footer.frame = rect;
//    _footer.backgroundColor = [UIColor colorWithCIColor:[CIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
//    _footer.titleLabel.textColor = [UIColor whiteColor];
    [_footer setTitle:LOADING_MORE forState:UIControlStateNormal];
//    self.tableView.tableFooterView = _footer;
    [_footer addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    self.restApi = @"showbooks";
    _downloadStatusDic = [[NSMutableDictionary alloc] init];
}

- (id)initWithStyle:(UITableViewStyle)style {
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
        [self loadDataWithCategory:@"rosi" page:[[NSString alloc] initWithFormat:@"%d", currentPage]];
    }
}

- (void) loadDataWithCategory:(NSString*) category page:(NSString*) page {
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = @"刷新中，请稍后...";
    showLoading = true;
    [hud showWhileExecuting:@selector(hubLoadingWait) onTarget:self withObject:nil animated:YES];
    
    BOOL forceLoad = YES;
    if ([page isEqualToString:@"0"]) {
        forceLoad = NO;
    }
    
    [_engine albumUrl:self.restApi completionHandler:^(NSMutableDictionary *album) {
        if (album != nil && [album count] > 0) {
            if ([page isEqualToString:@"0"]) {
                [_dataSource removeAllObjects];
            }
            
            int more = [album[@"hasmore"] integerValue];
            if (more == 1) {
                hasMore = YES;
            } else {
                hasMore = NO;
            }
            
            if (hasMore) {
                [self performSelectorOnMainThread:@selector(showFooter) withObject:nil waitUntilDone:NO];
            } else {
                [self performSelectorOnMainThread:@selector(hideFooter) withObject:nil waitUntilDone:NO];
            }
            
            [_dataSource addObjectsFromArray:album[@"data"]];
            if (_dataSource != nil && [_dataSource count] > 0) {
                [self.tableView reloadData];
                showLoading = false;
            }
        }
    } postParams:@{@"category" : category, @"page" : page} errorHandler:^(NSError *error) {
        showLoading = false;
    } forceLoad:forceLoad];
}

- (void) loadMore {
    currentPage = currentPage + 1;
    [self loadDataWithCategory:@"rosi" page:[[NSString alloc] initWithFormat:@"%d", currentPage]];
}

- (void) showFooter {
    self.tableView.tableFooterView = _footer;
}

- (void) hideFooter {
    self.tableView.tableFooterView = nil;
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[hud removeFromSuperview];
	hud = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor colorWithRed:0.29 green:0.32 blue:0.35 alpha:1];
    self.view.backgroundColor = [UIColor grayColor];

    [self initData];
    
    self.navigationItem.title = @"今日更新";
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //set right button
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.tableView setSeparatorColor:[[UIColor alloc] initWithWhite:0 alpha:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshAction:(id) sender {
    currentPage = 0;
    [self loadDataWithCategory:@"rosi" page:[[NSString alloc] initWithFormat:@"%d", currentPage]];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_dataSource != nil) {
        return [_dataSource count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 220;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 50;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"localCell";
    LocalCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LocalCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* item = [_dataSource objectAtIndex:indexPath.row];
    NSString* downloadUrl = item[@"downloadUrl"];
    NSString* docPath = [Fileutils DocumentFullPath];
    NSString* downloadUrlMD5 = [StringUtils md5Endcode:downloadUrl];
    NSString* sessionLocalFullPath = [[NSString alloc] initWithFormat:@"%@/%@", docPath, downloadUrlMD5];
    
    if ([_fm fileExistsAtPath:sessionLocalFullPath]) {
        cell.status.backgroundColor = [UIColor colorWithRed:0.21 green:0.368 blue:0.05 alpha:1.0];
        cell.status.text = @"已下载";
    } else {
        cell.status.backgroundColor = [UIColor colorWithRed:0.5 green:0.16 blue:0.16 alpha:1.0];
        cell.status.text = @"未下载";
    }
    cell.status.font = [UIFont boldSystemFontOfSize:16];
    cell.status.textColor = [UIColor whiteColor];
    CALayer* l = [cell.status layer];
    [l setCornerRadius:6.0];
    [l setBorderWidth:2];
    [l setBorderColor:[[UIColor grayColor] CGColor]];
    
    cell.desc.textColor = [UIColor whiteColor];
    cell.desc.font = [UIFont boldSystemFontOfSize:20];
    cell.downloadCount.textColor = [UIColor whiteColor];
    cell.downloadCount.font = [UIFont systemFontOfSize:14];
    cell.textRegionView.backgroundColor = [UIColor colorWithCIColor:[CIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    CALayer* layer = [cell.coverImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:8.0];
    [layer setBorderWidth:2];
    [layer setBorderColor:[[UIColor blackColor] CGColor]];
    layer = [cell.textRegionView layer];
    [layer setCornerRadius:8.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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

- (void) unzipSessionWithParams:(NSDictionary*) params {
    if (params != nil) {
        NSString* zipFilePath = params[@"localPath"];
        NSString* toTarget = params[@"targetPath"];
        
        if (zipFilePath != nil && toTarget != nil) {
            NSLog(@"[[unzipSessionWithParams]] try unzip form : %@ to local : %@", zipFilePath, toTarget);
            [ZipHelperUtils unzipFile:zipFilePath targetDir:toTarget forceOverWrite:YES];
        }
        
        NSLog(@"[[unzipSessionWithParams]] finish unzip form : %@ to local : %@", zipFilePath, toTarget);
    }
}

#pragma mark - Browser view delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void) pushImageBrowserWithSessionPath:(NSString*) sessionDirFullPath {
    if (sessionDirFullPath != nil) {
        NSFileManager* fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:sessionDirFullPath]) {
            NSArray* fileList = [fm subpathsAtPath:sessionDirFullPath];
            [_photos removeAllObjects];
            for (NSString* file in fileList) {
                if ([[file pathExtension] isEqualToString:@"jpg"]) {
                    MWPhoto* photo = [MWPhoto photoWithFilePath:[[NSString alloc] initWithFormat:@"%@/%@", sessionDirFullPath, file]];
//                    photo.caption = [[NSString alloc] initWithFormat:@"%@/%@", sessionDirFullPath, file];
                    [_photos addObject:photo];
                }
            }
            
            MWPhotoBrowser* browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = true;
            [self performSelectorOnMainThread:@selector(pushBrowserWithController:) withObject:browser waitUntilDone:NO];
        }
    }
}

- (void) pushBrowserWithController:(MWPhotoBrowser *) browser {
     [self.navigationController pushViewController:browser animated:YES];
}

- (void) loadingSessionWithZipFullPath:(NSString*) zipFullPath {
    if (zipFullPath == nil) {
        return;
    }
    
    ZipFile* unzipFile = [[ZipFile alloc] initWithFileName:zipFullPath mode:ZipFileModeUnzip];
    NSArray* fileinfos = [unzipFile listFileInZipInfos];
    NSString* dirName = nil;
    for (FileInZipInfo* info in fileinfos) {
        NSString* filename = [[NSString alloc] initWithFormat:@"%@", info.name];
        if ([filename characterAtIndex:([filename length] - 1)] == '/') {
            dirName = filename;
        }
    }
    
    if(dirName == nil) {
        return;
    }
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* docPath = [Fileutils DocumentFullPath];
    NSString* currentSessionFullPath = [[NSString alloc] initWithFormat:@"%@/%@", docPath, dirName];
    NSLog(@"try to search the image under dir : %@", currentSessionFullPath);
    if ([fm fileExistsAtPath:currentSessionFullPath]) {
        [self pushImageBrowserWithSessionPath:currentSessionFullPath];
    } else {
        [self unzipSessionWithParams:@{@"localPath" : zipFullPath, @"targetPath" : docPath}];
        [self pushImageBrowserWithSessionPath:currentSessionFullPath];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_dataSource count] > indexPath.row) {
        NSDictionary* item = [_dataSource objectAtIndex:indexPath.row];
        NSString* downloadUrl = item[@"downloadUrl"];
        if (item != nil && downloadUrl != nil) {
            NSString* docPath = [Fileutils DocumentFullPath];
            NSString* downloadUrlMD5 = [StringUtils md5Endcode:downloadUrl];
            NSString* sessionLocalFullPath = [[NSString alloc] initWithFormat:@"%@/%@", docPath, downloadUrlMD5];
            NSLog(@"Download to local Path : %@", sessionLocalFullPath);
            if ([_fm fileExistsAtPath:sessionLocalFullPath]) {
                //file has download
                
                MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.navigationController.view addSubview:hud];
                hud.delegate = self;
                hud.labelText = [[NSString alloc] initWithFormat:@"正在加载 %@, 请稍后...", item[@"description"]];
                hud.dimBackground = YES;
                [hud showWhileExecuting:@selector(loadingSessionWithZipFullPath:) onTarget:self withObject:sessionLocalFullPath animated:YES];

            } else {
                //file not download
                NSString* msg = [[NSString alloc] initWithFormat:@"下载 %@ ？", item[@"description"]];
                UIBAlertView* dialog = [[UIBAlertView alloc] initWithTitle:@"下载提示" message:msg cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil];
                [dialog showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
                    if (selectedIndex == 1) {
                        //OK click

                        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                        [self.navigationController.view addSubview:hud];
                        hud.delegate = self;
                        hud.labelText = [[NSString alloc] initWithFormat:@"正在下载 %@, 请稍后...", item[@"description"]];
                        hud.mode = MBProgressHUDModeAnnularDeterminate;
                        hud.dimBackground = YES;
                        showLoading = true;
                        [hud showWhileExecuting:@selector(hubLoadingWait) onTarget:self withObject:nil animated:YES];

                        
                        MKNetworkOperation* op = [_engine createDownloadOpWithUrl:downloadUrl toFile:sessionLocalFullPath];
                        [op onDownloadProgressChanged:^(double progress) {
                            if (hud != nil) {
                                hud.progress = progress;
                            }
                        }];
                        
                        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
                            NSFileManager* fm = [NSFileManager defaultManager];
                            NSLog(@"Download finish, local path : %@", sessionLocalFullPath);
                            NSLog(@"download file size = %lld", [[fm attributesOfItemAtPath:sessionLocalFullPath error:nil] fileSize] / 1000);
                            
                            showLoading = false;
                            
                            if ([fm fileExistsAtPath:sessionLocalFullPath]) {
                                if (_unzipHud == nil) {
                                    _unzipHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                                    [self.navigationController.view addSubview:_unzipHud];
                                    _unzipHud.delegate = self;
                                    _unzipHud.labelText = [[NSString alloc] initWithFormat:@"正在解压 %@", item[@"description"]];
                                    _unzipHud.dimBackground = YES;
                                    [_unzipHud showWhileExecuting:@selector(unzipSessionWithParams:) onTarget:self withObject:@{@"localPath" : sessionLocalFullPath, @"targetPath" : docPath} animated:YES];
                                    
                                }
                            }
                            
                        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                            showLoading = false;                            
                        }];
                    }
                }];
            }
        }
    }
    
    return;
}

@end
