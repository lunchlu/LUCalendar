

#import "EPPmplanCalendarCoreView.h"
#import "EPCalendarBaseCell.h"
#import "UIView+Frame.h"

#define MAIN_SCREEN ([UIScreen mainScreen].bounds)
//add screen's WIDTH and HEIGHT
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define NAVBAR_HEIGHT 64
#define TABBAR_HEIGHT 49

// 颜色(RGB)
#define COLOR_RGB(r, g, b)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define COLOR_RGBA(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define COLOR_HEX(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define MyFont(s)  [UIFont systemFontOfSize:(s)]



@interface EPPmplanCalendarCoreView ()
<
UICollectionViewDataSource,
UICollectionViewDelegate
>
{
    NSInteger _firstWeekday;
    NSInteger _totalDaysOfMonth;
    NSInteger _totalCellCount;
    CGFloat   _maxHeight;
}
@property (strong, nonatomic) UICollectionView *collectionView;
@property(nonatomic,assign)NSInteger row;
@end

@implementation EPPmplanCalendarCoreView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _maxHeight = self.height;
        self.backgroundColor = [UIColor clearColor];
        _dataArray = [NSMutableArray new];
    }
    return self;
}

-(void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    [self.collectionView reloadData];
}

-(void)setCellClassName:(NSString *)cellClassName{
    _cellClassName = cellClassName;
    [self setupCollectionView];
}

-(void)setupCollectionView{
    CGFloat itemWidth = (SCREEN_WIDTH) / 7;
    CGFloat itemHeight = self.height/6;
    UICollectionViewFlowLayout *flowLayot = [[UICollectionViewFlowLayout alloc] init];
    flowLayot.sectionInset = UIEdgeInsetsZero;
    flowLayot.itemSize = CGSizeMake(itemWidth, itemHeight);
    flowLayot.minimumLineSpacing = 0;
    flowLayot.minimumInteritemSpacing = 0;
    
    CGRect collectionViewFrame = self.bounds;
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayot];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:NSClassFromString(_cellClassName) forCellWithReuseIdentifier:@"CalendarCell"];
    [self addSubview:self.collectionView];
}

-(void)recieveDate:(NSDate *)date{
    self.date = date;
    [self.dataArray removeAllObjects];
    
    
    _firstWeekday = [self weekdayOfFirstDayInDate];
    _totalDaysOfMonth = [self totalDaysInMonthOfDate:date];
    _totalCellCount = _firstWeekday+_totalDaysOfMonth-1;
    [self updateCollectionFrame:date];
    
    _row = -1;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString* str = [formatter stringFromDate:date];
    NSString* dateStr = [formatter stringFromDate:[NSDate date]];
    
    if ([str isEqualToString:dateStr]) {
        //选中今天
        _row = [self indexPathFromDate:[NSDate date]];
    }else{
        //其他月的第一天
        _row = [self rowForFirstDay:date];
    }
    [self makeFirstShow];
//    [self requestForClockInRecords:date];
}

-(void)updateCollectionFrame:(NSDate*)date{
    
    NSInteger lines = 0;
    if (_totalCellCount <= 28) {
        lines = 4;
    }else if (_totalCellCount <= 35){
        lines = 5;
    }else{
        lines = 6;
    }
//    CGRect frame = self.collectionView.frame;
//    frame.size.height = self.height/6 *lines;
    
    [UIView animateWithDuration:0.35 animations:^{
        self.collectionView.height = _maxHeight/6 *lines;
    }];
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(passCalendarViewHeight:data:)]) {
        [_delegate passCalendarViewHeight:_collectionView.height data:_date];
    }
}

