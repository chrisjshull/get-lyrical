#import "ITObserver.h"

@implementation ITObserver

+(id)newITObserver {
    NSLog(@"Created iTunes Observer");
    return [[super alloc] init];
}

-(void)dealloc {
    [super dealloc];
}

-(void)beginObservingiTunes {
    NSLog(@"Begin Observing");
    [[NSDistributedNotificationCenter defaultCenter]
        addObserver:self 
        selector:@selector(handleiTunesNotification:) 
        name:@"com.apple.iTunes.playerInfo" 
        object:nil];
}

-(void)endObservingiTunes {
    NSLog(@"End Observing");
    [[NSDistributedNotificationCenter defaultCenter] 
        removeObserver:self 
        name:@"com.apple.iTunes.playerInfo" 
        object:nil];
}

-(void)handleiTunesNotification:(NSNotification *)aNotification {
    NSLog(@"Handle Notification");
    [asActionButton performClick:nil];
}

-(void)setActionButton:(NSButton *)theButton {
    asActionButton = theButton;
}

@end