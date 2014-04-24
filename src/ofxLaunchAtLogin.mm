//
//  ofxLaunchAtLogin.mm
//
//  Created by ISHII 2bit on 2014/04/24.
//
//

#include "ofxLaunchAtLogin.h"
#include "LaunchAtLoginController.h"

void ofxSetLaunchAtLogin(bool bEnable) {
    [[LaunchAtLoginController sharedController] setLaunchAtLoginEnabled:(BOOL)bEnable];
}

void ofxEnableLaunchAtLogin() { ofxSetLaunchAtLogin(true); }
void ofxDisableLaunchAtLogin() { ofxSetLaunchAtLogin(false); }
