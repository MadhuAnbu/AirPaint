//
//  Configurations.h
//  AirPaint2
//
//  Created by Philipp Sessler on 17.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef AirPaint2_Configurations_h
#define AirPaint2_Configurations_h

#define REVEAL_ANIMATION_SPEED 0.4f
#define SIDEBAR_WIDTH 80
#define SIDEBAR_PULL_WIDTH 30
#define CONTAINER_SHADOW_WIDTH 10.0
#define SETTINGS_POPUP_WIDTH 200
#define SETTINGS_POPUP_HEIGHT 150


// ---------------- NETWORK -----------------

// ------------------------------------------------

#define NETWORK_DEVICE_PORT_LISTENING 5551

#define NETWORK_SHOE_LISTENING_PORT 5552
//#define NETWORK_SHOE_IP @"192.168.178.37"
#define NETWORK_SHOE_IP @"192.168.178.28"

//#define NETWORK_SHOE_IP @"138.246.41.83"

#define NETWORK_REMOTECONTROL_LISTENING_PORT 5553
#define NETWORK_REMOTECONTROL_IP @"localhost"

// ------------ GESTURE UI SETTINGS ---------------
// ------------------------------------------------

#define SLIDER_STEP_WIDTH_PREFERED 40
#define SLIDER_START_POINT 220
#define SLIDER_END_POINT 30
#define SLIDER_STEP_WIDTH_MIN 1
// new
#define SLIDER_MAX_VALUE 200

#define TRANSFORMATION_SCALE_MAX 3.0
#define TRANSFORMATION_SCALE_MIN -0.5

#define BRUSH_SIZE_MIN 6.0
#define BRUSH_SIZE_MAX 40.0
#define BRUSH_SIZE_INITIAL 8.0



#define NUMBER_OF_CHOICES_COLOR_INITIAL 13  // max 13
#define NUMBER_OF_CHOICES_VARIOUSSTUFF_INITIAL 15 

#endif
