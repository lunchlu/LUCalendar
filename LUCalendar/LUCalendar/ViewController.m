/*
 
 LU日历
 提示：1，初始化的frame给出的高度，是日历的最大高度，
 会自动改变自己的高度，并回调回来。
 2，支持自定义的UI，本demo中的EPPmplanCalendarCell为自定义的cell
 自定义时，请创建新得cell与model，并分别继承于EPCalendarBaseCell与EPCalendarBaseCellModel，并在创建EPPmplanCalendarView时给出类的名字。
 3，代理方法中会给你一个EPPmplanCalendarCoreView，并给你一个包涵当前请求月份所有日期的array，请自己根据提供过来日期做自己的处理，然后在把你自定义的model包在array中，调用 EPPmplanCalendarCoreView的 coreView.dataArray = array赋值刷新。
 
 */

#import "ViewController.h"
#import "EPPmplanCalendarView.h"
#import "EPPmplanCalendarCoreView.h"
#import "EPPmplanCalendarCell.h"


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


@interface ViewController ()
<
EPPmplanCalendarCoreViewDelegate
>
@property (nonatomic, strong) EPPmplanCalendarView *calendarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

-(void)setup{
    [self setupCalendar];
}

-(void)setupCalendar{
    self.calendarView = [[EPPmplanCalendarView alloc] initWithFrame:(CGRectMake(0, 20, SCREEN_WIDTH, 250))];
    _calendarView.cellClassName = @"EPPmplanCalendarCell";
    _calendarView.modelClassName = @"EPPmplanCalendarCellModel";
    _calendarView.delegate = self;//必须实现代理
    
    [self.view addSubview:_calendarView];
}


//回调回来请求给出对应的coreView的数据源，返回日期请求模型
-(NSArray *)coreView:(EPPmplanCalendarCoreView *)coreView requestModel:(NSArray *)datas forMonth:(NSDate *)date{
    
    NSMutableArray *array = [NSMutableArray array];
    //不需要请求的处理
    //1.是否是当天
    if (datas && [datas isKindOfClass:[NSArray class]]) {
        
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
                }
                
                EPPmplanCalendarCellModel *model = [[EPPmplanCalendarCellModel alloc] init];
                model.date = date;
                if (dataTitle.length > 7) {
                    model.dateStr   = [dataTitle substringFromIndex:8];
                }
                
                
                if ([[formatter stringFromDate:date] isEqualToString:[formatter stringFromDate:[NSDate date]]]) {
                    model.isCurrentDay = YES;
                }
                else{
                    model.isCurrentDay = NO;
                }
                
                
                NSString *weekStr = [self weekdayStringFromDate:date]?:@"";
                if ([weekStr isEqualToString:@"星期六"]
                    ||[weekStr isEqualToString:@"星期天"])
                {
                    model.isWeekend = YES;
                }
                else{
                    model.isWeekend = NO;
                }
                
                if ([model.dateStr isEqualToString:@"01"]
                    &&![self isCurrentMouth:date])
                {
                    model.isSelected = YES;
                }
                
                
                model.isHaveInfo = YES;
                
                [array addObject:model];
                
            }
        }
        //赋值刷新的地方
        coreView.dataArray = array;
    }
    
    
    return @[];
}

//回调选择的日期对应的模型，和所在月的全部模型
-(void)coreView:(EPPmplanCalendarCoreView *)coreView selectedDate:(EPPmplanCalendarCellModel *)model dataArray:(NSArray *)dataArray{
    for (EPPmplanCalendarCellModel *model in dataArray) {
        model.isSelected = NO;
    }
    model.isSelected = YES;
    coreView.dataArray = [NSMutableArray arrayWithArray:dataArray];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy年MM月dd日";
    NSString* first = [dateFormatter stringFromDate:model.date];
    NSLog(@"%@",first);
    
}

//回调高度的改变
-(void)passCalendarViewHeight:(CGFloat)height data:(NSDate *)data{

}



//是否当前月
-(BOOL)isCurrentMouth:(NSDate *)date{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM";
    NSString* first = [dateFormatter stringFromDate:date];
    NSString* second = [dateFormatter stringFromDate:[NSDate date]];
    if ([first isEqualToString:second]) {
        return 1;
    }
    return 0;
}


// 判断是周几;
- (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

@end














