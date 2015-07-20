#import "MyView.h"
#include "colourmap.h"
@implementation MyView

float3D add3D(float3D a, float3D b)
{
    return (float3D){a.x+b.x,a.y+b.y,a.z+b.z};
}
float3D sub3D(float3D a, float3D b)
{
    return (float3D){a.x-b.x,a.y-b.y,a.z-b.z};
}
float3D sca3D(float3D a, float t)
{
    return (float3D){a.x*t,a.y*t,a.z*t};
}
float dot3D(float3D a, float3D b)
{
    return (float){a.x*b.x+a.y*b.y+a.z*b.z};
}
float3D cross3D(float3D a, float3D b)
{
    return (float3D){a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x};
}
float norm3D(float3D a)
{
    return sqrt(a.x*a.x+a.y*a.y+a.z*a.z);
}

-(void)setFreeSurferPoints:(char*)newP triangles:(char*)newT data:(char*)newD np:(int)newNp nt:(int)newNt
{
	p=(float3D*)newP;
	t=(int3D*)newT;
	d=(float*)newD;
	np=newNp;
	nt=newNt;
	
	[self configureCentre];
	
	printf("np:%i nt:%i\n",np,nt);
}
-(void)setFreeSurferData:(char*)newD
{
	int			i;
    float		n,max;
	float3D		ce={0,0,0},ide,siz;
	
	d=(float*)newD;

    /* TEST: replace the data with 1s */
	//for(i=0;i<np;i++)
	//	d[i]=1;
	
	// compute sulcal depth
	for(i=0;i<np;i++)
	{
		ce=(float3D){ce.x+p[i].x,ce.y+p[i].y,ce.z+p[i].z};
		
		if(i==0) ide=siz=p[i];
		
		if(ide.x<p[i].x) ide.x=p[i].x;
		if(ide.y<p[i].y) ide.y=p[i].y;
		if(ide.z<p[i].z) ide.z=p[i].z;
		
		if(siz.x>p[i].x) siz.x=p[i].x;
		if(siz.y>p[i].y) siz.y=p[i].y;
		if(siz.z>p[i].z) siz.z=p[i].z;
	}
	ce=(float3D){ce.x/(float)np,ce.y/(float)np,ce.z/(float)np};

	if(sdepth!=nil)
		free(sdepth);
	sdepth=(float*)calloc(np,sizeof(float));
	max=0;
    for(i=0;i<np;i++)
    {
        n=	pow(2*(p[i].x-ce.x)/(ide.x-siz.x),2) +
			pow(2*(p[i].y-ce.y)/(ide.y-siz.y),2) +
			pow(2*(p[i].z-ce.z)/(ide.z-siz.z),2);

        sdepth[i] = sqrt(n);
        if(sdepth[i]>max)	max=sdepth[i];
    }
    max*=1.05;	// pure white is not nice...
    for(i=0;i<np;i++)
        sdepth[i]=sdepth[i]/max;
}
-(void)configureVerticesColour
{
	int	i,j;
	
	if(vcolour)
	{
		free(vcolour);
		vcolour=nil;
	}
	vcolour=(float3D*)calloc(np,sizeof(float3D));
	
	/* 1. map data to colours using a colourmap
	int		i;
	unsigned char	c[4];
	for(i=0;i<np;i++)
	{
		colourmap(d[i],c,JET);//GRAY
		vcolour[i]=(float3D){c[0]/255.0,c[1]/255.0,c[2]/255.0};
	}
	*/
	
	for(i=0;i<np;i++)
		vcolour[i]=(float3D){sdepth[i],sdepth[i],sdepth[i]};
	return; // comment-out to render surface labels
	
	/* 2. map data to colours using FS annotation label colours */
	int	lab[35][3]={{ 25,  5, 25}, { 25,100, 40}, {125,100,160}, {100, 25,  0}, {120, 70, 50},
					{220, 20,100}, {220, 20, 10}, {180,220,140}, {220, 60,220}, {180, 40,120},
					{140, 20,140}, { 20, 30,140}, { 35, 75, 50}, {225,140,140}, {200, 35, 75},
					{160,100, 50}, { 20,220, 60}, { 60,220, 60}, {220,180,140}, { 20,100, 50},
					{220, 60, 20}, {120,100, 60}, {220, 20, 20}, {220,180,220}, { 60, 20,220},
					{160,140,180}, { 80, 20,140}, { 75, 50,125}, { 20,220,160}, { 20,180,140},
					{140,220,220}, { 80,160, 20}, {100,  0,100}, { 70, 70, 70}, {150,150,200}};
	for(i=0;i<np;i++)
	{
		j=(int)d[i];
		vcolour[i]=(float3D){sdepth[i]*lab[j][0]/255.0,sdepth[i]*lab[j][1]/255.0,sdepth[i]*lab[j][2]/255.0};
	}
}
-(void)configureCentre
{
	int		i;
	float3D	zero={0,0,0};
	
	centre=zero;
	
	for(i=0;i<np;i++)
		centre=(float3D){centre.x+p[i].x,centre.y+p[i].y,centre.z+p[i].z};
	centre=(float3D){centre.x/(float)np,centre.y/(float)np,centre.z/(float)np};
}
-(void)cleanFreeSurfer
{
}
#pragma mark -
- (id) initWithFrame: (NSRect) frame
{
    GLuint attribs[] = 
    {
            NSOpenGLPFANoRecovery,
            NSOpenGLPFAWindow,
            NSOpenGLPFAAccelerated,
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFAAlphaSize, 8,
            NSOpenGLPFADepthSize, 24,
            NSOpenGLPFAStencilSize, 8,
            NSOpenGLPFAAccumSize, 0,
            0
    };

    NSOpenGLPixelFormat* fmt = [[NSOpenGLPixelFormat alloc] initWithAttributes: (NSOpenGLPixelFormatAttribute*) attribs];
    
    self = [super initWithFrame:frame pixelFormat:[fmt autorelease]];
    if (!fmt)	NSLog(@"No OpenGL pixel format");
    [[self openGLContext] makeCurrentContext];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_SMOOTH);
	
    // initialize the trackball
    m_trackball = [[Trackball alloc] init];
    m_rotation[0] = m_tbRot[0] = 0.0;
    m_rotation[1] = m_tbRot[1] = 1.0;
    m_rotation[2] = m_tbRot[2] = 0.0;
    m_rotation[3] = m_tbRot[3] = 0.0;
    rot[0]=rot[1]=rot[2]=0;
	
	zoom=1;
	centreMesh=1;
	hemisphere=0;
	sdepth=nil;
	vcolour=nil;

    return self;
}
- (void) drawRect: (NSRect) rect
{
    int		i;
	float3D	x,c,zero={0,0,0};
	float	aspectRatio=(float)rect.size.width/(float)rect.size.height;
    
    [self update];

    // init projection
        glViewport(0, 0, (GLsizei) rect.size.width, (GLsizei) rect.size.height);
        glClearColor(1,1,1, 1);
        glClear(GL_COLOR_BUFFER_BIT+GL_DEPTH_BUFFER_BIT+GL_STENCIL_BUFFER_BIT);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrtho(-aspectRatio*zoom, aspectRatio*zoom, -zoom, zoom, -100000.0, 100000.0);

    // prepare drawing
        glMatrixMode (GL_MODELVIEW);
        glLoadIdentity();
        gluLookAt (0,0,-10, 0,0,0, 0,1,0); // eye,center,updir
        glRotatef(m_tbRot[0],m_tbRot[1], m_tbRot[2], m_tbRot[3]);
        glRotatef(m_rotation[0],m_rotation[1],m_rotation[2],m_rotation[3]);
        glRotatef(rot[0],1,0,0);
        glRotatef(rot[1],0,1,0);
        glRotatef(rot[2],0,0,1);

    // draw
        /*glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(3,GL_FLOAT,0,(GLfloat*)p);
        glEnableClientState(GL_COLOR_ARRAY);
        glColorPointer(3,GL_FLOAT,0,(GLfloat*)vcolour);
        glDrawElements(GL_TRIANGLES,nt*3,GL_UNSIGNED_INT,(GLuint*)t);*/

		glBegin(GL_TRIANGLES);
		c=centreMesh?centre:zero;
		for(i=0;i<nt;i++)
		{
			x=(float3D){p[t[i].a].x-c.x,p[t[i].a].y-c.y,p[t[i].a].z-c.z};
			glColor3fv((GLfloat*)&vcolour[t[i].a]);
			glVertex3fv((float*)&x);
			
			x=(float3D){p[t[i].b].x-c.x,p[t[i].b].y-c.y,p[t[i].b].z-c.z};
			glColor3fv((GLfloat*)&vcolour[t[i].b]);
			glVertex3fv((float*)&x);
			
			x=(float3D){p[t[i].c].x-c.x,p[t[i].c].y-c.y,p[t[i].c].z-c.z};
			glColor3fv((GLfloat*)&vcolour[t[i].c]);
			glVertex3fv((float*)&x);
		}
		glEnd();


    [[self openGLContext] flushBuffer];
}
#pragma mark -
- (void)rotateBy:(float *)r
{
    m_tbRot[0] = r[0];
    m_tbRot[1] = r[1];
    m_tbRot[2] = r[2];
    m_tbRot[3] = r[3];
}
- (void)mouseDown:(NSEvent *)theEvent
{
    [m_trackball start:[theEvent locationInWindow] sender:self];
}
- (void)mouseUp:(NSEvent *)theEvent
{
    // Accumulate the trackball rotation
    // into the current rotation.
    [m_trackball add:m_tbRot toRotation:m_rotation];

    m_tbRot[0]=0;
    m_tbRot[1]=1;
    m_tbRot[2]=0;
    m_tbRot[3]=0;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self lockFocus];
    [m_trackball rollTo:[theEvent locationInWindow] sender:self];
    [self unlockFocus];
    [self setNeedsDisplay:YES];
}
-(void)setStandardRotation:(int)indx
{
    m_rotation[0] = m_tbRot[0] = 0.0;
    m_rotation[1] = m_tbRot[1] = 0.0;
    m_rotation[2] = m_tbRot[2] = 1.0;
    m_rotation[3] = m_tbRot[3] = 0.0;
    
    switch(indx)
    {
        case 1:m_rotation[0]=270;	m_rotation[1]=1;m_rotation[2]=0; break; //sup
        case 4:m_rotation[0]= 90;	break; //frn
        case 5:m_rotation[0]=  0;	break; //tmp
        case 6:m_rotation[0]=270;	break; //occ
        case 7:m_rotation[0]=180;	break; //med
        case 9:m_rotation[0]= 90;	m_rotation[1]=1;m_rotation[2]=0; break; //cau
    }
    [self setNeedsDisplay:YES];
}
-(void)setZoom:(float)z
{
	zoom=pow(2,-z);
	[self setNeedsDisplay:YES];
}
-(void)setCentreMesh:(int)cm
{
	centreMesh=cm;
}
-(void)setHemisphere:(int)hem
{
	hemisphere=hem;
}

