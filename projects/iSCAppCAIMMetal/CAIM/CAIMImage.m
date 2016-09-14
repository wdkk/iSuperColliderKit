//
// CAIMImage.m
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//


#include "CAIMImage.h"

// [struct] CAIM Image Data Struct
typedef struct CAIMImageC
{
    unsigned char  *memory;         // pixel memory first address
    void		   *matrix;         // 2d(need to cast CAIMColorMatrix series)
    long            width;
    long            height;
    CAIMDepth       depth;
    unsigned short  channel;
    long            row_bytes;
    long            memory_size;
    float           scale;          // scaling(retina or non retina)
}
CAIMImage;

// (internal) create image memory
static void CAIMImageInternalCreateData(CAIMImageCPtr img_arg, long wid_arg, long hgt_arg, CAIMDepth depth_arg)
{
    /*
    if( img_arg == NULL ) { return; }
    
    img_arg->width   = (int)wid_arg;
    img_arg->height  = (int)hgt_arg;
    img_arg->depth   = depth_arg;
    img_arg->channel = 4;
    
    int row_bytes = (int)wid_arg * img_arg->channel * (img_arg->depth / 8);
    
    img_arg->row_bytes	= row_bytes;
    img_arg->memory     = (unsigned char*)malloc(row_bytes * hgt_arg);
    img_arg->scale      = [UIScreen mainScreen].scale;
    
    unsigned char *memory = img_arg->memory;
    int channel = img_arg->channel;
    int step = channel * (int)wid_arg;
    
    img_arg->matrix = malloc(hgt_arg * sizeof(CAIMColor*));
    
    CAIMColorMatrix mat = CAIMImageMatrix(img_arg);
    for (int y = 0; y < hgt_arg; ++y)
    {
        mat[y] = (CAIMColor*)(&memory[y * step * 4]);
    }
    */
    
    if( img_arg == NULL ) { return; }
    
    img_arg->width   = (int)wid_arg;
    img_arg->height  = (int)hgt_arg;
    img_arg->channel = 4;
    
    int row_bytes = (int)wid_arg * img_arg->channel * sizeof(float);
    int all_size  = (int)row_bytes * (int)hgt_arg;
    // iOS Metal Shared Memory need 4096 bytes alignment.
    int mod       = all_size % 4096;
    all_size += (mod > 0 ? 4096-mod : 0);
    
    img_arg->row_bytes	 = row_bytes;
    img_arg->memory_size = all_size;
    img_arg->memory      = (unsigned char*)malloc(all_size);
    img_arg->scale       = [UIScreen mainScreen].scale;
    
    unsigned char *memory = img_arg->memory;
    img_arg->matrix = malloc(hgt_arg * sizeof(CAIMColor*));
    int step = (int)wid_arg * img_arg->channel * sizeof(float);
    
    CAIMColorMatrix mat = CAIMImageMatrix(img_arg);
    for (int y = 0; y < hgt_arg; ++y)
    {
        mat[y] = (CAIMColor*)(&memory[y * step]);
    }
}

////////////////////////////////////////////////////////////////

// create image
CAIMImageCPtr CAIMImageCreate( long wid_arg, long hgt_arg, CAIMDepth depth_arg )
{
    if(wid_arg < 1 || hgt_arg < 1) { return NULL; }
    
    CAIMImageCPtr img_dst = (CAIMImageCPtr)malloc( sizeof(CAIMImage) );
    CAIMImageInternalCreateData( img_dst, wid_arg, hgt_arg, depth_arg );
    
    return img_dst;
}

// create image by image data file
CAIMImageCPtr CAIMImageCreateWithFile( NSString *file_path_arg, CAIMDepth depth_arg )
{
    CAIMImageCPtr img_dst = CAIMImageCreate( 1, 1, depth_arg );
    CAIMImageLoadFile( img_dst, file_path_arg );
    return img_dst;
}

// release image data
void CAIMImageRelease( CAIMImageCPtr img_arg )
{
    if( img_arg == NULL ) { return; }
    
    if( img_arg->matrix ) { free(img_arg->matrix); img_arg->matrix = NULL; }
    if( img_arg->memory ) { free(img_arg->memory); img_arg->memory = NULL; }
    
    free( img_arg );
}

// clone image
CAIMImageCPtr CAIMImageClone( const CAIMImageCPtr img_src_arg )
{
    if( img_src_arg == NULL ) { return NULL; }
    
    long wid = CAIMImageWidth(img_src_arg);
    long hgt = CAIMImageHeight(img_src_arg);
    
    CAIMImageCPtr img_dst;
    img_dst = CAIMImageCreate( wid, hgt, img_src_arg->depth );
    img_dst->scale  = CAIMImageRetinaScale(img_src_arg);
    
    long row_bytes = img_dst->row_bytes;
    long byte_size = hgt * row_bytes;
    memcpy( img_dst->memory, img_src_arg->memory, byte_size );
    
    return img_dst;
}

// copy image
void CAIMImageCopy( const CAIMImageCPtr img_src_arg, CAIMImageCPtr img_dst_arg)
{
    long wid       = img_src_arg->width;
    long hgt       = img_src_arg->height;
    long row_bytes = img_src_arg->row_bytes;
    CAIMImageResize( img_dst_arg, wid, hgt );
    img_dst_arg->scale = img_src_arg->scale;
    memcpy(img_dst_arg->memory, img_src_arg->memory, row_bytes * hgt );
}

// resize image
void CAIMImageResize( CAIMImageCPtr img_arg, long wid_arg, long hgt_arg )
{
    if(img_arg->width == wid_arg && img_arg->height == hgt_arg) { return; }
    
    if( img_arg->memory ) { free( img_arg->memory ); img_arg->memory = NULL; }
    if( img_arg->matrix ) { free( img_arg->matrix ); img_arg->matrix = NULL; }
    
    CAIMImageInternalCreateData( img_arg, wid_arg, hgt_arg, img_arg->depth );
}

