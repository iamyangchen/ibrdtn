//
//  IbrDtnSettingItem.h
//  ibr-dtn
//
//  Created by Chen Yang on 8/3/16.
//  Copyright © 2016 Chen Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IbrDtnSettingItem : NSObject

@property NSString *displayName;
@property NSString *key;
@property NSString *value;
@property NSMutableArray *nextLevel;

@end

@interface IbrDtnSettingUISwitch : UISwitch
@property IbrDtnSettingItem *setting_item;
@end