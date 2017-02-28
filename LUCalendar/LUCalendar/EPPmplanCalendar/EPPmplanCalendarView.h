

#import <UIKit/UIKit.h>
#import "EPPmplanCalendarCoreView.h"
@interface EPPmplanCalendarView : UIView
@property(nonatomic,weak)id<EPPmplanCalendarCoreViewDelegate>delegate;
@property (nonatomic, strong) NSString *cellClassName;
@property (nonatomic, strong) NSString *modelClassName;
@end
