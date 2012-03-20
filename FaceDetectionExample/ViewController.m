//
//  ViewController.m
//  FaceDetectionExample
//
//  Created by Guillermo Ignacio Enriquez on 2012/03/21.
//  Copyright (c) 2011 nacho4d. All rights reserved.
//

#import "ViewController.h"

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ViewController
@synthesize imageView;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Load an image for face detection
	imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facedetectionpic.jpg"]];

	// Add the view so its visible
	[self.view addSubview:imageView];

	// Do face detection
	[self performSelector:@selector(detectFaces) withObject:nil afterDelay:0.0];
}

// Below rates defines the size of the eyes and mouth circles in relationship with the whole face size
#define EYE_SIZE_RATE 0.3f
#define MOUTH_SIZE_RATE 0.4f

- (void)detectFaces
{
	// draw a CI image with the previously loaded face detection picture
	CIImage* image = [CIImage imageWithCGImage:imageView.image.CGImage];

	// create a face detector - since speed is not an issue now we'll use a high accuracy detector
	CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace 
											  context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];

	// create an array containing all the detected faces from the detector
	NSArray* features = [detector featuresInImage:image];

	
	// CoreImage coordinate system origin is at the bottom left corner and UIKit is at the top left corner
	// So we need to translate features positions before drawing them to screen
	// In order to do so we make an affine transform
	// **Note**
	// Its better to convert CoreImage coordinates to UIKit coordinates and
	// not the other way around because doing so could affect other drawings
	// i.e. In the original sample project you see the image and the bottom, Isn't weird?
	CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
	transform = CGAffineTransformTranslate(transform, 0, -imageView.bounds.size.height);
	
	// we'll iterate through every detected face.  CIFaceFeature provides us
	// with the width for the entire face, and the coordinates of each eye
	// and the mouth if detected.  Also provided are BOOL's for the eye's and
	// mouth so we can check if they already exist.
	for(CIFaceFeature* faceFeature in features)
	{
		// Get the face rect: Translate CoreImage coordinates to UIKit coordinates
		const CGRect faceRect = CGRectApplyAffineTransform(faceFeature.bounds, transform);

		// create a UIView using the bounds of the face
		UIView* faceView = [[UIView alloc] initWithFrame:faceRect];
		faceView.layer.borderWidth = 1;
		faceView.layer.borderColor = [[UIColor redColor] CGColor];

		// get the width of the face
		CGFloat faceWidth = faceFeature.bounds.size.width;
		
		// add the new view to create a box around the face
		[imageView addSubview:faceView];

		if(faceFeature.hasLeftEyePosition)
		{
			// Get the left eye position: Translate CoreImage coordinates to UIKit coordinates
			const CGPoint leftEyePos = CGPointApplyAffineTransform(faceFeature.leftEyePosition, transform);

			// Note1:
			// If you want to add this to the the faceView instead of the imageView we need to translate its
			// coordinates a bit more {-x, -y} in other words: {-faceFeature.bounds.origin.x, -faceFeature.bounds.origin.y}
			// You could do the same for the other eye and the mouth too.
			
			// Create an UIView to represent the left eye, its size depend on the width of the face.
			UIView* leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(leftEyePos.x - faceWidth*EYE_SIZE_RATE*0.5f /*- faceFeature.bounds.origin.x*/, // See Note1
																		   leftEyePos.y - faceWidth*EYE_SIZE_RATE*0.5f /*- faceFeature.bounds.origin.y*/, // See Note1
																		   faceWidth*EYE_SIZE_RATE,
																		   faceWidth*EYE_SIZE_RATE)];
			// make the left eye look nice and add it to the view
			leftEyeView.backgroundColor = [[UIColor magentaColor] colorWithAlphaComponent:0.3];
			leftEyeView.layer.cornerRadius = faceWidth*EYE_SIZE_RATE*0.5;
			//[faceView addSubview:leftEyeView];  // See Note1
			[imageView addSubview:leftEyeView];
		}
		
		if(faceFeature.hasRightEyePosition)
		{
			// Get the right eye position translated to imageView UIKit coordinates
			const CGPoint rightEyePos = CGPointApplyAffineTransform(faceFeature.rightEyePosition, transform);

			// Create an UIView to represent the right eye, its size depend on the width of the face.
			UIView* rightEye = [[UIView alloc] initWithFrame:CGRectMake(rightEyePos.x - faceWidth*EYE_SIZE_RATE*0.5,
																		rightEyePos.y - faceWidth*EYE_SIZE_RATE*0.5,
																		faceWidth*EYE_SIZE_RATE,
																		faceWidth*EYE_SIZE_RATE)];
			// make the right eye look nice and add it to the view
			rightEye.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
			rightEye.layer.cornerRadius = faceWidth*EYE_SIZE_RATE*0.5;
			[imageView addSubview:rightEye];
		}
		
		if(faceFeature.hasMouthPosition)
		{
			// Get the mouth position translated to imageView UIKit coordinates
			const CGPoint mouthPos = CGPointApplyAffineTransform(faceFeature.mouthPosition, transform);
			
			// Create an UIView to represent the mouth, its size depend on the width of the face.
			UIView* mouth = [[UIView alloc] initWithFrame:CGRectMake(mouthPos.x - faceWidth*MOUTH_SIZE_RATE*0.5,
																	 mouthPos.y - faceWidth*MOUTH_SIZE_RATE*0.5,
																	 faceWidth*MOUTH_SIZE_RATE,
																	 faceWidth*MOUTH_SIZE_RATE)];

			// make the mouth look nice and add it to the view
			mouth.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
			mouth.layer.cornerRadius = faceWidth*MOUTH_SIZE_RATE*0.5;
			[imageView addSubview:mouth];
		}
	}
}

@end
