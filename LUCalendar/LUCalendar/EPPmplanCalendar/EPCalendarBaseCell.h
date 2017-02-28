

#import <UIKit/UIKit.h>

@interface EPCalendarBaseCellModel : NSObject
@property (nonatomic, strong) NSString *dateStr;//10
@property (nonatomic, strong) NSDate *date;
@end


@interface EPCalendarBaseCell : UICollectionViewCell
@property (nonatomic, assign) BOOL isNone;
@property (nonatomic, strong) EPCalendarBaseCellModel *model;
@end
