#Ubuntu 15.10中sublime text 3支持中文输入的设置

##环境背景

* 系统版本：Ubuntu 15.10 64-bit
* 软件版本：Sublime Text 3（安装目录：/opt/sublime_text）
* 环境：已安装fcitx

##安装依赖软件

```sh
sudo apt-get install build-essential libgtk2.0-dev
```

##添加并编译修正程序

添加并编辑代码文件：～/projects/sublime/imfix/sublime_imfix.c

```sh
mkdir -p ~/projects/sublime/imfix
cd ~/projects/sublime/imfix
vi sublime_imfix.c
```

添加以下内容：

```c
/*
 * sublime-imfix.c
 * Use LD_PRELOAD to interpose some function to fix sublime input method support for linux.
 * By Cjacker Huang <jianzhong.huang at i-soft.com.cn> *
 *
 * gcc -shared -o libsublime-imfix.so sublime_imfix.c  `pkg-config --libs --cflags gtk+-2.0` -fPIC
 * LD_PRELOAD=./libsublime-imfix.so sublime_text
 */
#include <gtk/gtk.h>
#include <gdk/gdkx.h>

typedef GdkSegment GdkRegionBox;

struct _GdkRegion
{
    long size;
    long numRects;
    GdkRegionBox *rects;
    GdkRegionBox extents;
};

GtkIMContext *local_context;

void
gdk_region_get_clipbox (const GdkRegion *region,
                        GdkRectangle    *rectangle)
{
    g_return_if_fail (region != NULL);
    g_return_if_fail (rectangle != NULL);

    rectangle->x = region->extents.x1;
    rectangle->y = region->extents.y1;
    rectangle->width = region->extents.x2 - region->extents.x1;
    rectangle->height = region->extents.y2 - region->extents.y1;
    GdkRectangle rect;
    rect.x = rectangle->x;
    rect.y = rectangle->y;
    rect.width = 0;
    rect.height = rectangle->height;

    //The caret width is 2;
    //Maybe sometimes we will make a mistake, but for most of the time, it should be the caret.
    if (rectangle->width == 2 && GTK_IS_IM_CONTEXT(local_context)) {
        gtk_im_context_set_cursor_location(local_context, rectangle);
    }
}

//this is needed, for example, if you input something in file dialog and return back the edit area
//context will lost, so here we set it again.

static GdkFilterReturn event_filter (GdkXEvent *xevent, GdkEvent *event, gpointer im_context)
{
    XEvent *xev = (XEvent *)xevent;

    if (xev->type == KeyRelease && GTK_IS_IM_CONTEXT(im_context)) {
        GdkWindow *win = g_object_get_data(G_OBJECT(im_context), "window");

        if (GDK_IS_WINDOW(win)) {
            gtk_im_context_set_client_window(im_context, win);
        }
    }

    return GDK_FILTER_CONTINUE;
}

void gtk_im_context_set_client_window (GtkIMContext *context,
                                       GdkWindow    *window)
{
    GtkIMContextClass *klass;
    g_return_if_fail (GTK_IS_IM_CONTEXT (context));
    klass = GTK_IM_CONTEXT_GET_CLASS (context);

    if (klass->set_client_window) {
        klass->set_client_window (context, window);
    }

    if (!GDK_IS_WINDOW (window)) {
        return;
    }

    g_object_set_data(G_OBJECT(context), "window", window);
    int width = gdk_window_get_width(window);
    int height = gdk_window_get_height(window);

    if (width != 0 && height != 0) {
        gtk_im_context_focus_in(context);
        local_context = context;
    }

    gdk_window_add_filter (window, event_filter, context);
}
```

保存后，使用以下命令进行编译：

```sh
gcc -shared -o libsublime-imfix.so sublime_imfix.c  `pkg-config --libs --cflags gtk+-2.0` -fPIC
```

编译完成后，将在当前目录下得到新的文件：libsublime-imfix.so。将该文件移动到Sublime Text 3的安装目录：

```sh
sudo mv ~/projects/sublime/imfix/libsublime-imfix.so /opt/sublime_text/
```

##修改/usr/bin/subl

/usr/bin/subl是Sublime Text安装完成后设置的启动脚本，文件原内容如下：

```
#!/bin/sh
exec /opt/sublime_text/sublime_text "$@"
```

添加内容：`LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so `，如下：

```sh
#!/bin/sh
LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so exec /opt/sublime_text/sublime_text "$@"
```

保存。下次启动Sublime Text时使用命令subl即可使用中文输入法输入中文。

##启动Sublime Text

```sh
subl
```

##参考资料

* [0] [Ubuntu下Sublime Text 3解决无法输入中文的方法](http://jingyan.baidu.com/article/f3ad7d0ff8731609c3345b3b.html)
* [1] [在Ubuntu 14.04中使SublimeText 3支持中文输入法](http://blog.csdn.net/cywosp/article/details/32350899)