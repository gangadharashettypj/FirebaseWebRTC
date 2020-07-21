#import "FirebaseWebrtcPlugin.h"
#if __has_include(<firebase_webrtc/firebase_webrtc-Swift.h>)
#import <firebase_webrtc/firebase_webrtc-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "firebase_webrtc-Swift.h"
#endif

@implementation FirebaseWebrtcPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFirebaseWebrtcPlugin registerWithRegistrar:registrar];
}
@end
