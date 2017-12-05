# ASP.NET MVC架构与实战系列之三：MVC控件解析

俗话说"工欲善其事，必先利其器"，要真正的开发MVC网站，不光要掌握我在前两节提到的理论知识，而且还要拥有强大的武器装备。MVC视图开发是通过HtmlHelper的各种扩展方法来实现的(位于System.Web.Mvc.Html下)。主要包含以下7大类：FormExtensions、InputExtensions、LinkExtensions、SelectExtensions、TextAreaExtensions、ValidationExtensions及RenderPartialExtensions类。不仅如此，通过HtmlHelper的扩展方法还能开发更多的自定义控件(如我以后讲到的GridView等)。下面我一一讲解这些控件。

FormExtensions：在视图中添加表单和表单路由，分别是BeginForm、BeginRouteForm和EndForm。BeginForm用于定义表单的开始部分，重载方法如下：

```C#
BeginForm();
BeginForm(object routeValues);
BeginForm(RouteValueDictionary routeValues);
BeginForm(string actionName,string controllerName);
BeginForm(string actionName,string controllerName,object routeValues);
BeginForm(string actionName,string controllerName,RouteValueDictionary routeValues);
BeginForm(string actionName,string controllerName,FormMethod method);
BeginForm(string actionName,string controllerName,object routeValues,FormMethod method);
BeginForm(string actionName,string controllerName,RouteValueDictionary routeVaues,FormMethod method);
BeginForm(string actionName,string controllerName,FormMethod method,object htmlAttributes);
BeginForm(string actionName,string controllerName,FormMethod method,IDictionary<string,object> htmlAttributes);
BeginForm(string actionName,string controllerName,object routeValues,FormMethod method,object htmlAttributes);
BeginForm(string actionName,string controllerName,RouteValueDictionary routeValues,FormMethod method,IDictionary<string,object> htmlAttributes);
```

可以通过以下代码设置路由对象：

```C#
Html.BeginForm(new { controller = "blog", action = "show", author = "miracle" })
```

对应生成的HTML代码(默认提交方法为post)：

```html
<form action="/blog/show/miracle" method="post"/>
```

也可以通过BeginForm设置提交方法，以FormMethod为最高优先级，然后才是属性设置。

```C#
Html.BeginForm("show", "blog", FormMethod.Post, new { method = "get" })
```

对应生成的HTML代码(尽管后面又对方法进行了更改，但是以FormMethod优先级最高，提交方法仍然为post)：

```html
<form action="/blog/show" method="post"/>
```

还可以设置属性(例如id,class等)，如同时在属性中设置了action，则以属性设置为最高优先级。

```C#
Html.BeginForm("show", "blog",
                 new RouteValueDictionary { { "author", "miracle" } },
                 FormMethod.Post,
                 new RouteValueDictionary { { "action", "compose" }, { "class", "begin-form" } })
```

对应生成的HTML代码(添加了class，同时更改了action)：

```html
<form action="/blog/show/miracle" class="begin-form" method="post"/>
```

同时，也可以利用BeginRouteForm来定义form开头部分，不过不同的是，此时不用强制指定controller(当前也可以指定)，默认当前页面所在的目录对应的控制器。重载方法如下：

```C#
BeginRouteForm(object routeValues);
BeginRouteForm(RouteValueDictionary routeValues);
BeginRouteForm(string routeName);
BeginRouteForm(string routeName,object routeValues);
BeginRouteForm(string routeName,RouteValueDictionary routeValues);
BeginRouteForm(string routeName,FormMethod method);
BeginRouteForm(string routeName,object routeValues,FormMethod method);
BeginRouteForm(string routeName,RouteValueDictionary routeValues,FormMethod method);
BeginRouteForm(string routeName,FormMethod method,object htmlAttributes);
BeginRouteForm(string routeName,FormMethod method,IDictionary<string,object> htmlAttributes);
BeginRouteForm(string routeName,object routeValues,FormMethod method,object htmlAttributes);
BeginRouteForm(string routeName,RouteValueDictionary routeValues,FormMethod method,IDictionary<string,object> htmlAttributes);
```

