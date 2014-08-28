#import <Cocoa/Cocoa.h>

@interface ITObserver : NSObject {
    NSButton *asActionButton;
}

+(id)newITObserver;

-(void)beginObservingiTunes;
-(void)endObservingiTunes;

-(void)handleiTunesNotification:(NSNotification *)aNotification;
-(void)setActionButton:(NSButton *)theButton;
@end