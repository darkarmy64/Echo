//
//  Favourites.h
//  DUCEPRO
//
//  Created by YASH on 02/11/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Favourites : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (NSManagedObjectContext *) managedObjectContext;

@end

NS_ASSUME_NONNULL_END

#import "Favourites+CoreDataProperties.h"