可以通过以下代码设置路由对象：

```C#
Html.BeginRouteForm(new { action="show"})
```

对应生成的HTML代码(尽管没有指定controller)：

```html
<form action="/blog/show" method="post"/>
```

其他的设置与BeginForm类似。可通过EndForm定义结尾部分，不过一般在实际项目中，使用using来定义form而不是调用Html.EndForm。

```asp
<% using (Html.BeginForm(new { controller = "blog", action = "show", author = "miracle" }))
  {%>
  表单内容
<%} %>
```

InputExtensions：包含设置CheckBox、RadioButton、Hidden、TextBox及Password控件。

首先来看CheckBox控件，重载方法列表：

```C#
CheckBox(string name);
CheckBox(string name,bool isChecked);
CheckBox(string name,bool isChecked,object htmlAttributes);
CheckBox(string name,object htmlAttributes);
CheckBox(string name,IDictionary<string,object> htmlAttributes);
CheckBox(string name,bool isChecked,IDictionary<string,object> htmlAttributes);
```

我们来看看对应的页面代码：

```asp
<%using (Html.BeginForm("CheckBox", "Control"))
  {%>
<fieldset>
    <legend>设置字体</legend>
    <%=Html.CheckBox("chkBlack", true, new  { id="chkBlack"})%>
    <label for="chkBlack">
        黑色</label>
    <%=Html.CheckBox("chkBlue", false, new { id = "chkBlue" })%>
    <label for="chkBlue">
        蓝色</label>
</fieldset>
<%} %>
```

对应生成的HTML代码：

```html
<form action="/Control/CheckBox" method="post">
    <fieldset>
        <legend>设置字体</legend>
        <input checked="checked" id="chkBlack" name="chkBlack" type="checkbox" value="true" />
        <input name="chkBlack" type="hidden" value="false" />
        <label for="chkBlack">
            黑色</label>
        <input id="chkBlue" name="chkBlue" type="checkbox" value="true" />
        <input name="chkBlue" type="hidden" value="false" />
        <label for="chkBlue">
            蓝色</label>
    </fieldset>
</form>
```

我们可以看出，每一个CheckBox都会对应另外生成一个隐藏控件，可以利用它来检测复选框的选中状态。

```C#
public ActionResult ShowCheckBox(FormCollection form)
{
    bool isCheckedBlack = form["chkBlack"].Contains("true");
    bool isCheckedBlue = form["chkBlue"].Contains("true");
    ViewData["Black"] = isCheckedBlack;
    ViewData["Blue"] = isCheckedBlue;
    return View();
}
```

接下来看看单选控件RadioButton，重载方法列表：

```C#
RadioButton(string name,object value);
RadioButton(string name,object value,object htmlAttributes);
RadioButton(string name,object value,IDictionary<string,object> htmlAttributes);
RadioButton(string name,object value,bool isChecked);
RadioButton(string name,object value,bool isChecked,object htmlAttributes);
RadioButton(string name,object value,bool isChecked,IDictionary<string,object> htmlAttributes);
```

```asp
<%using (Html.BeginForm("RadioButton", "Control"))
  {%>
<fieldset>
    <legend>设置字体</legend>
    <%=Html.RadioButton("color", "black", true, new { id = "rbBlack" })%>
    <label for="rbBlack">
        黑色</label>
    <%=Html.RadioButton("color", "blue", false, new { id = "rbBlue" })%>
    <label for="rbBlue">
        蓝色</label>
</fieldset>
<%} %>
```

```html
<form action="/Control/RadioButton" method="post">
<fieldset>
    <legend>设置字体</legend>
    <input checked="checked" id="rbBlack" name="color" type="radio" value="black" />
    <label for="rbBlack">
        黑色</label>
    <input id="rbBlue" name="color" type="radio" value="blue" />
    <label for="rbBlue">
        蓝色</label>
</fieldset>
</form>
```

我们可以发现RadioButton的name值是一样的，保证单选的唯一性。同时不需要额外的隐藏控件来保存是否选中。

接下来看看隐藏控件是如何实现的：

