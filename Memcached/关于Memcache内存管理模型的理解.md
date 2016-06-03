#关于Memcache内存管理模型的理解

## 说在前面

本文不包含为什么使用memcache，以及如何使用memcache等基础知识。相关知识请查阅各类手册。 另，为便于理解，最好手头准备一份memcache的源码，本文使用的是目前最新的1.4.4版本源码，可自行到github上clone。

## Item、Chunk、Page、Slab

### Data Item

```
+---------------------------------------+
|  key-value | cas | suffix | item head |  
+---------------------------------------+
```

Item指实际存放到memcache中的数据对象结构，除key-value数据外，还包括memcache自身对数据对象的描述信息（Item=key+value+后缀长+32byte结构体）

### Chunk

Chunk指Memcache用来存放Data Item的最小单元，同一个Slab中的chunk大小是固定的。

```
+------------------------------+
|   data item    | empty space |
+------------------------------+
```

### Page

```
+-------------------------------------+
|  chunk1 | chunk2 | chunk3 | chunk4  |
+-------------------------------------+
```

每个Slab中按照Page来申请内存，Page的大小默认为1M，可以通过-l参数调整，最小1k，最大128m.

### Slab

```
+--------------------------------+
|  Page1 | Page2 | Page3 | Page4 |
+--------------------------------+
```

Memcache将分配给它的内存（-m 参数指定，默认64m）按照Chunk大小不同，划分为多个slab。

他们三者的关系如下图所示:

```
                 Chunk
                   ^                                                         
+------------------|------------------------------------------------------------+
|   Memory         |                                                            | 
|  +---------------|---------------------------------------------------------+  |
|  |      +--------|---------------------+  +------------------------------+ |  |
|  |      |Page1 +-|---+ +-----+ +-----+ |  |Page2 +-----+ +-----+ +-----+ | |  |
|  | Slab |(1M)  | 96B | | 68B | | 72B | |  |(1M)  | 92B | | 76B | | 84B | | |  | 
|  |  1   |      +-----+ +-----+ +-----+ |  |      +-----+ +-----+ +-----+ | |  |
|  |      +------------------------------+  +------------------------------+ |  |
|  +-------------------------------------------------------------------------+  |
|                                                                               |
|  +-------------------------------------------------------------------------+  |
|  |      +------------------------------+  +------------------------------+ |  |
|  |      |Page1 +------+    +------+    |  |Page2 +------+    +-------+   | |  |
|  | Slab | (1M) | 128B |    | 120B |    |  |(1M)  | 128B |    | 97B   |   | |  |
|  |   2  |      +------+    +------+    |  |      +------+    +-------+   | |  |
|  |      +------------------------------+  +------------------------------+ |  |
|  +-------------------------------------------------------------------------+  |
+-------------------------------------------------------------------------------+
```

## Slab内存分配

### slab初始化

Memcache启动时会进行slab初始化（参见slabs.c中slabs_init()函数），默认最小的chunksize为80（查看源码会发现settings中chunk_size默认为48，但是实际还需要加上一个32bytes的item结构体），可以通过-n参数调整，按照然后按照factor（默认为1.25，可以通过-f参数调整）(_关于参数更多的memcache默认参数可以参考memcache.c中settings的设置_)比例递增，划分出多个不同chunk大小的slab空间，即slab1的chunk大小=80，slab2的chunk大小为80*1.25=100，slab3的chunk大小为80*1.25*1.25=125，但最大一个一个chunk不会大于一个Page的大小（默认1M）。

一下代码节选自 slabs.c

```c
void slabs_init(const size_t limit, const double factor, const bool prealloc) {
    int i = POWER_SMALLEST - 1;
    unsigned int size = sizeof(item) + settings.chunk_size;
 
    mem_limit = limit;
 
    if (prealloc) {
        /* Allocate everything in a big chunk with malloc */
        mem_base = malloc(mem_limit);
        if (mem_base != NULL) {
            mem_current = mem_base;
            mem_avail = mem_limit;
        } else {
            fprintf(stderr, "Warning: Failed to allocate requested memory in"
                    " one large chunk.\nWill allocate in smaller chunks\n");
        }
    }
 
    memset(slabclass, 0, sizeof(slabclass));
 
    while (++i < POWER_LARGEST && size <= settings.item_size_max / factor) {
        /* Make sure items are always n-byte aligned */
        if (size % CHUNK_ALIGN_BYTES)
            size += CHUNK_ALIGN_BYTES - (size % CHUNK_ALIGN_BYTES);
 
        slabclass[i].size = size;
        slabclass[i].perslab = settings.item_size_max / slabclass[i].size;
        size *= factor;
        if (settings.verbose > 1) {
            fprintf(stderr, "slab class %3d: chunk size %9u perslab %7u\n",
                    i, slabclass[i].size, slabclass[i].perslab);
        }
    }
 
    power_largest = i;
    slabclass[power_largest].size = settings.item_size_max;
    slabclass[power_largest].perslab = 1;
    if (settings.verbose > 1) {
        fprintf(stderr, "slab class %3d: chunk size %9u perslab %7u\n",
                i, slabclass[i].size, slabclass[i].perslab);
    }
 
    /* for the test suite:  faking of how much we've already malloc'd */
    {
        char *t_initial_malloc = getenv("T_MEMD_INITIAL_MALLOC");
        if (t_initial_malloc) {
            mem_malloced = (size_t)atol(t_initial_malloc);
        }
 
    }
 
    if (prealloc) {
        slabs_preallocate(power_largest);
    }
} 
```
                            
