/*
 
 LU日历
    提示：1，初始化的frame给出的高度，是日历的最大高度，
            会自动改变自己的高度，并回调回来。
         2，支持自定义的UI，本demo中的EPPmplanCalendarCell为自定义的cell
            自定义时，请创建新得cell与model，并分别继承于EPCalendarBaseCell与EPCalendarBaseCellModel，并在创建EPPmplanCalendarView时给出类的名字。
         3，代理方法中会给你一个EPPmplanCalendarCoreView，并给你一个包涵当前请求月份所有日期的array，请自己根据提供过来日期做自己的处理，然后在把你自定义的model包在array中，调用 EPPmplanCalendarCoreView的 coreView.dataArray = array赋值刷新。
 
 */

#import "EPPmplanCalendarView.h"
#import "UIView+Frame.h"
#import "EPCalendarBaseCell.h"

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




#define Weekdays @[@"一", @"二", @"三", @"四", @"五", @"六",@"日"]
@interface EPPmplanCalendarView ()
<
UIScrollViewDelegate,
EPPmplanCalendarCoreViewDelegate
>
//headView
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UILabel *rightLab;
@property (nonatomic, strong) UIImageView *rightImg;
@property (nonatomic, strong) UILabel *headLab;
//weekly
@property (nonatomic, strong) UIView *weekHeadeView;

//日历
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) EPPmplanCalendarCoreView* calendarView1;
@property (nonatomic, strong) EPPmplanCalendarCoreView* calendarView2;
@property (nonatomic, strong) EPPmplanCalendarCoreView* calendarView3;

@property (nonatomic, strong) NSMutableArray *calendarArray;
@property(nonatomic,strong)NSDate* showDate;  //显示的日期

@end

@implementation EPPmplanCalendarView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.showDate = [NSDate date];
        self.backgroundColor = COLOR_HEX(0xf5f5f5);
        [self setupHeadView];
        [self setupWeekHeader];
        [self setupScrollView];
    }
    return self;
}

-(void)setCellClassName:(NSString *)cellClassName{
    _cellClassName = cellClassName;
    [self setupcClendarViewS];
}

-(void)setupHeadView{
    self.headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 30)];
    [self addSubview:_headView];
    _headView.backgroundColor = COLOR_HEX(0xf5f5f5);
    
    UIImageView *leftImg = [[UIImageView alloc] initWithFrame:(CGRectMake(0, 0, 12, 12))];
    leftImg.left = 16;
    leftImg.centerY = _headView.height/2;
    leftImg.image = [UIImage imageNamed:@"leftarrow"];
    leftImg.contentMode = 1;
    [_headView addSubview:leftImg];
    UITapGestureRecognizer *tapLeft1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToLastMonth)];
    [leftImg addGestureRecognizer:tapLeft1];
    leftImg.userInteractionEnabled = YES;
    
    
    UILabel *leftLab = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 100, _headView.height))];
    leftLab.left = leftImg.right +10;
    leftLab.textAlignment = NSTextAlignmentLeft;
    leftLab.text = @"上个月";
    leftLab.textColor = COLOR_HEX(0x666666);
    leftLab.font = MyFont(11);
    [_headView addSubview:leftLab];
    UITapGestureRecognizer *tapLeft2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToLastMonth)];
    [leftLab addGestureRecognizer:tapLeft2];
    leftLab.userInteractionEnabled = YES;

    
    self.rightImg = [[UIImageView alloc] initWithFrame:(CGRectMake(0, 0, 12, 12))];
    _rightImg.right = SCREEN_WIDTH - 16;
    _rightImg.centerY = _headView.height/2;
    _rightImg.image = [UIImage imageNamed:@"rightArrow2"];
    _rightImg.contentMode = 1;
    [_headView addSubview:_rightImg];
    UITapGestureRecognizer *tapRight1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToNextMonth)];
    [_rightImg addGestureRecognizer:tapRight1];
    _rightImg.userInteractionEnabled = YES;

    
    self.rightLab = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 100, _headView.height))];
    _rightLab.right = _rightImg.left - 10;
    _rightLab.textAlignment = NSTextAlignmentRight;
    _rightLab.text = @"下个月";
    _rightLab.textColor = COLOR_HEX(0x666666);
    _rightLab.font = MyFont(11);
    [_headView addSubview:_rightLab];
    UITapGestureRecognizer *tapRight2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToNextMonth)];
    [_rightLab addGestureRecognizer:tapRight2];
    _rightLab.userInteractionEnabled = YES;

    
    
    _headLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, _headView.height)];
    _headLab.centerX = _headView.width/2;
    _headLab.centerY = _headLab.height/2;
    _headLab.textAlignment = NSTextAlignmentCenter;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy年MM月";
    _headLab.text = [formatter stringFromDate:[NSDate date]];
    _headLab.textColor = COLOR_HEX(0x333333);
    _headLab.font = MyFont(14);
    [_headView addSubview:_headLab];
    
    UIView *line = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, SCREEN_WIDTH, 0.5))];
    line.bottom = _headView.height;
    [_headView addSubview:line];
    line.backgroundColor = COLOR_HEX(0xdedede);
    
    _rightImg.hidden =YES;
    _rightLab.hidden = YES;
}

