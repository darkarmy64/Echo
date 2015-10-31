//
//  SearchTableViewCell.h
//  DUCEPRO
//
//  Created by Avikant Saini on 10/31/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackArtistlabel;
@property (weak, nonatomic) IBOutlet UILabel *trackAlbumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *trackCoverImageView;


@end