```C#
Hidden(string name);
Hidden(string name,object value);
Hidden(string name,object value,object htmlAttributes);
Hidden(string name,object value,IDictionary<string,object> htmlAttributes);
```

生成的隐藏控件及HTML代码如下：

```asp
@Html.Hidden("name", "miracle");
```

```html
<input id="name" name="name" type="hidden" value="miracle" />
```

由于文本框及密码的生成方式与Hidden类似，这里就不再介绍了。

LinkExtensions：在视图中设置链接，包含ActionLink和RouteLink。两者基本功能一致，只是后者可以指定路由名称而已。

我们以ActionLink为例来讲解，重载方法列表：

```C#
ActionLink(string linkText,string actionName);
ActionLink(string linkText,string actionName,object routeValues);
ActionLink(string linkText,string actionName,object routeValues,object htmlAttributes);
ActionLink(string linkText,string actionName,RouteValueDictionary routeValues);
ActionLink(string linkText,string actionName,RouteValueDictionary routeValues,IDictionary<string,object> htmlAttributes);
ActionLink(string linkText,string actionName,string controller);
ActionLink(string linkText,string actionName,string controller,object routeValues,object htmlAttributes);
ActionLink(string linkText,string actionName,string controller,RouteValueDictionary routeValues,IDictionary<string,object> htmlAttributes);
ActionLink(string linkText,string actionName,string controller,string protocol,string hostName,string fragment,object routeValues,object htmlAttributes);
ActionLink(string linkText,string actionName,string controller,string protocol,string hostName,string fragment,RouteValueDictionary routeValues,IDictionary<string,object> htmlAttributes);
```

```asp
Html.ActionLink("Miracle's Blog", "Show", "Blog")
```

```html
<a href="/Blog/Show">Miracle's Blog</a>
```

在这里，简单的列举一下RouteLink的相关方法:

```C#
RouteLink(string linkText,object routeValues);
RouteLink(string linkText,RouteValueDictionary routeValues);
RouteLink(string linkText,string routeName,object routeValues);
RouteLink(string linkText,string routeName,RouteValueDictionary routeValues);
RouteLink(string linkText,object routeValues,object htmlAttributes);
RouteLink(string linkText,RouteValueDictionary routeValues,IDictionary<string,object> htmlAttributes);
RouteLink(string linkText,string routeName,object routeValues,object htmlAttributes);
RouteLink(string linkText,string routeName,RouteValueDictionary routeValues,IDictionary<string,object> htmlAttributes);
RouteLink(string linkText,string routeName,string protocol,string hostName,string fragment,object routeValues,object htmlAttributes);
RouteLink(string linkText,string routeName,string protocol,string hostName,string fragment,RouteValueDictionary routeValues,IDictionary<string,object> htmlAttributes);
```

```asp
Html.RouteLink("Miracle's Blog", "default", new { author="miracle"})
```

```html
<a href="/Blog/Show/miracle">Miracle's Blog</a>
```

SelectExtensions：包含DropDownList和ListBox控件。前者为下拉列表，后者为列表框。

DropDownList下拉列表的重载方法列表：

```C#
DropDownList(string name);
DropDownList(string name,string optionLabel);
DropDownList(string name,IEnumerable<SelectListItem> selectList,string optionLabel);
DropDownList(string name,IEnumerable<SelectListItem> selectList,string optionLabel,object htmlAttributes);
DropDownList(string name,IEnumerable<SelectListItem> selectList);
DropDownList(string name,IEnumerable<SelectListItem> selectList,object htmlAttributes);
DropDownList(string name,IEnumerable<SelectListItem> selectList,IDictionary<string,object> htmlAttributes);
DropDownList(string name,IEnumerable<SelectListItem> selectList,string optionLabel,IDictionary<string,object> htmlAttributes);
```

查看一下DropDownList应用页面及HTML：

```C#
public ActionResult ShowDropDownList()
{
    ViewData["Category"] = new SelectList(db.Categories, "CategoryID", "CategoryName");
    return View();
}
```