-(void)clickToLastMonth{
    _rightImg.hidden =NO;
    _rightLab.hidden = NO;
    [_scrollView setContentOffset:(CGPointMake(0, 0)) animated:YES];
}

-(void)clickToNextMonth{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy/MM/dd";
    if ([[formatter stringFromDate:self.showDate] isEqualToString:[formatter stringFromDate:[NSDate date]]]) {
        _rightImg.hidden =YES;
        _rightLab.hidden = YES;
    }
    _headLab.text = [self changeDateToString:self.showDate];

    [_scrollView setContentOffset:(CGPointMake(2*SCREEN_WIDTH, 0)) animated:YES];
}



// 设置星期文字的显示
- (void)setupWeekHeader {
    self.weekHeadeView = [[UIView alloc]initWithFrame:CGRectMake(0, _headView.bottom, SCREEN_WIDTH, 30)];
    _weekHeadeView.backgroundColor = COLOR_HEX(0xf5f5f5);
    [self addSubview:_weekHeadeView];
    NSInteger count = [Weekdays count];
    CGFloat width = SCREEN_WIDTH/7;
    for (int i = 0; i < count; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
        weekdayLabel.left = i*width;
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.text = Weekdays[i];
        weekdayLabel.font = [UIFont systemFontOfSize:11];
        weekdayLabel.textColor = COLOR_HEX(0x333333);
        if ([Weekdays[i] isEqualToString:@"日"]
            ||[Weekdays[i] isEqualToString:@"六"])
        {
            weekdayLabel.textColor = COLOR_HEX(0x999999);
        }
        [_weekHeadeView addSubview:weekdayLabel];
    }
}


-(void)setupScrollView{
    CGRect frame = CGRectMake(0, self.weekHeadeView.bottom, self.width, self.height - _weekHeadeView.bottom);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.backgroundColor = COLOR_HEX(0xf5f5f5);
    [self addSubview:_scrollView];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH *3, _scrollView.height);
    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
    _scrollView.delegate = self;
    
}

-(void)setDelegate:(id<EPPmplanCalendarCoreViewDelegate>)delegate{
    _delegate = delegate;
    [self.calendarView1 recieveDate:[self previousMonthDate]];
    [_calendarView2 recieveDate:[NSDate date]];
    [_calendarView3 recieveDate:[self nextMonthDate]];

}

-(void)setupcClendarViewS{
    self.calendarView1 = [[EPPmplanCalendarCoreView alloc]initWithFrame:_scrollView.bounds];
    _calendarView1.left = 0;
    _calendarView1.cellClassName = _cellClassName;
    [_scrollView addSubview:_calendarView1];
    _calendarView1.delegate = self;
    _calendarView1.tag = 1001;
    
    self.calendarView2 = [[EPPmplanCalendarCoreView alloc]initWithFrame:_scrollView.bounds];
    _calendarView2.left = SCREEN_WIDTH;
    _calendarView2.cellClassName = _cellClassName;
    [_scrollView addSubview:_calendarView2];
    _calendarView2.delegate = self;
    _calendarView2.tag = 1002;

    
    self.calendarView3 = [[EPPmplanCalendarCoreView alloc]initWithFrame:_scrollView.bounds];
    _calendarView3.left = SCREEN_WIDTH*2 ;
    _calendarView3.cellClassName = _cellClassName;
    [_scrollView addSubview:_calendarView3];
    _calendarView3.delegate = self;
    _calendarView3.tag = 1003;

    
    self.calendarArray = [NSMutableArray arrayWithArray:@[_calendarView1,_calendarView2,_calendarView3]];
    
}


-(NSArray *)coreView:(EPPmplanCalendarCoreView *)coreView requestModel:(NSArray *)datas forMonth:(NSDate *)date{
    
   if (_delegate
       && [_delegate respondsToSelector:@selector(coreView:requestModel:forMonth:)]) {
       
       NSMutableArray *array = [NSMutableArray new];
       
       NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
       formatter.dateFormat = @"yyyy-MM-dd";
       
       for (int i = 0; i<datas.count; i++) {
           NSDictionary* indexDic = datas[i];
           if (indexDic &&
               [indexDic isKindOfClass:[NSDictionary class]])
           {
               NSString *dataTitle;
               NSDate *date;
               if ([indexDic[@"date"] isKindOfClass:[NSString class]]) {
                   dataTitle = indexDic[@"date"]?:@"";
                   date = [formatter dateFromString:dataTitle];
                   
                   Class modelClass = NSClassFromString(_modelClassName);
                   EPCalendarBaseCellModel *model = [[modelClass alloc] init];
                   if (dataTitle.length > 7) {
                       model.dateStr   = [dataTitle substringFromIndex:8];
                   }
                   model.date   = date;
                   [array addObject:model];
               }
           }
       }
       coreView.dataArray = array;

       [_delegate coreView:coreView requestModel:datas forMonth:date];
    }
    return @[];
}



