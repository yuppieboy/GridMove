//
//  LxGridViewCell.m
//  LxGridView
//

#import "LxGridView.h"
#import "Masonry.h"

static NSString * const kVibrateAnimation = @stringify(kVibrateAnimation);
static CGFloat const VIBRATE_DURATION = 0.1;
static CGFloat const VIBRATE_RADIAN = M_PI / 96;

@interface LxGridViewCell ()

@property (nonatomic,assign) BOOL vibrating;

@end

@implementation LxGridViewCell
{
    UIButton * _deleteButton;
    UILabel * _titleLabel;
}
@synthesize editing = _editing;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self setupEvents];
    }
    return self;
}

- (void)setup
{
    self.iconImageView = [[UIImageView alloc]init];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconImageView.layer.cornerRadius = ICON_CORNER_RADIUS;
    self.iconImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.iconImageView];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteButton];
    _deleteButton.hidden = YES;
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.text = @"title";
    _titleLabel.font = [UIFont systemFontOfSize:12];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@30);
        make.height.equalTo(@30);
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY).offset(-5);

    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.iconImageView.mas_bottom);
        make.height.equalTo(@30);
        
    }];
    
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@20);
        make.height.equalTo(@20);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);

    }];


}

- (void)setupEvents
{
    [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.iconImageView.userInteractionEnabled = YES;
}

- (void)deleteButtonClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(deleteButtonClickedInGridViewCell:)]) {
        [self.delegate deleteButtonClickedInGridViewCell:self];
    }
}

- (BOOL)vibrating
{
    return [self.iconImageView.layer.animationKeys containsObject:kVibrateAnimation];
}

- (void)setVibrating:(BOOL)vibrating
{
    BOOL _vibrating = [self.layer.animationKeys containsObject:kVibrateAnimation];
    
    if (_vibrating && !vibrating) {
        [self.layer removeAnimationForKey:kVibrateAnimation];
    }
    else if (!_vibrating && vibrating) {
        CABasicAnimation * vibrateAnimation = [CABasicAnimation animationWithKeyPath:@stringify(transform.rotation.z)];
        vibrateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        vibrateAnimation.fromValue = @(- VIBRATE_RADIAN);
        vibrateAnimation.toValue = @(VIBRATE_RADIAN);
        vibrateAnimation.autoreverses = YES;
        vibrateAnimation.duration = VIBRATE_DURATION;
        vibrateAnimation.repeatCount = CGFLOAT_MAX;
        [self.layer addAnimation:vibrateAnimation forKey:kVibrateAnimation];
    }
}

- (BOOL)editing
{
    return self.vibrating;
}

- (void)setEditing:(BOOL)editing
{
//    self.vibrating = editing;
    _deleteButton.hidden = !editing;
    self.vibrating = NO;
    
    if (editing) {
        self.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        self.layer.borderWidth = 0.5;
    }else
    {
        self.layer.borderColor = nil;
        self.layer.borderWidth = 0;
    }
    

}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (NSString *)title
{
    return _titleLabel.text;
}

- (UIView *)snapshotView
{
    UIView * snapshotView = [[UIView alloc]init];
    
    UIView * cellSnapshotView = nil;
    UIView * deleteButtonSnapshotView = nil;
    
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        cellSnapshotView = [self snapshotViewAfterScreenUpdates:NO];
    }
    else {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * cellSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cellSnapshotView = [[UIImageView alloc]initWithImage:cellSnapshotImage];
    }
    
    if ([_deleteButton respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        deleteButtonSnapshotView = [_deleteButton snapshotViewAfterScreenUpdates:NO];
    }
    else {
        UIGraphicsBeginImageContextWithOptions(_deleteButton.bounds.size, _deleteButton.opaque, 0);
        [_deleteButton.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * deleteButtonSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        deleteButtonSnapshotView = [[UIImageView alloc]initWithImage:deleteButtonSnapshotImage];
    }
    
    snapshotView.frame = CGRectMake(-deleteButtonSnapshotView.frame.size.width / 2,
                                    -deleteButtonSnapshotView.frame.size.height / 2,
                                    deleteButtonSnapshotView.frame.size.width / 2 + cellSnapshotView.frame.size.width,
                                    deleteButtonSnapshotView.frame.size.height / 2 + cellSnapshotView.frame.size.height);
    cellSnapshotView.frame = CGRectMake(deleteButtonSnapshotView.frame.size.width / 2,
                                        deleteButtonSnapshotView.frame.size.height / 2,
                                        cellSnapshotView.frame.size.width,
                                        cellSnapshotView.frame.size.height);
    deleteButtonSnapshotView.frame = CGRectMake(cellSnapshotView.frame.size.width-deleteButtonSnapshotView.frame.size.width/2, deleteButtonSnapshotView.frame.size.width/2,
                                                deleteButtonSnapshotView.frame.size.width,
                                                deleteButtonSnapshotView.frame.size.height);
    
    [snapshotView addSubview:cellSnapshotView];
    [snapshotView addSubview:deleteButtonSnapshotView];
    
    return snapshotView;
}

@end
