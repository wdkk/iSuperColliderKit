// [include guard]
#ifndef __CAIM_MEMORY_C_H__
#define __CAIM_MEMORY_C_H__

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#if defined(__cplusplus)
extern "C" {
#endif
    typedef void* CAIMMemoryCPtr;
    
    CAIMMemoryCPtr CAIMMemoryCNew();
    void CAIMMemoryCDelete(CAIMMemoryCPtr mem);
    
    void* CAIMMemoryCPointer(CAIMMemoryCPtr mem);
    long  CAIMMemoryCCapacity(CAIMMemoryCPtr mem);
    long  CAIMMemoryCLength(CAIMMemoryCPtr mem);
    void  CAIMMemoryCResize(CAIMMemoryCPtr mem, long length);
    void  CAIMMemoryCReserve(CAIMMemoryCPtr mem, long length);
    void  CAIMMemoryCAppend(CAIMMemoryCPtr mem, CAIMMemoryCPtr src);
    void  CAIMMemoryCAppendC(CAIMMemoryCPtr mem, void *bin, long length);
    
#if defined(__cplusplus)
}
#endif


#endif
