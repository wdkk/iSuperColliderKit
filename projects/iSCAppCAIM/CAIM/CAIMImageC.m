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


#include "CAIMImageC.h"

// [struct] CAIM Image Data Struct
typedef struct CAIMImageC
{
    unsigned char * memory;         // pixel memory first address
    void * _Nonnull matrix;         // 2d(need to cast CAIMColorMatrix series)
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
static void CAIMImageInternalCreateData(CAIMImageCPtr img_, long wid_, long hgt_, CAIMDepth depth_) {
    if( img_ == NULL ) { return; }
    
    img_->width   = (int)wid_;
    img_->height  = (int)hgt_;
    img_->channel = 4;
    img_->depth   = depth_;
    
    int row_bytes = (int)wid_ * img_->channel * (img_->depth / 8);
    int all_size  = (int)row_bytes * (int)hgt_;
    // iOS Metal Shared Memory need 4096 bytes alignment.
    int mod       = all_size % 4096;
    all_size += (mod > 0 ? 4096-mod : 0);
    
    img_->row_bytes	 = row_bytes;
    img_->memory_size = all_size;
    img_->memory      = (unsigned char*)malloc(all_size);
    img_->scale       = [UIScreen mainScreen].scale;
    
    unsigned char *memory = img_->memory;
    img_->matrix = malloc(hgt_ * sizeof(CAIMColor*));
    int step = (int)wid_ * img_->channel * sizeof(float);
    
    CAIMColorMatrix mat = CAIMImageMatrix(img_);
    for (int y = 0; y < hgt_; ++y) {
        mat[y] = (CAIMColor*)(&memory[y * step]);
    }
}

////////////////////////////////////////////////////////////////

// create image
CAIMImageCPtr CAIMImageCreate( long wid_, long hgt_, CAIMDepth depth_ ) {
    if(wid_ < 1 || hgt_ < 1) { return NULL; }
    
    CAIMImageCPtr img_dst = (CAIMImageCPtr)malloc( sizeof(CAIMImage) );
    CAIMImageInternalCreateData( img_dst, wid_, hgt_, depth_ );
    
    return img_dst;
}

// create image by image data file
CAIMImageCPtr CAIMImageCreateWithFile( NSString* _Nonnull file_path_, CAIMDepth depth_ ) {
    CAIMImageCPtr img_dst = CAIMImageCreate( 1, 1, depth_ );
    CAIMImageLoadFile( img_dst, file_path_ );
    return img_dst;
}

// release image data
void CAIMImageRelease( CAIMImageCPtr img_ ) {
    if( img_ == NULL ) { return; }
    
    if( img_->matrix ) { free(img_->matrix); img_->matrix = NULL; }
    if( img_->memory ) { free(img_->memory); img_->memory = NULL; }
    
    free( img_ );
}

// clone image
CAIMImageCPtr CAIMImageClone( const CAIMImageCPtr img_src_ ) {
    if( img_src_ == NULL ) { return NULL; }
    
    long wid = CAIMImageWidth(img_src_);
    long hgt = CAIMImageHeight(img_src_);
    
    CAIMImageCPtr img_dst;
    img_dst = CAIMImageCreate( wid, hgt, img_src_->depth );
    img_dst->scale = CAIMImageRetinaScale(img_src_);
    
    long row_bytes = img_dst->row_bytes;
    long byte_size = hgt * row_bytes;
    memcpy( img_dst->memory, img_src_->memory, byte_size );
    
    return img_dst;
}

// copy image
void CAIMImageCopy( const CAIMImageCPtr img_src_, CAIMImageCPtr img_dst_) {
    long wid       = img_src_->width;
    long hgt       = img_src_->height;
    long row_bytes = img_src_->row_bytes;
    CAIMImageResize( img_dst_, wid, hgt );
    img_dst_->scale = img_src_->scale;
    memcpy(img_dst_->memory, img_src_->memory, row_bytes * hgt );
}

// resize image
void CAIMImageResize( CAIMImageCPtr img_, long wid_, long hgt_ ) {
    if(img_->width == wid_ && img_->height == hgt_) { return; }
    
    if( img_->memory ) { free( img_->memory ); img_->memory = NULL; }
    if( img_->matrix ) { free( img_->matrix ); img_->matrix = NULL; }
    
    CAIMImageInternalCreateData( img_, wid_, hgt_, img_->depth );
}

CAIMCharPtr CAIMImageMemory( CAIMImageCPtr img_ ) { return img_->memory; }

CAIMColorMatrix CAIMImageMatrix( CAIMImageCPtr img_ ) { return (CAIMColorMatrix)img_->matrix; }

CAIMColor8Matrix CAIMImageMatrix8( CAIMImageCPtr img_ ) { return (CAIMColor8Matrix)img_->matrix; }

long CAIMImageWidth( CAIMImageCPtr img_ ) { return img_->width; }

long CAIMImageHeight( CAIMImageCPtr img_ ) { return img_->height; }

CAIMDepth CAIMImageDepth( CAIMImageCPtr img_ ) { return img_->depth; }

CGFloat CAIMImageRetinaScale( CAIMImageCPtr img_ ) { return (CGFloat)img_->scale; }

long CAIMImageMemorySize ( CAIMImageCPtr img_ ) { return img_->memory_size; }

int CAIMImageLoadFile( CAIMImageCPtr img_, NSString* _Nonnull file_path_) {
    UIImage *ui_img = [UIImage imageWithContentsOfFile:file_path_];
    
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
    CAIMImageResize(img_, wid, hgt);
    
    CAIMColorMatrix mat = CAIMImageMatrix(img_);

    for(int y = 0; y < hgt; ++y) {
        for(int x = 0; x < wid; ++x) {
            mat[y][x].R = (float)(buffer[x * 4 + y * row_bytes]) / 255.0;
            mat[y][x].G = (float)(buffer[x * 4 + y * row_bytes + 1]) / 255.0;
            mat[y][x].B = (float)(buffer[x * 4 + y * row_bytes + 2]) / 255.0;
            mat[y][x].A = (float)(buffer[x * 4 + y * row_bytes + 3]) / 255.0;
        }
    }

    
    // release data reference
    CFRelease(data_ref);
    
    return 1;
}

int CAIMImageSaveFileToAlbum( CAIMImageCPtr img_ ) {
    if(img_ == NULL) { return 0; }
 
    // parameter of LLImage
    long wid = CAIMImageWidth(img_);
    long hgt = CAIMImageHeight(img_);
    
    CAIMColor8Ptr buf = NULL;
    register CAIMColor8 c;
    
    CAIMColorMatrix mat = CAIMImageMatrix(img_);
    buf = (CAIMColor8Ptr)malloc(wid * hgt * sizeof(CAIMColor8));
    for(int y = 0; y < hgt; ++y) {
        for(int x = 0; x < wid; ++x) {
            c.R = (unsigned char)(mat[y][x].R * 255.0);
            c.G = (unsigned char)(mat[y][x].G * 255.0);
            c.B = (unsigned char)(mat[y][x].B * 255.0);
            c.A = (unsigned char)(mat[y][x].A * 255.0);
            buf[x + y * wid] = c;
        }
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
    
    free(buf);
    
    return 1;
}

// 高速なmemset
// https://www16.atwiki.jp/projectpn/pages/36.html
void *memsetex(void *dst, void *src, size_t nmemb, size_t size) {
    if(size == 0) { return NULL; }
    if(size == 1) {
        memcpy(dst, src, nmemb);
    }
    else {
        size_t half = size/2;
        memsetex(dst, src, nmemb, half);
        memcpy(dst + half * nmemb, dst, half * nmemb);
        if(size % 2) {
            memcpy(dst + (size - 1) * nmemb, src, nmemb);
        }
    }
    return dst;
}

void CAIMImageFillColor(CAIMImageCPtr img_, CAIMColor c_) {
    long wid       = img_->width;
    long hgt       = img_->height;    
    memsetex(img_->memory, &c_, sizeof(CAIMColor), wid * hgt);
};

void CAIMImagePaste(CAIMImageCPtr img_src, CAIMImageCPtr img_dst, int x, int y) {
    // ベース画像
    long wid = img_dst->width;
    long hgt = img_dst->height;
    CAIMColorMatrix mat = img_dst->matrix;
    // 貼り付ける画像
    long wid_s = img_src->width;
    long hgt_s = img_src->height;
    CAIMColorMatrix mat_s = img_src->matrix;
    
    // はみ出さないループ範囲をつくり、その部分だけ貼り付け
    long min_x = MAX(x, 0);
    long min_y = MAX(y, 0);
    long max_x = MIN(wid_s+x, wid);
    long max_y = MIN(hgt_s+y, hgt);
    // memcpyをx方向一ラインずつつかって若干の高速化
    for(long j = min_y; j < max_y; ++j) {
        memcpy(&(mat[j][min_x]), &(mat_s[j-y][min_x-x]), (max_x-min_x) * 4 * sizeof(float));
    }
}

