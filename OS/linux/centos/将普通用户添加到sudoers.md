#CentOS����ͨ�û���ӵ�sudoers��

���նˣ�Ӧ�ó��� > ϵͳ���� > �նˣ����������

```bash
su -
```

����root�û������룬�س�����root��

�������

```bash
visudo
```

����sudoers�ı༭״̬���ҵ������У�

```
# %wheel	ALL=(ALL)	ALL
```

�����׵� # ȥ�������档

Ϊ�û�����û��飺

```bash
usermod -aG wheel ben
```

��������Ϊ�û�ben����û���wheel��

����ϵͳ��

```bash
reboot
```