```asp
<%using (Html.BeginForm("SelectDropDownList", "Control"))
  {%>
<fieldset>
    <legend>选择类别</legend>
    <%=Html.DropDownList("Category")%>
    <input type="submit" value="选择"/>
</fieldset>
<%} %>
```

```html
<form action="/Control/SelectDropDownList" method="post">
<fieldset>
<legend>选择产品类别</legend>
    <select id="Category" name="Category">
        <option value="1">Beverages</option>
        <option value="2">Condiments</option>
        <option value="3">Confections</option>
        <option value="4">Dairy Products</option>
        <option value="5">Grains/Cereals</option>
        <option value="6">Meat/Poultry</option>
        <option value="7">Produce</option>
        <option value="8">Seafood</option>
    </select>
    <input type="submit" value="选择"/></fieldset>
</form>
```

要获取当前选中的项，代码如下：

```C#
public ActionResult SelectDropDownList(FormCollection form)
{
    var selectedCategories = form["Category"];
    ViewData["SelectCategory"] = new SelectList(db.Categories, "CategoryID", "CategoryName", selectedCategories);
    return View();
}
```

```asp
<%using (Html.BeginForm("ShowDropDownList", "Control"))
{%>
    <fieldset>
        <legend>当前选中类别</legend>
        <%=Html.DropDownList("SelectCategory")%>
        <input type="submit" value="返回"/>
    </fieldset>
<%} %>
```

```html
<form action="/" method="post">
<fieldset>
    <legend>当前选中类别</legend>
    <select id="SelectCategory" name="SelectCategory">
        <option value="1">Beverages</option>
        <option value="2">Condiments</option>
        <option value="3">Confections</option>
        <option value="4">Dairy Products</option>
        <option value="5">Grains/Cereals</option>
        <option value="6">Meat/Poultry</option>
        <option value="7">Produce</option>
        <option selected="selected" value="8">Seafood</option>
    </select>
    <input type="submit" value="返回"/>
</fieldset>
</form>
```

ListBox列表框可选中多个项(设置multiple)：

```C#
ListBox(string name);
ListBox(string name,IEnumerable<SelectListItem> selectList);
ListBox(string name,IEnumerable<SelectListItem> selectList,object htmlAttributes);
ListBox(string name,IEnumerable<SelectListItem> selectList,IDictionary<string,object> htmlAttributes);
```

查看一下ListBox应用页面及HTML：

```C#
public ActionResult ShowListBox()
{
    ViewData["Category"] = new SelectList(db.Categories, "CategoryID", "CategoryName");
    return View();
}
```

```asp
<%using (Html.BeginForm("SelectListBox", "Control"))
  {%>
<fieldset>
    <legend>选择类别</legend>
    <%=Html.ListBox("Category")%>
    <input type="submit" value="选择"/>
</fieldset>
<%} %>
```

```html
<form action="/Control/SelectListBox" method="post">
<fieldset>
    <legend>选择类别</legend>
    <select id="Category" multiple="multiple" name="Category">
        <option value="1">Beverages</option>
        <option value="2">Condiments</option>
        <option value="3">Confections</option>
        <option value="4">Dairy Products</option>
        <option value="5">Grains/Cereals</option>
        <option value="6">Meat/Poultry</option>
        <option value="7">Produce</option>
        <option value="8">Seafood</option>
    </select>
    <input type="submit" value="选择"/>
</fieldset>
</form>
```

当选中多项时，代码如下：

```C#
public ActionResult SelectListBox(FormCollection form)
{
    var selectedCategories = form["Category"].Split(',').AsEnumerable();
    ViewData["SelectCategory"] = new MultiSelectList(db.Categories, "CategoryID", "CategoryName", selectedCategories);
    return View();
}
```

```asp
<%using (Html.BeginForm("ShowListBox", "Control"))
  {%>
<fieldset>
    <legend>当前选中类别</legend>
    <%=Html.ListBox("SelectCategory")%>
    <input type="submit" value="返回"/>
</fieldset>
<%} %>
```

