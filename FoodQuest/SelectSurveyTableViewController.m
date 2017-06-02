//
//  SelectSurveyTableViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/3/10.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "SelectSurveyTableViewController.h"
#import "SurveyViewController.h"
#import <YAML/YAMLSerialization.h>

@interface SelectSurveyTableViewController ()

@end

@implementation SelectSurveyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // load survey dictionaries from yaml files in "surveys" folder
    _surveys = [NSMutableArray array];

    
    NSString * surveysPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"surveys"];
    
    NSError * error;
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:surveysPath error:&error];
    
    NSLog(@"directoryContents ====== %@",directoryContents);
    
    for (NSString *filename in directoryContents) {
    
        if ([filename hasSuffix:@"yaml"]) {
            NSString* path = [surveysPath stringByAppendingPathComponent:filename];
                                                         
            NSString *yamlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];

            NSMutableArray *yamlObjects = [YAMLSerialization
                                                    objectsWithYAMLString: yamlString
                                                    options:  kYAMLReadOptionStringScalars
                                                    error: &error];
                                                    
            if (yamlObjects != nil && 0 < [yamlObjects count]) {
                [_surveys addObject: [yamlObjects firstObject]];
            }
            else {
                // NOTE: post alert that one of the surveys is illformed
                // or pre-scan all surverys as part of build?
                NSLog(@"YAML error %@",error);
            }
            
        }
    
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
  //  NSLog(@"number of sections: %ld", [tableView numberOfSections]);

  //  return [tableView numberOfSections];
   
   return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

   // NSLog(@"number of rows: %ld", [tableView numberOfRowsInSection:section]);
   // return [tableView numberOfRowsInSection:section];
    
    if (0 == section) {
        NSLog(@"number of rows: %ld", [_surveys count]);
        return [_surveys count];
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"surveyCell" forIndexPath:indexPath];

    cell.textLabel.text = [[_surveys objectAtIndex:[indexPath row]] objectForKey:@"label"];
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSDictionary * selectedSurvey = [_surveys objectAtIndex:[[self.tableView indexPathForSelectedRow] row] ];
    
    [(SurveyViewController *)[segue destinationViewController] setSurvey:selectedSurvey];
    
}


@end
