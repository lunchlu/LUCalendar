

#import <UIKit/UIKit.h>
#import "EPCalendarBaseCell.h"


@interface EPPmplanCalendarCellModel :EPCalendarBaseCellModel
@property (nonatomic, assign) BOOL isCurrentDay;
@property (nonatomic, assign) BOOL isWeekend;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isHaveInfo;
@end


@interface EPPmplanCalendarCell : EPCalendarBaseCell

@end
