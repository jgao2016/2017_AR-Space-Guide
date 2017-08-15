/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <UIKit/UIKit.h>

#import <Vuforia/UIGLViewProtocol.h>

#import "Texture.h"
#import "ARApplicationSession.h"
#import "SampleApplication3DModel.h"
#import "SampleGLResourceHandler.h"
#import "SampleAppRenderer.h"

#define kNumAugmentationTextures 3

#import <UIKit/UILabel.h>
//#import "EndARProtocol.h"

@protocol EndARProtocol <NSObject>

-(void)returnToStartView;
-(void)returnToScanLogoView;

@end


// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface ImageTargetsEAGLView : UIView <UIGLViewProtocol, SampleGLResourceHandler, SampleAppRendererControl,EndARProtocol> {
@public
    //gao
    BOOL logoMode;
    BOOL markerMode;
//    BOOL hasShownLogoInfo;
//    BOOL hasShownEndInfo;
//    BOOL hasShownReturnButton;
    BOOL hasUpdatedInstruction;
    int logoIndex;
    int markerIndex;


    //gao

@private
    // OpenGL ES context
    EAGLContext *context;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;

    // Shader handles
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    
    UILabel *textLabel;
    UIImageView *mask;
    UILabel *test;
    UILabel *logoLabel;
    UIButton *yesButton;
    
    UIImageView *endBackground;
    UILabel *endLabel;
    UIButton *endButton;
    UIButton *returnButton;
    
    // Texture used when rendering augmentation
    Texture* augmentationTexture[kNumAugmentationTextures];
    
    SampleAppRenderer * sampleAppRenderer;
    
    }

@property (nonatomic, weak) ARApplicationSession * vapp;
@property(nonatomic,weak) id<EndARProtocol> endARDelegate;//gao


- (id)initWithFrame:(CGRect)frame appSession:(ARApplicationSession *) app;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (void) setOffTargetTrackingMode:(BOOL) enabled;
- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight;
- (void) updateRenderingPrimitives;
@end
