/* MyAppController */

#import <Cocoa/Cocoa.h>
#import "RAMON.h"
#include "FreeSurfer.h"
#import "MyView.h"
#import "MyTextView.h"

@interface MyAppController : RAMON
{
    IBOutlet MyView *view;
	IBOutlet MyTextView *text;
    
    int isSmooth;
    int isCurvature;
}
-(void)configureVisualisation;
-(void)cleanVisualisation;

-(IBAction)standard:(id)sender;
-(IBAction)zoom:(id)sender;
-(void)applyScript:(NSString*)s;
@end