CAIMMemory CAIMImageMemory( CAIMImageCPtr img_arg ) { return img_arg->memory; }

CAIMColorMatrix CAIMImageMatrix( CAIMImageCPtr img_arg ) { return (CAIMColorMatrix)img_arg->matrix; }

CAIMColor8Matrix CAIMImageMatrix8( CAIMImageCPtr img_arg ) { return (CAIMColor8Matrix)img_arg->matrix; }

long CAIMImageWidth( CAIMImageCPtr img_arg ) { return img_arg->width; }

long CAIMImageHeight( CAIMImageCPtr img_arg ) { return img_arg->height; }

CAIMDepth CAIMImageDepth( CAIMImageCPtr img_arg ) { return img_arg->depth; }

CGFloat CAIMImageRetinaScale( CAIMImageCPtr img_arg ) { return (CGFloat)img_arg->scale; }

long CAIMImageMemorySize ( CAIMImageCPtr img_arg ) { return img_arg->memory_size; }

int CAIMImageLoadFile( CAIMImageCPtr img_arg, NSString *file_path_arg)
{
    UIImage *ui_img = [UIImage imageWithContentsOfFile:file_path_arg];
    if(ui_img == NULL) { return 0; }
    
    // get CGImage into ui_img.
    CGImageRef img_ref = ui_img.CGImage;
    // get Data Provider
    CGDataProviderRef data_prov = CGImageGetDataProvider(img_ref);
    // get Data Reference
    CFDataRef data_ref = CGDataProviderCopyData(data_prov);
    // get pixel buffer
    UInt8* buffer = (UInt8*)CFDataGetBytePtr(data_ref);
    
    int row_bytes = (int)CGImageGetBytesPerRow(img_ref);
    int wid = (int)ui_img.size.width;
    int hgt = (int)ui_img.size.height;
    
    // resize CAIMImage data.
    CAIMImageResize(img_arg, wid, hgt);
    
    if(img_arg->depth == CAIMDepth_float)
    {
        CAIMColorMatrix mat = CAIMImageMatrix(img_arg);
    
        for(int y = 0; y < hgt; ++y)
        {
            for(int x = 0; x < wid; ++x)
            {
                mat[y][x].R = (float)(buffer[x * 4 + y * row_bytes]) / 255.0;
                mat[y][x].G = (float)(buffer[x * 4 + y * row_bytes + 1]) / 255.0;
                mat[y][x].B = (float)(buffer[x * 4 + y * row_bytes + 2]) / 255.0;
                mat[y][x].A = (float)(buffer[x * 4 + y * row_bytes + 3]) / 255.0;
            }
        }
    }
    else if(img_arg->depth == CAIMDepth_bit8)
    {
        CAIMColor8Matrix mat8 = CAIMImageMatrix8(img_arg);
        
        for(int y = 0; y < hgt; ++y)
        {
            for(int x = 0; x < wid; ++x)
            {
                mat8[y][x] = *((CAIMColor8Ptr)&buffer[x * 4 + y * row_bytes]);
            }
        }
    }
    
    // release data reference
    CFRelease(data_ref);
    
    return 1;
}

int CAIMImageSaveFileToAlbum( CAIMImageCPtr img_arg )
{
    if(img_arg == NULL) { return 0; }
 
    // parameter of LLImage
    long wid = CAIMImageWidth(img_arg);
    long hgt = CAIMImageHeight(img_arg);
    
    CAIMColor8Ptr buf = NULL;
    register CAIMColor8 c;
    
    if(img_arg->depth == CAIMDepth_float)
    {
        CAIMColorMatrix mat = CAIMImageMatrix(img_arg);
        buf = (CAIMColor8Ptr)malloc(wid * hgt * sizeof(CAIMColor8));
        for(int y = 0; y < hgt; ++y)
        {
            for(int x = 0; x < wid; ++x)
            {
                c.R = (unsigned char)(mat[y][x].R * 255.0);
                c.G = (unsigned char)(mat[y][x].G * 255.0);
                c.B = (unsigned char)(mat[y][x].B * 255.0);
                c.A = (unsigned char)(mat[y][x].A * 255.0);
                buf[x + y * wid] = c;
            }
        }
    }
    else if(img_arg->depth == CAIMDepth_bit8)
    {
        buf = (CAIMColor8Ptr)CAIMImageMemory(img_arg);
    }
    
    int bits_per_component = 8;
    int bits_per_pixel = 32;
    long bytes_per_row = 4 * wid;
    long bytes_size = bytes_per_row * hgt;
    CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
    // create CGDataProvider
    CFDataRef dst = CFDataCreate(NULL, (void*)buf, bytes_size);
    CGDataProviderRef data_prov = CGDataProviderCreateWithCFData(dst);
    // create CGImage
    CGImageRef cg_image = CGImageCreate(
                                        wid,
                                        hgt,
                                        bits_per_component,
                                        bits_per_pixel,
                                        bytes_per_row,
                                        color_space,
                                        kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast,
                                        data_prov,
                                        nil,
                                        true,
                                        kCGRenderingIntentDefault);
    
    UIImage *ui_img = [UIImage imageWithCGImage:cg_image];
    UIImageWriteToSavedPhotosAlbum(ui_img, NULL, NULL, NULL);

    // release data reference
    CGImageRelease(cg_image);
    CFRelease(color_space);
    CFRelease(data_prov);
    CFRelease(dst);
    
    if(img_arg->depth != CAIMDepth_bit8) { free(buf); }
    
    return 1;
}

