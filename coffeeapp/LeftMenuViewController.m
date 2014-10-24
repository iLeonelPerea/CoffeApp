//
//  LeftMenuViewController.m
//  coffeeapp
//
//  Created by Omar Guzmán on 10/22/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "LeftMenuViewController.h"

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController
@synthesize tblMenu, arrMenu, isUserLogged;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    arrMenu = [[NSMutableArray alloc] initWithObjects:@"Menu", @"Orders", nil];
    [tblMenu setDelegate:self];
    [tblMenu setDataSource:self];
    [tblMenu reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[arrMenu count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"CellMenu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [arrMenu objectAtIndex:(NSUInteger)indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
