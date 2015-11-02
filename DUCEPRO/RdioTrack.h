//
//  RdioTrack.h
//  DUCEPRO
//
//  Created by Shubham Sorte on 29/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RdioTrack : NSObject
@property (nonatomic, strong) NSString *trackAlbum;
@property (nonatomic, strong) NSString *trackName;
@property (nonatomic, strong) NSString *trackArtist;
@property (nonatomic, strong) NSString *trackIcon;
@property (nonatomic, strong) NSString *trackKey;
@property (nonatomic, strong) NSString *trackUrl;

@property(nonatomic,strong) NSDictionary *mainDictionary;

-(id)initWithDict:(NSDictionary*)dict;


@end