-(void)makeFirstShow{
    NSArray *array = [self firstDayAndLastDay:_date];
    NSString *first = array[0];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate *firstDate = [formatter dateFromString:first];
    
    
    NSInteger days = [self totalDaysInMonthOfDate:_date];
    NSMutableArray *dictArray = [NSMutableArray array];
    for (int i = 0; i<days; i++) {
        [dictArray addObject:@{
                               @"date": [formatter stringFromDate:firstDate]
                               }];
        firstDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:firstDate];
    }
    
    if (_delegate
        &&[_delegate respondsToSelector:@selector(coreView:requestModel:forMonth:)])
    {
        [_delegate coreView:self requestModel:dictArray forMonth:_date];
    }
}

//collectionView 代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    NSInteger totalDaysOfMonth = [self totalDaysInMonthOfDate:self.date];
    return firstWeekday+totalDaysOfMonth-1;
}

- (UICollectionViewCell *)collectionView:(EPCalendarBaseCell *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CalendarCell";
    EPCalendarBaseCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(EPCalendarBaseCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    NSInteger totalDaysOfMonth = [self totalDaysInMonthOfDate:self.date];
    
    if (_dataArray.count<1) return;
    
    if (indexPath.row < firstWeekday-1) {
        // 小于这个月的第一天
        cell.isNone = YES;
    } else if (indexPath.row >= totalDaysOfMonth + firstWeekday-1) {
        // 大于这个月的最后一天
        cell.isNone = YES;
    } else {
        int index = (int)indexPath.row;
        int count = index - (int)(firstWeekday -1);
        cell.model = self.dataArray[count];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    EPCalendarBaseCellModel *model =((EPCalendarBaseCell *)cell).model;
    if (((EPCalendarBaseCell *)cell).isNone == YES) return;
    
    if (_delegate
        &&[_delegate respondsToSelector:@selector(coreView:selectedDate:dataArray:)])
    {
        [_delegate coreView:self selectedDate:model dataArray:_dataArray];
    }
}



//tool func
// 获取date当前月的第一天是星期几
- (NSInteger)weekdayOfFirstDayInDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
    [components setDay:1];
    NSDate *firstDate = [calendar dateFromComponents:components];
    NSDateComponents *firstComponents = [calendar components:NSCalendarUnitWeekday fromDate:firstDate];
    if (firstComponents.weekday-1 != 0) {
        return firstComponents.weekday-1;
    }else{
        return 7;
    }
}

// 获取date当前月的总天数
- (NSInteger)totalDaysInMonthOfDate:(NSDate *)date {
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

// 根据indexpath获取对应的日期
-(NSDate*)dateFromIndexPath:(NSIndexPath*)indexPath{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
    
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    [components setDay:indexPath.row - firstWeekday + 2];
    NSDate *selectedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    
    return selectedDate;
}

// 根据NSDate获取NSInteger
-(NSInteger)indexPathFromDate:(NSDate*)date{
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSInteger day = components.day;
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    NSInteger row = day +firstWeekday -2;
    
    return row;
}

// 求出指定日期所在月的第一天的indexpath.row
-(NSInteger)rowForFirstDay:(NSDate*)date{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    [components setDay:1];
    NSDate* first = [calendar dateFromComponents:components];
    NSInteger firstRow = [self indexPathFromDate:first];
    return firstRow;
}

-(NSArray*)firstDayAndLastDay:(NSDate*)date{
    NSInteger firstIndex = [self rowForFirstDay:date];
    NSDate* firstDate = [self dateFromIndexPath:[NSIndexPath indexPathForItem:firstIndex inSection:0]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString* first = [dateFormatter stringFromDate:firstDate];
    
    NSString* last;
    //    if ([self isCurrentMouth]) {
    //        last = [dateFormatter stringFromDate:date];
    //    }
    //    else{
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    NSInteger totalDaysOfMonth = [self totalDaysInMonthOfDate:self.date];
    NSInteger lastIndex = firstWeekday+totalDaysOfMonth-1-1;
    NSDate* lastDate = [self dateFromIndexPath:[NSIndexPath indexPathForItem:lastIndex inSection:0]];
    last = [dateFormatter stringFromDate:lastDate];
    //    }
    
    return @[first,last];
}

@end














