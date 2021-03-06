//
//  LxGridViewCell.h
//  LxGridView
//

#import <UIKit/UIKit.h>


static CGFloat const LxGridView_DELETE_WIDTH = 20;
static CGFloat const ICON_CORNER_RADIUS = 0;

@class LxGridViewCell;

@protocol LxGridViewCellDelegate <NSObject>

- (void)deleteButtonClickedInGridViewCell:(LxGridViewCell *)gridViewCell;

@end

@interface LxGridViewCell : UICollectionViewCell

@property (nonatomic,assign) id<LxGridViewCellDelegate> delegate;
@property (nonatomic,retain) UIImageView * iconImageView;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,assign) BOOL editing;

- (UIView *)snapshotView;

@end
