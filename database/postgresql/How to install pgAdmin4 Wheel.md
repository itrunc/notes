According to https://www.pgadmin.org/download/pip4.php.

Install the virtualenv by running:

```bash
sudo apt-get install virtualenv
```

You also need to install these 2 libraries:

```bash
sudo apt-get install libpq-dev python-dev 
```

Then:

```bash
cd ~/bin/
virtualenv pgadmin4
```

I prefer to use the ~/bin/ directory for installing applications.

Then you download the pgadmin4-1.1-py2-none-any.whl or pgadmin4-1.1-py3-none-any.whl depending on the python version you use. For this example we use python 2.7.

You download pgadmin4:

```bash
wget https://ftp.postgresql.org/pub/pgadmin3/pgadmin4/v1.1/pip/pgadmin4-1.1-py2-none-any.whl
```

Activate the virtualenv:

```bash
. ~/bin/pgadmin4/bin/activate
```

After that you will see (pgadmin4) in the terminal.

Inside of pgadmin4 run:

```bash
pip install ./pgadmin4-1.1-py2-none-any.whl
```

After that you must be able to run pgadmin4:

```bash
python ~/bin/pgadmin4/lib/python2.7/site-packages/pgadmin4/pgAdmin4.py 
```

In order to make the running process a bit easier you can create an alias. For instance, in Ubuntu 16.04 LTS, add alias in the ~/.bash_aliases file:

```bash
alias pgadmin4='. /home/your_username/bin/pgadmin4/bin/activate; /home/your_username/bin/pgadmin4/lib/python2.7/site-packages/pgadmin4/pgAdmin4.py'
```

Where your_username should be replaced by your real user name.

Then give execute permission, for example, 764 to the pgAdmin4.py file in:

```bash
/home/your_username/bin/pgadmin4/lib/python2.7/site-packages/pgadmin4/pgAdmin4.py
```

Also you need to edit the pgAdmin4.py file and add this line in the very top:

```bash
#!/home/your_username/bin/pgadmin4/bin/python
```

where your_username is your real user name.

This will make sure that you run the application using the required version of python and include all necessary dependencies in order to run pgadmin4.

Then run . ~/.bashrc in order to apply the changes.

So now you can open your terminal and simply type pgadmin4 in order to run it.

Open your browser and point to:

```
http://127.0.0.1:5050
```

One more thing to note - if you need to run pgadmin4 in desktop mode you need to change SERVER_MODE to False in:

```
/home/your_username/bin/pgadmin4/lib/python2.7/site-packages/pgadmin4/config.py
```

Otherwise when you visit localhost:5050 it will ask you for your login and password.
