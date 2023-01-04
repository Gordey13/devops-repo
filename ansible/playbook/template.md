```
	name: Install Apache and Upload my Home Page
	hosts: all
	become: yes
	
	vars:
		source_folder: ./MyWebSite2
		destin_folder: /var/www/html
	
	tasks:
	- block: # ======BLock for REDHAT=====
		- name: Install Apache Web Server for RedHat
		yum: name=httpd state=latest
		- name: Start Web Server service for RedHat
		service: name=httpd state=started enabled=yes
	when: ansible_os_family == "RedHat"
	
	- block: #=========Block for UBUNTU=====
		- name: Install Apache Web Server for Debian
		apt: name=apache2 state=latest
		- name: Start Web Server service for Debian
		service: name=apache2 state=started enabled=yes
	when: ansible_os_family == "Debian"
	
	- name: Generate INDEX.HTML file
	template: src={{ source_folder }}/index.j2 
	dest={{ destin_folder }}/index.html mode=0555
	notify:
		- Restart Apache RedHat
		- Restart Apache Debian
	
	- name: Copy HomePage file to Web Server
	copy: src={{ source_folder }}/{{ item }} 
	dest={{ destin_folder }} mode=0555
	loop:
		- "bahamas.png"
		- "bulgaria.png"
		- "jordan.png"
		- "newzeland.png"
	notify:
		- Restart Apache RedHat
		- Restart Apache Debian
	
	handlers:
	- name: Restart Apache RedHat
		service: name=httpd state=restarted
		when: ansible_os_family == "RedHat"
	
	- name: Restart Apache Debian
		service: name=apache2 state=restarted
		when: ansible_os_family == "Debian"
```