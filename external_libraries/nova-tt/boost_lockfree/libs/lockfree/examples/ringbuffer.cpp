//  Copyright (C) 2009 Tim Blechmann
//
//  Distributed under the Boost Software License, Version 1.0. (See
//  accompanying file LICENSE_1_0.txt or copy at
//  http://www.boost.org/LICENSE_1_0.txt)

//[ringbuffer_example
#include <boost/thread/thread.hpp>
#include <boost/atomic.hpp>
#include <boost/lockfree/ringbuffer.hpp>
#include <iostream>

int producer_count = 0;
boost::atomic_int consumer_count (0);

boost::lockfree::ringbuffer<int, 1024> ringbuffer;

const int iterations = 10000000;

void producer(void)
{
    for (int i = 0; i != iterations; ++i) {
        int value = ++producer_count;
        while (!ringbuffer.enqueue(value))
            ;
    }
}

boost::atomic<bool> done (false);

void consumer(void)
{
    int value;
    while (!done) {
        while (ringbuffer.dequeue(value))
            ++consumer_count;
    }

    while (ringbuffer.dequeue(value))
        ++consumer_count;
}

int main(int argc, char* argv[])
{
    using namespace std;
    cout << "boost::lockfree::fifo is ";
    if (!ringbuffer.is_lock_free())
        cout << "not ";
    cout << "lockfree" << endl;

    boost::thread producer_thread(producer);
    boost::thread consumer_thread(consumer);


    producer_thread.join();
    done = true;
    consumer_thread.join();

    cout << "produced " << producer_count << " objects." << endl;
    cout << "consumed " << consumer_count << " objects." << endl;
}
//]
