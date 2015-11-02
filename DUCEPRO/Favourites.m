//
//  Favourites.m
//  DUCEPRO
//
//  Created by YASH on 02/11/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import "Favourites.h"

@implementation Favourites

// Insert code here to add functionality to your managed object subclass

+ (NSManagedObjectContext *) managedObjectContext
{
    
    NSManagedObjectContext *context = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext) withObject:self])
    {
        
        context = [delegate managedObjectContext];
        
    }
    
    return context;
    
}

@end
