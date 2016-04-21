# Python标准库之time

## 变量

* time.timezone: 整型，UTC和本地标准时间之间相差的秒数
* time.altzone: 整型，UTC和本地DST(Daylight Savings Time)之间相差的秒数
* time.daylight: 整型，本地时间是否反映DST
* time.tzname: 元组，(标准时区名, DST时区名)

```
print time.timezone, time.altzone, time.daylight, time.tzname
```

```
-28800 -32400 0 ('\xd6\xd0\xb9\xfa\xb1\xea\xd7\xbc\xca\xb1\xbc\xe4', '\xd6\xd0\xb9\xfa\xcf\xc4\xc1\xee\xca\xb1')
```

## 数据结构

时间的表示形式有两种：

1. 时间戳，浮点数(float)，在Unix中从1970年1月1日0时0分0秒开始计算，以秒为单位的偏移量
2. struct_time，包含9个时间属性的数据结构
    * tm_year: 年，如1993
    * tm_mon: 月，范围 [1, 12]
    * tm_mday: 月份中的日期，范围 [1, 31]
    * tm_yday: 年中的第几天，范围 [1, 366]
    * tm_wday: 星期中的第几天，范围 [0, 6]，周一为0
    * tm_hour: 小时，范围 [0, 23]
    * tm_min: 分钟，范围 [0, 59]
    * tm_sec: 秒，范围 [0, 61]
    * tm_isdst: 是否DST，1表示DST，0表示不是DST，-1为unknown

```
>>> print time.time()
1461217697.82
```

```
>>> print time.localtime()
time.struct_time(tm_year=2016, tm_mon=4, tm_mday=21, tm_hour=13, tm_min=48, tm_sec=46, tm_wday=3, tm_yday=112, tm_isdst=0)
```

## 方法

### time.asctime([tuple]) -> string

将时间元组转成字符串，如：Sat Jun 06 16:26:11 1998

如果忽略参数，则默认使用time.localtime()返回的当前时间

```
>>> print time.asctime()
Thu Apr 21 14:03:09 2016

>>> print time.asctime(time.localtime())
Thu Apr 21 14:03:21 2016

>>> print time.asctime(time.gmtime())
Thu Apr 21 06:03:29 2016
```

### time.clock() -> float

返回进程启动后，第一次调用clock()到现在所经历的CPU时间

```
>>> import time
>>> print time.clock()
3.28417066685e-06

>>> print time.clock()
3.93542417322

>>> print time.clock()
5.92227394335
```

### time.ctime(seconds) -> string

将时间戳转成字符串

```
>>> print time.ctime()
Thu Apr 21 14:07:02 2016

>>> print time.ctime(time.time())
Thu Apr 21 14:07:09 2016

>>> print time.ctime(123)
Thu Jan 01 08:02:03 1970
```

### time.gmtime([seconds]) -> struct_time

时间戳转UTC时间元组

```
>>> print time.gmtime()
time.struct_time(tm_year=2016, tm_mon=4, tm_mday=21, tm_hour=6, tm_min=8, tm_sec=47, tm_wday=3, tm_yday=112, tm_isdst=0)

>>> print time.gmtime(time.time())
time.struct_time(tm_year=2016, tm_mon=4, tm_mday=21, tm_hour=6, tm_min=8, tm_sec=56, tm_wday=3, tm_yday=112, tm_isdst=0)

>>> print time.gmtime(123)
time.struct_time(tm_year=1970, tm_mon=1, tm_mday=1, tm_hour=0, tm_min=2, tm_sec=3, tm_wday=3, tm_yday=1, tm_isdst=0)
```

### time.localtime([seconds]) -> struct_time

时间戳转本地时间元组

```
>>> print time.localtime()
time.struct_time(tm_year=2016, tm_mon=4, tm_mday=21, tm_hour=14, tm_min=11, tm_sec=36, tm_wday=3, tm_yday=112, tm_isdst=0)

>>> print time.localtime(time.time())
time.struct_time(tm_year=2016, tm_mon=4, tm_mday=21, tm_hour=14, tm_min=11, tm_sec=42, tm_wday=3, tm_yday=112, tm_isdst=0)

>>> print time.localtime(123)
time.struct_time(tm_year=1970, tm_mon=1, tm_mday=1, tm_hour=8, tm_min=2, tm_sec=3, tm_wday=3, tm_yday=1, tm_isdst=0)
```

### time.mktime(tuple) -> float

时间元组转时间戳

```
>>> print time.mktime(time.localtime())
1461219297.0

>>> print time.mktime(time.gmtime())
1461190504.0
```

### time.sleep(seconds)

延迟指定的时间间隔(单位：秒)之后执行

### time.strftime(format[, tuple]) -> string

将时间元组按指定格式转成字符串

```
>>> print time.strftime('%Y-%m-%d %H:%M:%S')
2016-04-21 14:21:06

>>> print time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
2016-04-21 14:21:34

>>> print time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime())
2016-04-21 06:21:47
```

### time.strptime(string, format) -> struct_time

将字符串转成时间元组

```
>>> print time.strptime('2016-04-21 06:21:47', '%Y-%m-%d %H:%M:%S')
time.struct_time(tm_year=2016, tm_mon=4, tm_mday=21, tm_hour=6, tm_min=21, tm_sec=47, tm_wday=3, tm_yday=112, tm_isdst=-1)
```

### time.time() -> float

返回当前时间的时间戳

```
>>> print time.time()
1461219974.48
```

## 时间格式化

* %y: 年份（2位数），范围 [0, 99]
* %Y: 年份（4位数），范围 [0, 9999]
* %m: 月，范围 [1, 12]
* %d: 日，范围 [0, 31]
* %H: 小时（24小时制），范围 [0, 23]
* %I: 小时（12小时制），范围 [1, 12]
* %M: 分钟，范围 [0, 59]
* %S: 秒，范围 [0, 59]
* %a: 本地简化的星期名称
* %A: 本地完整的星期名称
* %b: 本地简化的月份名称
* %B: 本地完整的月份名称
* %c: 本地相应的日期和时间表示
* %j: 年中的第几天，范围 [1, 366]
* %p: 本地AM或PM的等价符
* %U: 年中的第几星期，范围 [0, 53]，星期日为每周的第一天
* %w: 星期几，范围 [0, 6]，星期日为0
* %W: 年中的第几星期，范围 [0, 53]，星期一为每周的第一天
* %x: 本地相应的日期表示
* %X: 本地相应的时间表示
* %Z: 当前的时区名称
* %%: %号本身

## 案例

###获取当前时间

```
>>> print time.time()
1461221134.17

>>> print time.localtime()
time.struct_time(tm_year=2016, tm_mon=4, tm_mday=21, tm_hour=14, tm_min=56, tm_sec=12, tm_wday=3, tm_yday=112, tm_isdst=0)

>>> print time.ctime()
Thu Apr 21 14:56:48 2016

>>> print time.strftime('%Y-%m-%d %H:%M:%S')
2016-04-21 14:57:39
```

###将时间戳按指定的格式显示

```
>>> print time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(1461221134.17))
2016-04-21 14:45:34

>>> print time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(1461221134.17))
2016-04-21 06:45:34
```

###将字符串转成时间戳

```
>>> print time.mktime(time.strptime('2016-04-21 14:45:34', '%Y-%m-%d %H:%M:%S'))
1461221134.0
```

## 参考资料

* [1] [python time模块详解](http://blog.csdn.net/kiki113/article/details/4033017)