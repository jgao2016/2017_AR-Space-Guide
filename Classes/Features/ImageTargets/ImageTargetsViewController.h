/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <UIKit/UIKit.h>
#import "ImageTargetsEAGLView.h"
#import "ARApplicationSession.h"
//#import "SampleAppMenuViewController.h"
#import <Vuforia/DataSet.h>


#import <UIKit/UILabel.h>//GAO


@interface ImageTargetsViewController : UIViewController <SampleApplicationControl,EndARProtocol> {
    
    Vuforia::DataSet*  dataSetCurrent;
    Vuforia::DataSet*  targetdataSet;

    BOOL continuousAutofocusEnabled;
//    UIButton *returnButton;
}

@property (nonatomic, strong) ImageTargetsEAGLView* eaglView;
@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;
@property (nonatomic, strong) ARApplicationSession * vapp;

@end
