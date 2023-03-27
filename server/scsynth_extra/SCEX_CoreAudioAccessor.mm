//
//  SCEX_CoreAudioAccessor.m
//  libscsynth
//
//  Created by Kengo Watanabe on 2023/03/28.
//

#import <Foundation/Foundation.h>
#include "SCEX_CoreAudioAccessor.h"

static SCEXCoreAudioRenderCallback _internal_render_callback = nullptr;

void SCEX_CoreAudioAccessorSetCallback( SCEXCoreAudioRenderCallback f ) {
    _internal_render_callback = f;
}

void SCEX_CoreAudioAccessorCallCallback( float* waves, int count, long long time ) {
    if( _internal_render_callback == nullptr ) { return; }
    _internal_render_callback( waves, count, time );
}
