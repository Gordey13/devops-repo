Команды для построения playbook

```
ansible all -m setup - конфигурация сервера
```

Генерация шаблонов j2 template
```
{{ Template_j2 }}
{{ anisble_hostname }}
{{ ansible_of_family }}
{{ ansible_default_ipv4.address }}
```

ansible playbook
```
 - name: generate index.html file
   template: src={{ source_folder }}/index.j2 dest={{ destin_folder }}.html mode=0555
   copy: src={{ source_folder }}/{{ item }} dest={{ destin_folder }} mode=0555
```
