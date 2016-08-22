//
//  ViewController.m
//  GridMove
//
//  Created by Paul on 16/8/22.
//  Copyright © 2016年 yudo. All rights reserved.
//

#import "ViewController.h"
#import "LxGridView.h"
#import "Masonry.h"

static NSString * const LxGridViewCellReuseIdentifier = @stringify(LxGridViewCellReuseIdentifier);

@interface ViewController () <LxGridViewDataSource, LxGridViewDelegateFlowLayout, LxGridViewCellDelegate>

@property (nonatomic,retain) NSMutableArray * dataArray;

@end

@implementation ViewController
{
    LxGridViewFlowLayout * _gridViewFlowLayout;
    LxGridView * _gridView;
    UIButton * _homeButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    for (int i = 0; i < 6; i++) {
        
        NSMutableDictionary * dataDict = [[NSMutableDictionary alloc]init];
        [dataDict setValue:[NSString stringWithFormat:@"title %d", i] forKey:@"index"];
        [dataDict setValue:[UIImage imageNamed:[NSString stringWithFormat:@"%i", i]] forKey:@"icon_image"];
        [self.dataArray addObject:dataDict];
    }
    
    _gridViewFlowLayout = [[LxGridViewFlowLayout alloc]init];
    _gridViewFlowLayout.sectionInset = UIEdgeInsetsMake(18, 18, 18, 18);
    _gridViewFlowLayout.minimumLineSpacing = 9;
    _gridViewFlowLayout.itemSize = CGSizeMake(58, 78);
    
    _gridView = [[LxGridView alloc]initWithFrame:self.view.bounds collectionViewLayout:_gridViewFlowLayout];
    _gridView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    _gridView.delegate = self;
    _gridView.dataSource = self;
    _gridView.scrollEnabled = NO;
    _gridView.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:_gridView];
    
    [_gridView registerClass:[LxGridViewCell class] forCellWithReuseIdentifier:LxGridViewCellReuseIdentifier];
    
    _homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _homeButton.showsTouchWhenHighlighted = YES;
    _homeButton.layer.masksToBounds = YES;
    _homeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_homeButton setTitle:@"管理" forState:UIControlStateNormal];
    [_homeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_homeButton addTarget:self action:@selector(homeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_homeButton];
    
    [_gridView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom).offset(-44);
    }];
    
    [_homeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(_gridView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (void)homeButtonClicked:(UIButton *)btn
{
    _gridView.editing = _gridView.editing?NO:YES;
    if (_gridView.editing) {
        [_homeButton setTitle:@"完成" forState:UIControlStateNormal];
    }else
    {
        [_homeButton setTitle:@"管理" forState:UIControlStateNormal];

    }
    [_gridView reloadData];
}

#pragma mark - delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LxGridViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:LxGridViewCellReuseIdentifier forIndexPath:indexPath];
    
//    cell.backgroundColor=[UIColor groupTableViewBackgroundColor];
    
    cell.delegate = self;
    cell.editing = _gridView.editing;
    
    NSDictionary * dataDict = self.dataArray[indexPath.item];
    cell.title = dataDict[@"index"];
    cell.iconImageView.image = dataDict[@"icon_image"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath willMoveToIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSDictionary * dataDict = self.dataArray[sourceIndexPath.item];
    [self.dataArray removeObjectAtIndex:sourceIndexPath.item];
    [self.dataArray insertObject:dataDict atIndex:destinationIndexPath.item];
}

- (void)deleteButtonClickedInGridViewCell:(LxGridViewCell *)gridViewCell
{
    NSIndexPath * gridViewCellIndexPath = [_gridView indexPathForCell:gridViewCell];
    
    if (gridViewCellIndexPath) {
        [self.dataArray removeObjectAtIndex:gridViewCellIndexPath.item];
        [_gridView performBatchUpdates:^{
            [_gridView deleteItemsAtIndexPaths:@[gridViewCellIndexPath]];
        } completion:nil];
    }
}

@end