```html
<form action="/" method="post">
<fieldset>
    <legend>当前选中类别</legend>
    <select id="SelectCategory" multiple="multiple" name="SelectCategory">
        <option value="1">Beverages</option>
        <option selected="selected" value="2">Condiments</option>
        <option selected="selected" value="3">Confections</option>
        <option value="4">Dairy Products</option>
        <option value="5">Grains/Cereals</option>
        <option value="6">Meat/Poultry</option>
        <option value="7">Produce</option>
        <option value="8">Seafood</option>
    </select>
    <input type="submit" value="返回"/>
</fieldset>
</form>
```

TextAreaExtensions：设置文本域控件。重载方法列表：

```C#
TextArea(string name);
TextArea(string name,object htmlAttributes);
TextArea(string name,IDictionary<string,object> htmlAttributes);
TextArea(string name,string value);
TextArea(string name,string value,object htmlAttributes);
TextArea(string name,string value,IDictionary<string,object> htmlAttributes);
TextArea(string name,string value,int rows,int cols,object htmlAttributes);
TextArea(string name,string value,int rows,int cols,IDictionary<string,object> htmlAttributes);
```

我们先添加一个简单的TextArea，默认情况下会生成2行10列：

```asp
Html.TextArea("description", "My name is miracle")
```

```html
<textarea cols="20" id="description" name="description" rows="2">My name is miracle</textarea>
```

也可以指定行数和列数:

```asp
Html.TextArea("description", "My name is miracle", new { rows=5,cols=10 })
```

```html
<textarea cols="10" id="description" name="description" rows="5">My name is miracle</textarea>
```

ValidationExtensions：实现表单控件的输入验证，包含ValidationMessage和ValidationSummary控件。

首先简单的看一下ValidationMessage控件，重载方法列表：

```C#
ValidationMessage(string modelName);
ValidationMessage(string modelName,object htmlAttributes);
ValidationMessage(string modelName,string validationMessage);
ValidationMessage(string modelName,string validationMessage,object htmlAttributes);
ValidationMessage(string modelName,IDictionary<string,object> htmlAttributes);
ValidationMessage(string modelName,string validationMessage,IDictionary<string,object> htmlAttributes);
```

```C#
Html.TextBox("ProductName")
Html.ValidationMessage("ProductName", "*")
```

接下来看一下ValidationMessage和ValidationSummary的结合运用:

```C#
ValidationSummary();
ValidationSummary(string message);
ValidationSummary(string message,object htmlAttributes);
ValidationSummary(string message,IDictionary<string,object> htmlAttributes);
```

一般ValidationSummary应放在表单的外部：

```asp
<%=Html.ValidationSummary("创建不成功,请确认是否填写正确！") %>
<%using (Html.BeginForm())
  {%>
<fieldset>
    <legend>输入验证</legend>
    <p>
        <label for="ProductName">名称:</label>
        <%=Html.TextBox("ProductName")%>
        <%=Html.ValidationMessage("ProductName","*") %>
    </p>
    <p>
        <label for="Description">描述:</label>
        <%=Html.TextBox("Description")%>
        <%=Html.ValidationMessage("Description", "*")%>
    </p>
    <p>
        <label for="UnitPrice">单价:</label>
        <%=Html.TextBox("UnitPrice")%>
        <%=Html.ValidationMessage("UnitPrice", "*")%>
    </p>
    <p>
        <input type="submit" value="创建"/>
    </p>
</fieldset>
<%} %>
```

通常结合两者使用，并在错误逻辑中加入ModelState，通过ModelState.IsValid判断是否通过自定义验证。

RenderPartialExtensions：实现将现有自定义控件或分部视图加入到视图，重载方法列表如下：

```C#
RenderPartial(string partialViewName);
RenderPartial(string partialViewName,ViewDataDictionary viewData);
RenderPartial(string partialViewName,object model);
RenderPartial(string partialViewName,object model,ViewDataDictionary viewData);
```

如将类别列表控件(CategoryList.ascx)加入到当前视图:

```C#
Html.RenderPartial("CategoryList");
```

## Reference

* [1] [原文链接](http://www.cnblogs.com/hmiinyu/archive/2012/05/30/2523492.html)