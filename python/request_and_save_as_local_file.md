```python
import requests
import shutil

url = '****'
r = requests.get(url, stream=True)
if r.status_code == 200:
    with open(path, 'wb') as f:
        r.raw.decode_content = True
        shutil.copyfileobj(r.raw, f)
```

```python
import requests

#This'll read the data in 128 byte chunks
url = '****'
r = requests.get(url, stream=True)
if r.status_code == 200:
    with open(path, 'wb') as f:
        for chunk in r:
            f.write(chunk)
```

```python
import requests

#use the Response.iter_content() method with a custom chunk size.
url = '****'
r = requests.get(url, stream=True)
if r.status_code == 200:
    with open(path, 'wb') as f:
        for chunk in r.iter_content(1024):
            f.write(chunk)
```

Note that you need to open the destination file in binary mode to ensure python doesn't try and translate newlines for you. We also set `stream=True` so that requests doesn't download the whole data into memory first.
