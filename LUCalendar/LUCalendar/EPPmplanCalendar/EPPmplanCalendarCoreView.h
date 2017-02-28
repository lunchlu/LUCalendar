

#import <UIKit/UIKit.h>
@class EPCalendarBaseCellModel;
@class EPPmplanCalendarCoreView;
@protocol EPPmplanCalendarCoreViewDelegate <NSObject>
//当前月份的每一天
-(NSArray *)coreView:(EPPmplanCalendarCoreView *)coreView requestModel:(NSArray *)datas forMonth:(NSDate *)date;
//回调选择的日期，和日期字符串
-(void)coreView:(EPPmplanCalendarCoreView *)coreView selectedDate:(EPCalendarBaseCellModel *)model dataArray:(NSArray *)dataArray;
//回调view的高度
-(void)passCalendarViewHeight:(CGFloat)height data:(NSDate *)data;
@end


@interface EPPmplanCalendarCoreView : UIView
@property (weak, nonatomic) id<EPPmplanCalendarCoreViewDelegate> delegate;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *cellClassName;
- (void)recieveDate:(NSDate*)date;
@end
