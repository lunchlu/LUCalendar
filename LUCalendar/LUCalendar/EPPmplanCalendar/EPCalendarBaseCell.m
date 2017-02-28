
#import "EPCalendarBaseCell.h"

@implementation EPCalendarBaseCell


-(void)setModel:(EPCalendarBaseCellModel *)model{
    _model = model;
    for (UIView *view in self.subviews) {
        view.hidden = NO;
    }
}

-(void)setIsNone:(BOOL)isNone{
    if (isNone) {
        for (UIView *view in self.subviews) {
            view.hidden = YES;
        }
    }
    else{
        for (UIView *view in self.subviews) {
            view.hidden = NO;
        }
    }
}


@end


@implementation EPCalendarBaseCellModel


@end
