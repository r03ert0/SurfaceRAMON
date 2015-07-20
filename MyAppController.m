#import "MyAppController.h"

@implementation MyAppController
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self setObjectType:"FreeSurfer"];
	[self ramonizeAtLaunch];
	[text setApp:self];
    
    isSmooth=0;
    isCurvature=0;
}
-(void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self ramonizeAtTerminate];
}
#pragma mark -
-(void)configureVisualisation
{
	FreeSurferHeader	hdr;
	char				*p;
	char				*t;
	char				*d;
	int					np,nt;
	
	hdr=*(FreeSurferHeader*)shm;
	np=hdr.np;
	nt=hdr.nt;
	p=shm+sizeof(hdr);
	t=shm+sizeof(hdr)+np*sizeof(float)*3;
	d=shm+sizeof(hdr)+np*sizeof(float)*3+nt*sizeof(int)*3;
	
    [view setFreeSurferPoints:p triangles:t data:d np:np nt:nt];
	[view setFreeSurferData:d];
	[view configureVerticesColour];
	if(isSmooth)
        [view smooth];
	if(isCurvature)
        [view curvature];
    [view setNeedsDisplay:YES];
}
-(void)cleanVisualisation
{
}
#pragma mark -
-(IBAction)standard:(id)sender
{
	int	tag=[[sender selectedCell] tag];
	[view setStandardRotation:tag];
}
-(IBAction)zoom:(id)sender
{
	float	z=[sender floatValue];
	[view setZoom:z];
}
-(void)applyScript:(NSString*)s
{
	char		*cs,cmd[64];
	int			n;
	char		str[256];
	
    cs=(char*)[s UTF8String];
    printf("[%s]\n",cs);
	n=0;
	while(cs[n]!=' ' && cs[n]!='\r' && cs[n]!='\n' && n<63)
    {
		cmd[n]=cs[n];
        n++;
    }
	cmd[n]=(char)0;
	printf("%s\n",cmd);

	if(strcmp(cmd,"smooth")==0)
	{
		[view smooth];
	}
	else
	if(strcmp(cmd,"curvature")==0)
	{
		[view curvature];
	}
	else
	if(strcmp(cmd,"setCentreMesh")==0)
	{
		n=sscanf(cs," setCentreMesh %s ",str);
		if(n==1)
		{
			if(strcmp(str,"on")==0)
				[view setCentreMesh:1];
			else
			if(strcmp(str,"off")==0)
				[view setCentreMesh:0];
		}
	}
	else
    if(strcmp(cmd,"setHemisphere")==0)
    {
        n=sscanf(cs," setHemisphere %s ",str);
        if(n==1)
            [self sendMessage:str];
    }
    else
    if(strcmp(cmd,"toggleSmooth")==0)
    {
        isSmooth=!isSmooth;
    }
    else
    if(strcmp(cmd,"toggleCurvature")==0)
    {
        isCurvature=!isCurvature;
    }
	[view setNeedsDisplay:YES];
}
@end
