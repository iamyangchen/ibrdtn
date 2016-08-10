//
//  ToDoListTableViewController.m
//  ibr-dtn
//
//  Created by Chen Yang on 7/27/16.
//  Copyright © 2016 Chen Yang. All rights reserved.
//

#import "IbrDtnSettingsTableViewController.h"
#import "ToDoItem.h"
#import "IbrDtnSettingItem.h"
#import "AddToDoViewController.h"

#include "daemon_init.h"


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

#define SETTING_DAEMON      0
#define SETTING_NET         1


@interface IbrDtnSettingsTableViewController ()

// Private variable
@property NSMutableArray *toDoItems1;
@property NSMutableArray  *toDoItems2;

@property NSMutableArray *settings;

@end

@implementation IbrDtnSettingsTableViewController


- (IBAction)unwindToList:(UIStoryboardSegue *)segue{
  AddToDoViewController *source = [segue sourceViewController];
  ToDoItem *item = source.toDoItem;
  if (item != nil){
    [self.toDoItems1 addObject:item];
    [self.tableView reloadData];
  }
    
}

- (void) daemonStateChangedBySwitch:(id)sender {
  IbrDtnSettingUISwitch *switchControl = sender;
  NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
  
  // If it's turned on, start the daemon
  if (switchControl.on){
    // init_daemon_thread();
    revoke_daemon();
  } else {
  // else, turn off the daemon
    shutdown_daemon();
  }
}

- (void) ifaceStateChangedBySwitch:(id)sender {
  IbrDtnSettingUISwitch *switchControl = sender;
  IbrDtnSettingItem *item = switchControl.setting_item;
  IbrDtnSettingItem *enabled_net = [item.nextLevel objectAtIndex:0];
  if (switchControl.on){
    enabled_net.value = @"true";
  } else {
    enabled_net.value = @"false";
  }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
  self.settings = [[NSMutableArray alloc] init];
  [self loadInitialData];
  init_daemon_thread();
    /*
    char *para[6];
    char prog[] = "test";
    char p1[] = "-i";
    char p2[] = "en0";
    char p3[] = "-v";
    char p4[] = "-d";
    char p5[] = "5";
    para[0] = prog;
    para[1] = p1;
    para[2] = p2;
    para[3] = p3;
    para[4] = p4;
    para[5] = p5;
    
    init_ibrdtn_daemon(4, para);
     */
}

- (void) loadInitialData {
  
  
  NSMutableArray *daemon_settings = [[NSMutableArray alloc] init];
  NSMutableArray *net_settings = [[NSMutableArray alloc] init];
  
  IbrDtnSettingItem *enabled = [[IbrDtnSettingItem alloc] init];
  enabled.key = @"enabled";
  enabled.value = @"true";
  enabled.displayName = @"Device Enabled";
  [daemon_settings addObject:enabled];
  
  IbrDtnSettingItem *eid = [[IbrDtnSettingItem alloc] init];
  eid.key = @"local_uri";
  eid.value = @"dtn://Chen-iPhone.dtn";
  eid.displayName = [[NSString alloc] initWithString:eid.value];
  [daemon_settings addObject:eid];
  
  
  NSMutableSet *ifaceSet = [self loadIfaceData];
  NSInteger ifacecnt = 0;
  for (NSString *iface in ifaceSet){
    IbrDtnSettingItem *item = [[IbrDtnSettingItem alloc] init];
    NSMutableString *ckey = [[NSMutableString alloc] initWithString:@"lan"];
    [ckey appendString:[NSString stringWithFormat:@"%ld", (long)ifacecnt]];
    item.key = [[NSString alloc] initWithString:ckey];
    item.value = [[NSString alloc] initWithString:iface];
    item.nextLevel = [[NSMutableArray alloc] init];
    
    IbrDtnSettingItem *enabled_net = [[IbrDtnSettingItem alloc] init];
    enabled_net.key = @"enabled";
    enabled_net.value = @"false";
    enabled_net.displayName = @"Enabled";
    [item.nextLevel addObject:enabled_net];
    if ([item.value isEqualToString:@"pdp_ip0"]){
      item.displayName = @"Cellular";
    }
    else if ([item.value isEqualToString:@"en0"])
      item.displayName = @"WiFi";
    else
      item.displayName = [[NSString alloc] initWithString:iface];
    
    ifacecnt = ifacecnt + 1;
    [net_settings addObject:item];
  }
  
  [self.settings addObject:daemon_settings];
  [self.settings addObject:net_settings];
  

}

// Self defined method for loading data
- (NSMutableSet *)loadIfaceData {
  
  NSMutableSet *ifaceList = [[NSMutableSet alloc] init];
  
  
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
              [ifaceList addObject:name];
            }
        }
    }
  return ifaceList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.settings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.settings[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  switch (section) {
    case SETTING_DAEMON:
      return @"Daemon";
    case SETTING_NET:
      return @"Network";
    default:
      break;
  }
  return @"Unknown Section";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
  NSMutableString *toDisplay;

  IbrDtnSettingItem *item = self.settings[indexPath.section][indexPath.row];
  toDisplay = [[NSMutableString alloc] initWithString:item.displayName];
  cell.textLabel.text = toDisplay;
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  // Check if we need to attach a UISwitch
  IbrDtnSettingUISwitch *switchView = [[IbrDtnSettingUISwitch alloc] initWithFrame:CGRectZero];
  if ([toDisplay isEqualToString:@"Device Enabled"] ||
      indexPath.section == SETTING_NET)
    cell.accessoryView = switchView;

  
  // Add switch to "Device Enabled" setting
  if ([toDisplay isEqualToString:@"Device Enabled"]){
    bool daemonOn = [item.value isEqualToString:@"true"];
    switchView.setting_item = item;
    [switchView setOn:daemonOn animated:NO];
    [switchView addTarget:self action:@selector(daemonStateChangedBySwitch:) forControlEvents:UIControlEventValueChanged];
  } else if (indexPath.section == SETTING_NET) {
    IbrDtnSettingItem *enabled_net = [item.nextLevel objectAtIndex:0];
    bool ifaceOn = [enabled_net.value isEqualToString:@"true"];
    switchView.setting_item = item;
    [switchView setOn:ifaceOn animated:NO];
    [switchView addTarget:self action:@selector(ifaceStateChangedBySwitch:) forControlEvents:UIControlEventValueChanged];
  }
  
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

/*
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  ToDoItem *item = [self.toDoItems1 objectAtIndex:indexPath.row];
  item.completed = !item.completed;
  [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
}
*/

@end
