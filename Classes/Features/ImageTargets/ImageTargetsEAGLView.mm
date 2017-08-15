/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <Vuforia/Vuforia.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/VideoBackgroundConfig.h>

#import "ImageTargetsEAGLView.h"
#import "Texture.h"
#import "SampleApplicationUtils.h"
#import "SampleApplicationShaderUtils.h"

#import "arrow0.h"
#import "arrow1.h"
#import "arrow2.h"
#import "arrow3.h"
#import "arrow4.h"

#import "logo1.h"
#import "logo2.h"
#import "logo3.h"
#import "logo4.h"
#import "logo5.h"
#import "logo6.h"
#import "logo7.h"


#import "arrow.h"

#define timerEnd 100


//******************************************************************************
// *** OpenGL ES thread safety ***
//
// OpenGL ES on iOS is not thread safe.  We ensure thread safety by following
// this procedure:
// 1) Create the OpenGL ES context on the main thread.
// 2) Start the Vuforia camera, which causes Vuforia to locate our EAGLView and start
//    the render thread.
// 3) Vuforia calls our renderFrameVuforia method periodically on the render thread.
//    The first time this happens, the defaultFramebuffer does not exist, so it
//    is created with a call to createFramebuffer.  createFramebuffer is called
//    on the main thread in order to safely allocate the OpenGL ES storage,
//    which is shared with the drawable layer.  The render (background) thread
//    is blocked during the call to createFramebuffer, thus ensuring no
//    concurrent use of the OpenGL ES context.
//
//******************************************************************************


namespace {
    // --- Data private to this unit ---

    const char* textureFilenames[] = {
        "arrow1.jpg",
        "arrow2.jpg",
        "logo1.png",
    };
    /*
     "logo1.png",
     "logo2.png",
     "logo3.png",
     "logo4.png",
     "logo5.png",
     "logo6.png",
     "logo7.png"
     */
    
    
    // Model scale factor
    const float kObjectScaleNormal = 0.3f;

    int arrowIndexes [logoNum][markNum];
    
    const GLvoid* verts;
    const GLvoid* normals;
    const GLvoid* texCoords;
    int numVerts;
    
    CGRect screenRect;
    int width;
    int height;
    
    int timer;

}



@interface ImageTargetsEAGLView (PrivateMethods)


- (void)initShaders;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;
@end


@implementation ImageTargetsEAGLView

@synthesize vapp = vapp;



-(void)updateLogoName
{
    logoLabel.text = logoNames[logoIndex];
    
}
-(void)updateInstruction
{    NSLog(@"UPDATE !!!");
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/10, height/10*5.3, width-width/10*2, height/3)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont fontWithName:@"SukhumvitSet-Text" size:17.0f];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = @"Please go in the direction of the arrow until you find the next marker.";
    [self addSubview:textLabel];

}
-(void)removeInstructionAndMask
{
    [self->textLabel removeFromSuperview];
    [self->mask removeFromSuperview];
    [self showReturnButton];
}
-(void)showScanInstruction
{
    //black screen mask
    mask= [[UIImageView alloc] initWithImage : [UIImage imageNamed:@"mask.png"]];
    [mask setFrame:CGRectMake(0,0,width,height)];
    [self addSubview:mask];
    
    //testlabel showing instruction
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/10, height/10*6.6, width-width/10*2, height/10)];
    textLabel.numberOfLines = 0;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor whiteColor];

    textLabel.text = @"Please place the logo at the center of the square for better recognition result.";
        //line space
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textLabel.text];
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle setLineSpacing:0.0];
//    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textLabel.text length])];
//    textLabel.attributedText = attributedString;
    textLabel.font = [UIFont fontWithName:@"SukhumvitSet-Text" size:17.0f];
    [self addSubview:textLabel];
}

