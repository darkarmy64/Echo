//
//  Favourites+CoreDataProperties.h
//  DUCEPRO
//
//  Created by YASH on 02/11/15.
//  Copyright © 2015 appvaders. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Favourites.h"

NS_ASSUME_NONNULL_BEGIN

@interface Favourites (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *trackName;
@property (nullable, nonatomic, retain) NSString *trackKey;
@property (nullable, nonatomic, retain) NSString *trackAlbum;
@property (nullable, nonatomic, retain) NSString *trackIcon;
@property (nullable, nonatomic, retain) NSString *trackArtist;
@property (nullable, nonatomic, retain) NSString *trackUrl;

@end

NS_ASSUME_NONNULL_END
