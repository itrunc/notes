## Firefox 浏览器

```css
@-moz-document url-prefix() {
  .selector {
    property: value;
  }
}
```

支持所有Gecko内核的浏览器 (包括Firefox)

```css
*>.selector { property: value; }
```

## Webkit 内核浏览器

```css
@media screen and (-webkit-min-device-pixel-ratio: 0) {
  Selector {
    property: value;
  }
}
```

## Opera 浏览器

```css
html:first-child>b\ody Selector {property:value;}
```

## IE 浏览器

IE 浏览器针对不同的版本有不同个Hack方式。

### IE 9

```css
:root Selector {property: value\9;}
```

### IE 9-

```css
Selector {property: value\9;}
```

### IE 8

```css
Selector {property: value/;}
```

或：

```css
@media \0screen {
    Selector {property: value;}
}
```

### IE 8+

```css
Selector {property: value\0;}
```

### IE 7

```css
*+html Selector{property:value;}
```

或：

```css
*:first-child+html Selector {property:value;}
```

### IE 7-

```css
Selector {*property: value;}
```

### IE6

```css
Selector {
  _property: value;
}
```

或：

```css
*html Selector {
  property: value;
}
```
