/* MyView */

#import <Cocoa/Cocoa.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#import "Trackball.h"
#include "FreeSurfer.h"

@interface MyView : NSOpenGLView
{
	float3D		*p;
	int3D		*t;
	float		*d,*sdepth;
	int			np;
	int			nt;
	
	float3D		*vcolour;
	
	Trackball	*m_trackball;
	float		m_rotation[4];	// The main rotation
	float		m_tbRot[4];		// The trackball rotation
	float		rot[3];
	
	float		zoom;
	int			centreMesh;
	float3D		centre;
	int			hemisphere;
}
-(void)setFreeSurferPoints:(char*)newP triangles:(char*)newT data:(char*)newD np:(int)newNp nt:(int)newNt;
-(void)setFreeSurferData:(char*)newD;
-(void)configureVerticesColour;
-(void)configureCentre;
-(void)cleanFreeSurfer;

- (void)rotateBy:(float *)r;		// trackball method

-(void)setStandardRotation:(int)indx;
-(void)setZoom:(float)z;
-(void)setCentreMesh:(int)cm;
-(void)setHemisphere:(int)hem;
-(void)smooth;
-(void)curvature;
@end
