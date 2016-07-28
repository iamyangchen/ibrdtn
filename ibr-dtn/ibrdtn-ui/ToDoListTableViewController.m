//
//  ToDoListTableViewController.m
//  ibr-dtn
//
//  Created by Chen Yang on 7/27/16.
//  Copyright © 2016 Chen Yang. All rights reserved.
//

#import "ToDoListTableViewController.h"
#import "ToDoItem.h"


#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"


@interface ToDoListTableViewController ()

// Private variable
@property NSMutableArray *toDoItems;

@end

@implementation ToDoListTableViewController


- (IBAction)unwindToList:(UIStoryboardSegue *)segue{
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.toDoItems = [[NSMutableArray alloc] init];
    [self loadInitialData];
}

// Self defined method for loading data
- (void)loadInitialData {
    
    struct ifaddrs *ifap = NULL;
    int status = getifaddrs(&ifap);
    int i=0;
    
    for (struct ifaddrs *iter = ifap; iter != NULL; iter = iter->ifa_next, i++)
    {
        // Skip interfaces not up
        if (!(iter->ifa_flags & IFF_UP)) continue;
        const struct sockaddr_in * addr = (const struct sockaddr_in*) iter->ifa_addr;
        
        if (addr->sin_family == AF_INET6){
            const struct sockaddr_in6 * addr6 = (const struct sockaddr_in6 *)addr;
            if (IN6_IS_ADDR_LINKLOCAL(&(addr6->sin6_addr))) {
                continue;
            } else if (IN6_IS_ADDR_LOOPBACK(&(addr6->sin6_addr))){
                continue;
            }
        } else if (addr->sin_family == AF_INET){
            if ((addr->sin_addr.s_addr & htonl(0xffff0000)) == htonl(0xA9FE0000)) {
                // link-local address
                continue;
            }
            else if ((addr->sin_addr.s_addr & htonl(0xff000000)) == htonl(0x7F000000)) {
                // loop-back address
                continue;
            }
        } else
            continue;
        
        char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
        
        if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
            NSString *name = [NSString stringWithUTF8String: iter->ifa_name];
            NSString *type;
            if(addr->sin_family == AF_INET) {
                if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                    type = IP_ADDR_IPv4;
                }
            } else {
                const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)iter->ifa_addr;
                if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                    type = IP_ADDR_IPv6;
                }
            }
            if(type) {
                NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                
                ToDoItem *item = [[ToDoItem alloc] init];
                item.itemName = [[NSString alloc] initWithString:name];
                item.ip = [NSString stringWithUTF8String: addrBuf];
                [self.toDoItems addObject:item];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.toDoItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    
    ToDoItem *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    NSMutableString *toDisplay = [[NSMutableString alloc] init];
    [toDisplay appendString:toDoItem.itemName];
    [toDisplay appendString:@","];
    [toDisplay appendString:toDoItem.ip];
    
    
    cell.textLabel.text = toDisplay;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