-(void)showLogoMessage
{
    //change text content
    [self->textLabel removeFromSuperview];
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/6, height/10*6.4, width-width/8*2, height/5)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont fontWithName:@"SukhumvitSet-Text" size:17.0f];
    textLabel.text = @"is this the company you are looking for?";
    [self addSubview:textLabel];
    
    //label showing company name
    logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/10, height/10*6.3, width-width/10*2, height/10)];
    logoLabel.backgroundColor = [UIColor clearColor];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    logoLabel.textColor = [UIColor colorWithRed:252/255.0 green:90.0/255.0 blue:136.0/255.0 alpha:1];
    logoLabel.numberOfLines = 0;
    logoLabel.font = [UIFont fontWithName:@"SukhumvitSet-Text" size:25.0f];
    logoLabel.text = logoNames[logoIndex];
    [self addSubview:logoLabel];
    
    // yes button
    UIImage *yesimage = [UIImage imageNamed:@"yesButton.png"];
    int imgwidthoffset = (width-width/10*2)/0.95*0.025;
    yesButton = [[UIButton alloc] initWithFrame:CGRectMake( width/10-imgwidthoffset,height/5*3.98, (width-width/10*2)/0.95,(width-width/10*2)/0.95/4.6)];
    [yesButton addTarget:self action:@selector(checkYesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [yesButton setBackgroundImage:yesimage forState:UIControlStateNormal];
    [self addSubview:yesButton];

 
}

- (void)checkYesButtonTapped:(id)sender
{
    logoMode = NO;
    markerMode = YES;
    [self->yesButton removeFromSuperview];
    [self->logoLabel removeFromSuperview];
    [self->textLabel removeFromSuperview];

    NSLog(@"button yes pressed");
}
-(void)reachDestination
{
    
    [self->yesButton removeFromSuperview];
    [self->logoLabel removeFromSuperview];
    [self->textLabel removeFromSuperview];
    [self removeInstructionAndMask];
    [self->returnButton removeFromSuperview];
    
    endBackground= [[UIImageView alloc] initWithImage : [UIImage imageNamed:@"endBackground.png"]];
    endBackground.contentMode = UIViewContentModeScaleAspectFit;
    [endBackground setFrame:CGRectMake(0,-50,width,height)];
    [self addSubview:endBackground];
    
    endLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/10, height/10*4.1, width-width/10*2, height/10)];
    endLabel.backgroundColor = [UIColor clearColor];
    endLabel.textAlignment = NSTextAlignmentCenter;
    endLabel.textColor = [UIColor whiteColor];
    endLabel.numberOfLines = 0;
    endLabel.text = @"is Here!";
    endLabel.font = [UIFont fontWithName:@"SukhumvitSet-Text" size:17.0f];
    [self addSubview:endLabel];
    
    logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/10, height/10*3.65, width-width/10*2, height/10)];
    logoLabel.backgroundColor = [UIColor clearColor];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    logoLabel.textColor = [UIColor colorWithRed:252/255.0 green:90.0/255.0 blue:136.0/255.0 alpha:1];
    logoLabel.numberOfLines = 0;
    logoLabel.text = logoNames[logoIndex];
    logoLabel.font = [UIFont fontWithName:@"SukhumvitSet-Text" size:25.0f];
    [self addSubview:logoLabel];
    
    UIImage *endimage = [UIImage imageNamed:@"endButton.png"];
    endButton = [[UIButton alloc] initWithFrame:CGRectMake(width*3/8,height/5*4.2, width/4,width/4)];
    [endButton addTarget:self action:@selector(checkEndButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [endButton setBackgroundImage:endimage forState:UIControlStateNormal];
    [self addSubview:endButton];

}
-(void)showReturnButton
{
    
    UIImage *returnimage = [UIImage imageNamed:@"returnButton.png"];
    returnButton = [[UIButton alloc] initWithFrame:CGRectMake( 10,12,60,60)];
    [returnButton addTarget:self action:@selector(checkReturnButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [returnButton setBackgroundImage:returnimage forState:UIControlStateNormal];
    returnButton.alpha=0.6f;
    [self addSubview:returnButton];
    
}

- (void)checkEndButtonTapped:(id)sender
{
    if (self.endARDelegate && [self.endARDelegate respondsToSelector:@selector(returnToStartView)]) {
        [self.endARDelegate returnToStartView];
    }
    NSLog(@"button return pressed");
}

- (void)checkReturnButtonTapped:(id)sender
{
    if (self.endARDelegate && [self.endARDelegate respondsToSelector:@selector(returnToScanLogoView)]) {
        [self.endARDelegate returnToScanLogoView];
    }
    NSLog(@"button return pressed");
}


// You must implement this method, which ensures the view's underlying layer is
// of type CAEAGLLayer
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame appSession:(ARApplicationSession *) app
{
    self = [super initWithFrame:frame];
    
    if (self) {
        vapp = app;
        // Enable retina mode if available on this device
        if (YES == [vapp isRetinaDisplay]) {
            [self setContentScaleFactor:[UIScreen mainScreen].nativeScale];
        }
        
        // Load the augmentation textures
        for (int i = 0; i < kNumAugmentationTextures; ++i) {
            augmentationTexture[i] = [[Texture alloc] initWithImageFile:[NSString stringWithCString:textureFilenames[i] encoding:NSASCIIStringEncoding]];
        }

        // Create the OpenGL ES context
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        // The EAGLContext must be set for each thread that wishes to use it.
        // Set it the first time this method is called (on the main thread)
        if (context != [EAGLContext currentContext]) {
            [EAGLContext setCurrentContext:context];
        }
        
        // Generate the OpenGL ES texture and upload the texture data for use
        // when rendering the augmentation
        for (int i = 0; i < kNumAugmentationTextures; ++i) {
            GLuint textureID;
            glGenTextures(1, &textureID);
            [augmentationTexture[i] setTextureID:textureID];
            glBindTexture(GL_TEXTURE_2D, textureID);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [augmentationTexture[i] width], [augmentationTexture[i] height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[augmentationTexture[i] pngData]);
        }

        sampleAppRenderer = [[SampleAppRenderer alloc]initWithSampleAppRendererControl:self deviceMode:Vuforia::Device::MODE_AR stereo:false nearPlane:0.01 farPlane:5];
        
        [self initShaders];
        
        // we initialize the rendering method of the SampleAppRenderer
        [sampleAppRenderer initRendering];
    }
    
    [self initLogoMarkerAndArrow];
    [self showScanInstruction];
    
    return self;
}


- (void)initLogoMarkerAndArrow
{

    for(int i=0;i<logoNum;i++){
        for(int j=0;j<markNum;j++){
            arrowIndexes[i][j]=arrowIndex1D[i * markNum +j];

            NSLog(@"arrowIndexes[%i][%i]=%i",i, j,arrowIndexes[i][j]);
        }
    }
    screenRect=[[UIScreen mainScreen] bounds];
    width=screenRect.size.width;
    height=screenRect.size.height;

    logoMode = YES;
    markerMode = NO;
//    hasShownLogoInfo=NO;
    timer=0;

}

//gao

- (CGSize)getCurrentARViewBoundsSize
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGSize viewSize = screenBounds.size;
    
    viewSize.width *= [UIScreen mainScreen].nativeScale;
    viewSize.height *= [UIScreen mainScreen].nativeScale;
    return viewSize;
}


- (void)dealloc
{
    [self deleteFramebuffer];
    
    // Tear down context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }

    for (int i = 0; i < kNumAugmentationTextures; ++i) {
        augmentationTexture[i] = nil;
    }
}


- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  The render loop has
    // been stopped, so we now make sure all OpenGL ES commands complete before
    // we (potentially) go into the background
    if (context) {
        [EAGLContext setCurrentContext:context];
        glFinish();
    }
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Free easily
    // recreated OpenGL ES resources
    [self deleteFramebuffer];
    glFinish();
}



- (void) updateRenderingPrimitives
{
    [sampleAppRenderer updateRenderingPrimitives];
}


//------------------------------------------------------------------------------
#pragma mark - UIGLViewProtocol methods

// Draw the current frame using OpenGL
//
// This method is called by Vuforia when it wishes to render the current frame to
// the screen.
//
// *** Vuforia will call this method periodically on a background thread ***
- (void)renderFrameVuforia
{
    if (! vapp.cameraIsStarted) {
        return;
    }
    
    [sampleAppRenderer renderFrameVuforia];
}

- (void) renderFrameWithState:(const Vuforia::State&) state projectMatrix:(Vuforia::Matrix44F&) projectionMatrix {
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render video background and retrieve tracking state
    [sampleAppRenderer renderVideoBackground];
    
    glEnable(GL_DEPTH_TEST);

    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    if(logoMode){
        Vuforia::setHint(Vuforia::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, 1);//GAO
    }else if(markerMode){
        Vuforia::setHint(Vuforia::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, 5);//GAO
    }
    
//    int trackableNumber=state.getNumTrackableResults();
//    NSLog(@"????????????????????????????num of trackable %i", trackableNumber);

    
    
    for (int i = 0; i < state.getNumTrackableResults(); ++i) {
        // Get the trackable
        const Vuforia::TrackableResult* result = state.getTrackableResult(i);
        const Vuforia::Trackable& trackable = result->getTrackable();

        //const Vuforia::Trackable& trackable = result->getTrackable();
        Vuforia::Matrix44F modelViewMatrix = Vuforia::Tool::convertPose2GLMatrix(result->getPose());
        
        // OpenGL 2
        Vuforia::Matrix44F modelViewProjection;
        
        SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScaleNormal, &modelViewMatrix.data[0]);
        SampleApplicationUtils::scalePoseMatrix(kObjectScaleNormal, kObjectScaleNormal, kObjectScaleNormal, &modelViewMatrix.data[0]);

        SampleApplicationUtils::multiplyMatrix(&projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
        
        glUseProgram(shaderProgramID);
        
        

        
        
        int textureIndex = 0; //

        // Choose the arrow based on the target name
        const char* name = trackable.getName();

        NSString *str= [NSString stringWithCString:name encoding:NSUTF8StringEncoding];

        
        int indexValue=[[str substringWithRange:NSMakeRange(4, 2)] intValue];

        if([str hasPrefix:@"logo"]){
            if(logoMode){
                logoIndex = indexValue;
                if(![self.subviews containsObject:logoLabel]){
                    [self showLogoMessage];
//                    hasShownLogoInfo = YES;
                }else{
                    [self updateLogoName];
                }
//                NSLog(@"this is a logo, logoIndex:%i",logoIndex);
            }else if(logoIndex == indexValue){
                NSLog(@"this is a logo, logoIndex:%i, and i will show arrow",[[str substringWithRange:NSMakeRange(4, 1)] intValue]);

                if(!hasUpdatedInstruction){
                    [self updateInstruction];
                    hasUpdatedInstruction=YES;
                }
                markerIndex =  0;
            }else{
                NSLog(@"this is a logo, logoIndex:%i, and i will do nothing since you have chonsen another logo",indexValue);
                continue;
            }
            
        }else{//detected marker
            if(markerMode){
                if([self.subviews containsObject:mask]){
                    [self removeInstructionAndMask];
//                    hasShownReturnButton=YES;
                }
                
                markerIndex = indexValue;
                NSLog(@"this is a marker,markerIndex %i", markerIndex);
            }else{
                NSLog(@"this is a marker,markerIndex %i, but I will do nothing since I'm in logoMode", indexValue);
                continue;
            }
        }
        
//        NSLog(@"current logoIndex:%i markerindex:%i,arrowIndexes[%i][%i]=%i",logoIndex, markerIndex,logoIndex, markerIndex,arrowIndexes[logoIndex][markerIndex]);


        if(logoMode){
            textureIndex = 2;
            if(logoIndex==1){
                verts = (const GLvoid*)logo1Verts;
                normals=(const GLvoid*)logo1Normals;
                texCoords=(const GLvoid*)logo1TexCoords;
                numVerts = logo1NumVerts;
//                textureIndex = 2;
                
            }else if(logoIndex==2){
                verts = (const GLvoid*)logo2Verts;
                normals=(const GLvoid*)logo2Normals;
                texCoords=(const GLvoid*)logo2TexCoords;
                numVerts = logo2NumVerts;
//                textureIndex = 3;
                
            }else if(logoIndex==3){
                verts = (const GLvoid*)logo3Verts;
                normals=(const GLvoid*)logo3Normals;
                texCoords=(const GLvoid*)logo3TexCoords;
                numVerts = logo3NumVerts;
//                textureIndex = 4;
                
            }else if(logoIndex==4){
                verts = (const GLvoid*)logo4Verts;
                normals=(const GLvoid*)logo4Normals;
                texCoords=(const GLvoid*)logo4TexCoords;
                numVerts = logo4NumVerts;
//                textureIndex = 5;
                
            }else if(logoIndex==5){
                verts = (const GLvoid*)logo5Verts;
                normals=(const GLvoid*)logo5Normals;
                texCoords=(const GLvoid*)logo5TexCoords;
                numVerts = logo5NumVerts;
//                textureIndex = 6;
                
            }else if(logoIndex==6){
                verts = (const GLvoid*)logo6Verts;
                normals=(const GLvoid*)logo6Normals;
                texCoords=(const GLvoid*)logo6TexCoords;
                numVerts = logo6NumVerts;
//                textureIndex = 7;
                
            }else if(logoIndex==7){
                verts = (const GLvoid*)logo7Verts;
                normals=(const GLvoid*)logo7Normals;
                texCoords=(const GLvoid*)logo7TexCoords;
                numVerts = logo7NumVerts;
//                textureIndex = 8;
                
            }else if(logoIndex==0){
                NSLog(@"error:illegal logo index!");
                
            }
        }else if(markerMode){
            textureIndex = 0;
            //left arrow
            if(arrowIndexes[logoIndex][markerIndex]==1){
                verts = (const GLvoid*)arrow1Verts;
                normals=(const GLvoid*)arrow1Normals;
                texCoords=(const GLvoid*)arrow1TexCoords;
                numVerts = arrow1NumVerts;
                //textureIndex = 0;
                
            // right arrow
            }else if(arrowIndexes[logoIndex][markerIndex]==2){
                verts = (const GLvoid*)arrow2Verts;
                normals=(const GLvoid*)arrow2Normals;
                texCoords=(const GLvoid*)arrow2TexCoords;
                numVerts = arrow2NumVerts;
                //textureIndex = 1;
                
            // left-forward arrow
            }else if(arrowIndexes[logoIndex][markerIndex]==3){
                verts = (const GLvoid*)arrow3Verts;
                normals=(const GLvoid*)arrow3Normals;
                texCoords=(const GLvoid*)arrow3TexCoords;
                numVerts = arrow3NumVerts;
                //textureIndex = 1;
                
            // right-forward arrow
            }else if(arrowIndexes[logoIndex][markerIndex]==4){
                verts = (const GLvoid*)arrow4Verts;
                normals=(const GLvoid*)arrow4Normals;
                texCoords=(const GLvoid*)arrow4TexCoords;
                numVerts = arrow4NumVerts;
                //textureIndex = 1;

            }else if(arrowIndexes[logoIndex][markerIndex]== -1){
//                NSLog(@"reached destination!");
                if(![self.subviews containsObject:endButton]){
                    [self reachDestination];
//                    hasShownEndInfo=YES;
                }
                verts = (const GLvoid*)arrow0Verts;
                normals=(const GLvoid*)arrow0Normals;
                texCoords=(const GLvoid*)arrow0TexCoords;
                numVerts = arrow0NumVerts;
                //textureIndex = 1;
                
            }else if(arrowIndexes[logoIndex][markerIndex]==0){
                verts = (const GLvoid*)arrow0Verts;
                normals=(const GLvoid*)arrow0Normals;
                texCoords=(const GLvoid*)arrow0TexCoords;
                numVerts = arrow0NumVerts;
                //textureIndex = 1;
                
            }else {
                NSLog(@"error:illegal arrow index!");
    
                
            }
        }

        glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, verts);
        glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, normals);
        glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
        
        
        glEnableVertexAttribArray(vertexHandle);
        glEnableVertexAttribArray(normalHandle);
        glEnableVertexAttribArray(textureCoordHandle);
        
        
        glActiveTexture(GL_TEXTURE0);
        
        glBindTexture(GL_TEXTURE_2D, augmentationTexture[textureIndex].textureID);
        
        glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (const GLfloat*)&modelViewProjection.data[0]);
        glUniform1i(texSampler2DHandle, 0 /*GL_TEXTURE0*/);
        
        glDrawArrays(GL_TRIANGLES, 0, numVerts);
        
        glDisableVertexAttribArray(vertexHandle);
        glDisableVertexAttribArray(normalHandle);
        glDisableVertexAttribArray(textureCoordHandle);
        
        SampleApplicationUtils::checkGlError("EAGLView renderFrameVuforia");
    }

    
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    [self presentFramebuffer];
}

- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    [sampleAppRenderer configureVideoBackgroundWithViewWidth:viewWidth andHeight:viewHeight];
}

//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management

- (void)initShaders
{
    shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh"
                                                   fragmentShaderFileName:@"Simple.fragsh"];

    if (0 < shaderProgramID) {
        vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
        normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
        textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
        mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
        texSampler2DHandle  = glGetUniformLocation(shaderProgramID,"texSampler2D");
    }
    else {
        NSLog(@"Could not initialise augmentation shader");
    }
}


- (void)createFramebuffer
{
    if (context) {
        // Create default framebuffer object
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        GLint framebufferWidth;
        GLint framebufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    }
}


- (void)deleteFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}


- (void)setFramebuffer
{
    // The EAGLContext must be set for each thread that wishes to use it.  Set
    // it the first time this method is called (on the render thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFramebuffer) {
        // Perform on the main thread to ensure safe memory allocation for the
        // shared buffer.  Block until the operation is complete to prevent
        // simultaneous access to the OpenGL context
        [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}


- (BOOL)presentFramebuffer
{
    // setFramebuffer must have been called before presentFramebuffer, therefore
    // we know the context is valid and has been set for this (render) thread
    
    // Bind the colour render buffer and present it
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}



@end
