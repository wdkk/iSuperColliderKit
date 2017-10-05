//
//  CAIMMemory.cpp
//  ios_caimmetal01
//
//  Created by kengo on 2017/03/08.
//  Copyright © 2017年 TUT Creative Application. All rights reserved.
//

#include "CAIMMemoryC.h"
#include <cstdlib>
#include <iostream>
#include <type_traits>
#include <vector>

template<typename T = void*, typename std::enable_if<std::is_pointer<T>::value, std::nullptr_t>::type = nullptr>
static inline T alignedMalloc(std::size_t size, std::size_t alignment) noexcept {
    void* p;
    return reinterpret_cast<T>(posix_memalign(&p, alignment, size) == 0 ? p : nullptr);
}

static inline void alignedFree(void* ptr) noexcept { std::free(ptr); }

template<typename T, std::size_t N>
class AlignedAllocator : public std::allocator<T>
{
public:
    
    using ConstPtr = typename std::allocator<T>::const_pointer;
    using Ptr = typename std::allocator<T>::pointer;
    using SizeType = typename std::allocator<T>::size_type;
    
    Ptr allocate(SizeType n, ConstPtr = nullptr) const {
        if (n > this->max_size()) { throw std::bad_alloc(); }
        return alignedMalloc<Ptr>(n * sizeof(T), N);
    }
    
    void deallocate(Ptr p, SizeType) const noexcept { alignedFree(p); }
};

static const int ALIGNMENT4096 = 4096;

typedef std::vector<char, AlignedAllocator<char, ALIGNMENT4096>> CAIMMemoryC;

static CAIMMemoryC* _M(CAIMMemoryCPtr mem_) { return (CAIMMemoryC*)mem_; }

CAIMMemoryCPtr CAIMMemoryCNew() {
    CAIMMemoryC* mem = (CAIMMemoryC*)(new CAIMMemoryC());
    mem->reserve(ALIGNMENT4096);
    return mem;
}

void CAIMMemoryCDelete(CAIMMemoryCPtr mem_) {
    delete _M(mem_);
}

void* CAIMMemoryCPointer(CAIMMemoryCPtr mem_) {
    return _M(mem_)->data();
}

long CAIMMemoryCCapacity(CAIMMemoryCPtr mem_) {
    return (long)_M(mem_)->capacity();
}

long CAIMMemoryCLength(CAIMMemoryCPtr mem_) {
    return (long)_M(mem_)->size();
}

void CAIMMemoryCResize(CAIMMemoryCPtr mem_, long length_) {
    long mod = length_ % ALIGNMENT4096;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT4096 - mod);
    CAIMMemoryC *mem = _M(mem_);
    if(length == mem->size()) { return; }
    mem->resize(length);
}

void CAIMMemoryCReserve(CAIMMemoryCPtr mem_, long length_) {
    long mod = length_ % ALIGNMENT4096;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT4096 - mod);
    _M(mem_)->reserve(length);
}

void CAIMMemoryCAppend(CAIMMemoryCPtr mem_, CAIMMemoryCPtr src_) {
    CAIMMemoryC* d = _M(mem_);
    CAIMMemoryC* s = _M(src_);
    std::copy(s->begin(), s->end(), std::back_inserter(*d));
}

void CAIMMemoryCAppendC(CAIMMemoryCPtr mem_, void* bin_, long length_) {
    CAIMMemoryC* m = _M(mem_);
    long sz = m->size();
    m->resize((size_t)(sz + length_));
    char* p = (char*)CAIMMemoryCPointer(mem_);
    
    memcpy(&p[sz], bin_, (size_t)length_);
}
