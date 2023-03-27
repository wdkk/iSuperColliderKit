//
//  SCEX_CoreAudio.h
//  libscsynth
//
//  Created by Kengo Watanabe on 2023/03/26.
//

#ifndef SCEX_CoreAudio_h
#define SCEX_CoreAudio_h

#include <stdio.h>

typedef void(*SCEXCoreAudioRenderCallback)( float*, int, long long );

void SCEX_CoreAudioAccessorSetCallback( SCEXCoreAudioRenderCallback f );
void SCEX_CoreAudioAccessorCallCallback( float*, int, long long );

#endif 
