# 怎样让git显示正常的中文文件名

git默认会对中文进行转码，包括路径中的中文。git提供一个配置项，可禁止对路径中的多字节字符进行转码。

```bash
git config --global core.quotepath false
```