//
//  OTDefaultAudioDevice.h
//  APCallKit
//
//  Created by Chindanai Peerapattanapaiboon on 31/12/2562 BE.
//  Copyright © 2562 Chindanai Peerapattanapaiboon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <OpenTok/OpenTok.h>

#define kMixerInputBusCount 2
#define kOutputBus 0
#define kInputBus 1

#define AUDIO_DEVICE_HEADSET     @"AudioSessionManagerDevice_Headset"
#define AUDIO_DEVICE_BLUETOOTH   @"AudioSessionManagerDevice_Bluetooth"
#define AUDIO_DEVICE_SPEAKER     @"AudioSessionManagerDevice_Speaker"


@interface OTDefaultAudioDevice : NSObject <OTAudioDevice>
{
    AudioStreamBasicDescription stream_format;
}

/**
 Returns YES if a wired headset is available.
 */
@property (nonatomic, readonly) BOOL headsetDeviceAvailable;

/**
 Returns YES if a bluetooth device is available.
 */
@property (nonatomic, readonly) BOOL bluetoothDeviceAvailable;

- (BOOL)setAudioBus:(id<OTAudioBus>)audioBus;

/**
 * Audio device lifecycle should live for the duration of the process, and
 * needs to be set before OTSession is initialized.
 *
 * It is not recommended to initialize unique audio device instances.
 */
+ (instancetype)sharedInstance;
+ (instancetype)sharedInstanceWithAudioSession:(AVAudioSession *)audioSession;

- (OTAudioFormat*)captureFormat;
- (OTAudioFormat*)renderFormat;

- (BOOL)renderingIsAvailable;
- (BOOL)initializeRendering;
- (BOOL)renderingIsInitialized;
- (BOOL)captureIsAvailable;
- (BOOL)initializeCapture;
- (BOOL)captureIsInitialized;

- (BOOL)startRendering;
- (BOOL)stopRendering;
- (BOOL)isRendering;
- (BOOL)startCapture;
- (BOOL)stopCapture;
- (BOOL)isCapturing;

- (uint16_t)estimatedRenderDelay;
- (uint16_t)estimatedCaptureDelay;

//desired Audio Route can be bluetooth and headset.
//bluetooth has higher priority of all, next headset, next speaker
- (BOOL)configureAudioSessionWithDesiredAudioRoute:(NSString*)desiredAudioRoute;
- (BOOL)detectCurrentRoute;

- (BOOL)setPlayOutRenderCallback:(AudioUnit)unit;

@end