-(void)coreView:(EPPmplanCalendarCoreView *)coreView selectedDate:(EPCalendarBaseCellModel *)model dataArray:(NSArray *)dataArray{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy/MM";
    NSString *showStr = [formatter stringFromDate:_showDate];
    NSString *dataStr = [formatter stringFromDate:model.date];
    if (![showStr isEqualToString:dataStr]) return;
    
    if (model.date
        &&model.dateStr)
    {
        _headLab.text = [self changeDateToString:model.date];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(coreView:selectedDate:dataArray:)]) {
            [self.delegate coreView:coreView selectedDate:model dataArray:dataArray];
        }
    }
}

-(void)passCalendarViewHeight:(CGFloat)height data:(NSDate *)data{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy/MM";
    NSString *showStr = [formatter stringFromDate:_showDate];
    NSString *dataStr = [formatter stringFromDate:data];
    if (![showStr isEqualToString:dataStr]) return;
    
    
    [UIView animateWithDuration:0.35 animations:^{
        ((UIView *)_calendarArray[1]).height = height;
        _scrollView.height = height;
        _scrollView.contentSize = CGSizeMake(3*SCREEN_WIDTH, _scrollView.height);
        self.height = _scrollView.bottom;
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(passCalendarViewHeight:data:)]) {
        [_delegate passCalendarViewHeight:self.height data:_showDate];
    }
    
}


#pragma mark - scrollView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x >= SCREEN_WIDTH ) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy/MM";
        NSString *showStr = [formatter stringFromDate:_showDate];
        NSString *dataStr = [formatter stringFromDate:[NSDate date]];
        if ([showStr isEqualToString:dataStr]) {
            //禁止下一页
            scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0) ;
            scrollView.contentSize = CGSizeMake(SCREEN_WIDTH *2, 0);
            return;
        }
        else{
            scrollView.contentSize = CGSizeMake(SCREEN_WIDTH *3, 0);
        }
    }
    
    //到了左边
    if (scrollView.contentOffset.x <= 0) {
        [_calendarArray[0] setLeft:SCREEN_WIDTH];
        [_calendarArray[1] setLeft:SCREEN_WIDTH *2];
        [_calendarArray[2] setLeft:0];
        NSArray *array = @[_calendarArray[2],_calendarArray[0],_calendarArray[1]];
        [_calendarArray removeAllObjects];
        _calendarArray = [NSMutableArray arrayWithArray:array];
        _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
        _showDate = [self previousMonthDate];
        [self refresh];
        _rightLab.hidden = NO;
        _rightImg.hidden = NO;

    }
    //到了右边
    else if (scrollView.contentOffset.x >= SCREEN_WIDTH*2 ) {
        [_calendarArray[0] setLeft:SCREEN_WIDTH*2];
        [_calendarArray[1] setLeft:0];
        [_calendarArray[2] setLeft:SCREEN_WIDTH];
        
        NSArray *array = @[_calendarArray[1],_calendarArray[2],_calendarArray[0]];
        [_calendarArray removeAllObjects];
        _calendarArray = [NSMutableArray arrayWithArray:array];
        _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
        _showDate = [self nextMonthDate];
        
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy/MM";
        NSString *showStr = [formatter stringFromDate:_showDate];
        NSString *dataStr = [formatter stringFromDate:[NSDate date]];
        if ([showStr isEqualToString:dataStr]){
            _rightLab.hidden = YES;
            _rightImg.hidden = YES;
            
        }
        
        [self refresh];
    }
    _headLab.text = [self changeDateToString:self.showDate];

}

-(void)refresh{
    [_calendarArray[0] recieveDate:[self previousMonthDate]];
    [_calendarArray[1] recieveDate:_showDate];
    [_calendarArray[2] recieveDate:[self nextMonthDate]];
}


//tool func

// 获取date的下个月日期
- (NSDate *)nextMonthDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 1;
    NSDate *nextMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.showDate options:NSCalendarMatchStrictly];
    return nextMonthDate;
}

// 获取date的上个月日期
- (NSDate *)previousMonthDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -1;
    NSDate *previousMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.showDate options:NSCalendarMatchStrictly];
    return previousMonthDate;
}



//获取当前时间，并转换成年月的形式
-(NSString*)changeDateToString:(NSDate*)date{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy年MM月";
    return [formatter stringFromDate:date];
}

@end