PS：prealloc指的是直接申请一个大的chunk存放所有数据，默认是不采用这种方式的。

### 数据存储过程

一个数据项的大致存储量过程可以理解为（完整代码较长，不在粘贴，具体可参见items.c中do_item_alloc()方法）：

1. 构造一个数据项结构体，计算数据项的大小，（假设默认配置下，数据项大小为102B） 

2. 根据数据项的大小，找到最合适的slab，（100<102<125，所以存储在slab3中）

3. 检查该slab中是否有过期的数据，如有清理掉

4. 如果没有过期的数据项，则从当前slab中申请空间，参见slabs.c中slab_alloc()方法。

5. 如果当前slab中申请失败，则尝试根据LRU算法逐出一个数据项，默认memcache是允许逐出的，如果被设置为禁止逐出，那么这是会反生悲剧的oom了

6. 获取到item空间后将数据存储到改空间中，并追加到该slab的item列表中

一个slab的申请一个chunk空间的过程大致如下（以下代码节选自slabs.c）：

```c
static int do_slabs_newslab(const unsigned int id) { 
    slabclass_t *p = &slabclass[id];
    int len = settings.slab_reassign ? settings.item_size_max
        : p->size * p->perslab;
    char *ptr;             
           
    if ((mem_limit && mem_malloced + len > mem_limit && p->slabs > 0) ||
        (grow_slab_list(id) == 0) ||    
        ((ptr = memory_allocate((size_t)len)) == 0)) {
           
        MEMCACHED_SLABS_SLABCLASS_ALLOCATE_FAILED(id);
        return 0;          
    }      
           
    memset(ptr, 0, (size_t)len);    
    split_slab_page_into_freelist(ptr, id);
           
    p->slab_list[p->slabs++] = ptr; 
    mem_malloced += len;   
    MEMCACHED_SLABS_SLABCLASS_ALLOCATE(id);
           
    return 1;              
}
 
/*@null@*/ 
static void *do_slabs_alloc(const size_t size, unsigned int id) {
    slabclass_t *p;        
    void *ret = NULL;      
    item *it = NULL;       
 
    if (id < POWER_SMALLEST || id > power_largest) {
        MEMCACHED_SLABS_ALLOCATE_FAILED(size, 0);
        return NULL;
    }
 
    p = &slabclass[id];
    assert(p->sl_curr == 0 || ((item *)p->slots)->slabs_clsid == 0);
 
    /* fail unless we have space at the end of a recently allocated page,
       we have something on our freelist, or we could allocate a new page */
    if (! (p->sl_curr != 0 || do_slabs_newslab(id) != 0)) {
        /* We don't have more memory available */
        ret = NULL;
    } else if (p->sl_curr != 0) {
        /* return off our freelist */
        it = (item *)p->slots;
        p->slots = it->next;
        if (it->next) it->next->prev = 0;
        p->sl_curr--;
        ret = (void *)it;
    }
 
    if (ret) {
        p->requested += size;
        MEMCACHED_SLABS_ALLOCATE(size, id, p->size, ret);
    } else {
        MEMCACHED_SLABS_ALLOCATE_FAILED(size, id);
    }
 
    return ret;
}
```

slab优先从slots（空闲chunk空间列表）中申请空间，如果没有则尝试申请一个Page的新空间（do_slab_newslab()），申请新slab是会先判断是否进行slab_reasgin（重新分配slab空间，默认不开启）。

### 内存浪费

根据上述描述，Memcache使用Slab预分配的方式进行内存管理提升了性能（减少分配内存的消耗），但是带来了内存浪费，主要体现在：

1. Data Item Size <= Chunk Size，Chunk是存储数据项的最小单元，数据项的大小必须不大于其所在的Chunk大小。也就是说76B的数据对象存入96B的Chunk中，将带来96B-76B=20B的空间浪费。

2. Memcache是按照Page申请和使用内存的，当Page大小不是Chunk的整数倍时，余下的空间将被浪费。即如果PageSize=1M，ChunkSize=1000B,那么将有1024*1024%1000=576B的空间浪费。

3. Memcache默认是不开启slab reasign的，也就是说分配已经分配给一个slab的内存空间，即使该slab不用，默认也不会分配给其他slab的

## 案例分析：定长问题导致逐出

memcache的chunk分布是均匀的，这是为了通用性考虑，但是现实中一些场景chunk的分布是不均运的，例如为了减小对数据库的压力，对数据进行了全量缓存，为标识数据库中不存在的记录，向缓存中放置了一个stupidObject。这个对象大小是固定的，且该数据的量很大，导致该数据类型所在的slab占用了大量缓存空间。再一次调整对象结构时，修改了这个StupidObject大小，使其分布在另一个slab中，但是这个原分配的slab空间不会回收，空闲空间不足，导致大量逐出。

## 引用

- [0] [原文](http://jiangbo.me/blog/2012/08/31/something-about-memcache-internal/)