-(void)smooth
{
	int		i,k;
	float3D	*tmp=(float3D*)calloc(np,sizeof(float3D));
	int		*itmp=(int*)calloc(np,sizeof(int));

	for(k=0;k<50;k++)
	{
		for(i=0;i<np;i++)
		{
			tmp[i]=(float3D){0,0,0};
			itmp[i]=0;
		}
		
		for(i=0;i<nt;i++)
		{
			tmp[t[i].a].x+=p[t[i].b].x+p[t[i].c].x;
			tmp[t[i].b].x+=p[t[i].c].x+p[t[i].a].x;
			tmp[t[i].c].x+=p[t[i].a].x+p[t[i].b].x;

			tmp[t[i].a].y+=p[t[i].b].y+p[t[i].c].y;
			tmp[t[i].b].y+=p[t[i].c].y+p[t[i].a].y;
			tmp[t[i].c].y+=p[t[i].a].y+p[t[i].b].y;

			tmp[t[i].a].z+=p[t[i].b].z+p[t[i].c].z;
			tmp[t[i].b].z+=p[t[i].c].z+p[t[i].a].z;
			tmp[t[i].c].z+=p[t[i].a].z+p[t[i].b].z;

			itmp[t[i].a]+=2;
			itmp[t[i].b]+=2;
			itmp[t[i].c]+=2;
		}
		
		for(i=0;i<np;i++)
			p[i]=(float3D){tmp[i].x/(float)itmp[i],tmp[i].y/(float)itmp[i],tmp[i].z/(float)itmp[i]};
	}
	
	free(tmp);
	free(itmp);

	[self configureCentre];
	[self setNeedsDisplay:YES];
}
-(void)curvature
{
    float3D *tmp,*tmp1;
    int     *n;
    float3D nn;
    float   absmax,*C;
    int     i;
    
    tmp=(float3D*)calloc(np,sizeof(float3D));
    n=(int*)calloc(np,sizeof(int));
    // compute smoothing direction as the vector to the average of neighbour vertices
    for(i=0;i<nt;i++)
    {
        tmp[t[i].a]=add3D(tmp[t[i].a],add3D(p[t[i].b],p[t[i].c]));
        tmp[t[i].b]=add3D(tmp[t[i].b],add3D(p[t[i].c],p[t[i].a]));
        tmp[t[i].c]=add3D(tmp[t[i].c],add3D(p[t[i].a],p[t[i].b]));
        n[t[i].a]+=2;
        n[t[i].b]+=2;
        n[t[i].c]+=2;
    }
    for(i=0;i<np;i++)
        tmp[i]=sub3D(sca3D(tmp[i],1/(float)n[i]),p[i]);
    
    tmp1=(float3D*)calloc(np,sizeof(float3D));
    // compute normal direction as the average of neighbour triangle normals
    for(i=0;i<nt;i++)
    {
        nn=cross3D(sub3D(p[t[i].b],p[t[i].a]),sub3D(p[t[i].c],p[t[i].a]));
        nn=sca3D(nn,1/norm3D(nn));
        tmp1[t[i].a]=add3D(tmp1[t[i].a],nn);
        tmp1[t[i].b]=add3D(tmp1[t[i].b],nn);
        tmp1[t[i].c]=add3D(tmp1[t[i].c],nn);
    }
    for(i=0;i<np;i++)
        tmp1[i]=sca3D(tmp1[i],1/(float)n[i]);
    free(n);
    
    C=(float*)calloc(np,sizeof(float));
    for(i=0;i<np;i++)
        C[i]=-dot3D(tmp1[i],tmp[i]);
    free(tmp);
    free(tmp1);
    
    absmax=-1;
    for(i=0;i<np;i++)
        absmax=(fabs(C[i])>absmax)?fabs(C[i]):absmax;
    absmax*=0.95;
    for(i=0;i<np;i++)
    {
        C[i]/=2*absmax;
        if(C[i]>0.5)    C[i]=0.5;
        if(C[i]<-0.5)   C[i]=-0.5;
        C[i]+=0.5;
    }
    
    for(i=0;i<np;i++)
    {
        if(C[i]>0.5)
            vcolour[i]=(float3D){sdepth[i]*C[i],0,0};
        else
            vcolour[i]=(float3D){0,sdepth[i]*C[i],0};
    }
}

@end
