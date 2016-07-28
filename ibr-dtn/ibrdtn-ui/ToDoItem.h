//
//  ToDoItem.h
//  ibr-dtn
//
//  Created by Chen Yang on 7/27/16.
//  Copyright © 2016 Chen Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject

@property NSString *itemName;
@property NSString *ip;
@property BOOL completed;
@property (readonly) NSDate *creationDate;

@end
