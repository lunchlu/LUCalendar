

#import "EPPmplanCalendarCell.h"
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


#define itemWidth  (SCREEN_WIDTH) / 7
#define itemHeight  190.0/6


@implementation EPPmplanCalendarCellModel
@end



@interface EPPmplanCalendarCell ()
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIView  *currentDayImg;
@property (nonatomic, strong) UIView  *selectedImg;
@property (nonatomic, strong) UIView  *haveInfoImg;
@end

@implementation EPPmplanCalendarCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{

    self.currentDayImg = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 30, 30))];
    _currentDayImg.layer.borderColor = COLOR_HEX(0x2ec7c9).CGColor;
    _currentDayImg.layer.borderWidth = 1.5;
    _currentDayImg.layer.cornerRadius = _currentDayImg.width/2;
    _currentDayImg.center = CGPointMake(itemWidth/2, itemHeight/2);
    [self.contentView addSubview:_currentDayImg];
    _currentDayImg.hidden = YES;
    
    _selectedImg = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 30, 30))];
    _selectedImg.layer.cornerRadius = _currentDayImg.width/2;
    _selectedImg.backgroundColor = COLOR_HEX(0x2ec7c9);
    _selectedImg.center = CGPointMake(itemWidth/2, itemHeight/2);
    [self.contentView addSubview:_selectedImg];
    _selectedImg.hidden = YES;
    
    self.titleLab = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, SCREEN_WIDTH/7, itemHeight))];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.font = MyFont(14);
    [self.contentView addSubview:_titleLab];
    
    _haveInfoImg = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 4, 4))];
    _haveInfoImg.layer.cornerRadius = _haveInfoImg.width/2;
    _haveInfoImg.center = _titleLab.center;
    _haveInfoImg.top -= 10;
    [self.contentView addSubview:_haveInfoImg];

}

-(void)setModel:(EPPmplanCalendarCellModel *)model{
    [super setModel:model];
    _titleLab.text = model.dateStr;

    
    _currentDayImg.hidden = model.isCurrentDay ? NO :YES;
    _selectedImg.hidden = model.isSelected ? NO :YES;
    _titleLab.textColor = model.isWeekend ? COLOR_HEX(0x999999) :COLOR_HEX(0x333333);
    _haveInfoImg.hidden = model.isHaveInfo ? NO : YES;
    _haveInfoImg.backgroundColor = model.isSelected ? [UIColor whiteColor] :COLOR_HEX(0x2ec7c9);
    _titleLab.textColor = model.isSelected ? [UIColor whiteColor] :_titleLab.textColor;
}





@end
