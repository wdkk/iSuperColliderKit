//
// CAIMImage.h
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

// [include guard]
#ifndef __CAIM_IMAGE_H__
#define __CAIM_IMAGE_H__

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// CAIMImage struct
struct CAIMImageC;
typedef struct CAIMImageC* CAIMImageCPtr;

typedef struct CAIMColor
{
    float R, G, B, A;
}
CAIMColor, **CAIMColorMatrix;

typedef struct CAIMColor8
{
    unsigned char R, G, B, A;
}
CAIMColor8, *CAIMColor8Ptr, **CAIMColor8Matrix;

typedef NS_ENUM(unsigned char, CAIMDepth)
{
    CAIMDepth_bit8 = 8,
    CAIMDepth_float= 32
};

typedef unsigned char* CAIMMemory;

//// shared method ////

// create & release functions.
CAIMImageCPtr     CAIMImageCreate(long wid, long hgt, CAIMDepth depth);
CAIMImageCPtr     CAIMImageCreateWithFile(NSString *file_path, CAIMDepth depth);
void              CAIMImageRelease(CAIMImageCPtr img);
CAIMImageCPtr     CAIMImageClone(const CAIMImageCPtr img_src);
void              CAIMImageCopy(const CAIMImageCPtr img_src, CAIMImageCPtr img_dst);
// resize memory space into CAIMImage.
void              CAIMImageResize(CAIMImageCPtr img, long wid, long hgt);

// load & save file functions.
int               CAIMImageLoadFile(CAIMImageCPtr img, NSString *file_path);
// load & save image file to Album.
int               CAIMImageSaveFileToAlbum(CAIMImageCPtr img);
// get matrix
CAIMMemory        CAIMImageMemory(CAIMImageCPtr img);
CAIMColorMatrix   CAIMImageMatrix(CAIMImageCPtr img);
CAIMColor8Matrix  CAIMImageMatrix8(CAIMImageCPtr img);
// get width/height
long              CAIMImageWidth(CAIMImageCPtr img);
long              CAIMImageHeight(CAIMImageCPtr img);
CAIMDepth         CAIMImageDepth(CAIMImageCPtr img);
long              CAIMImageMemorySize(CAIMImageCPtr img);
CGFloat           CAIMImageRetinaScale(CAIMImageCPtr img);

#endif
