#$1 -> tipo de experimento (SMB2 | SMB3 | NFS | webDav | sftp)
#$2 -> nombre del ransomware sin extension
#Arranca el servidor
if [[ $1 == "SMB3" ]]; then
	vboxmanage snapshot Server_ubuntu restore v5
	vboxmanage snapshot Windows10_client restore v5
fi
VBoxManage modifyvm Windows10_client --nictrace2 off
VBoxManage modifyvm Windows10_client --nictrace2 on --nictracefile2 /home/cliente/comparacionv2v3/trazasRansomware/$2_$1.pcap
vboxmanage startvm Server_ubuntu --type headless
#Esperar 30s
sleep 30

#Ćambiar la configuración del servidor para que use una u otra versión de SMB
if [[ $1 == "SMB3" ]]; then

	ssh server@192.168.56.102 'echo server | sudo -S mv /etc/samba/smb.conf_v3 /etc/samba/smb.conf | echo server | sudo -S service smbd restart'

fi

if [[ $1 == "SMB2" ]]; then

	ssh server@192.168.56.102 'echo server | sudo -S mv /etc/samba/smb.conf_v2 /etc/samba/smb.conf | echo server | sudo -S service smbd restart'

fi

if [[ $1 == "NFS" ]]; then
	ssh server@192.168.56.102 'echo server | sudo -S service smbd stop | echo server | sudo -S service apache2 stop'
	ssh server@192.168.56.102 'echo server | sudo -S mv /etc/exports_NFSv4 /etc/exports | echo server | sudo -S exportfs -a | echo server | sudo -S systemctl restart nfs-kernel-server'
fi

if [[ $1 == "webDav" ]]; then
	ssh server@192.168.56.102 'echo server | sudo -S service smbd stop | echo server | sudo -S systemctl stop nfs-kernel-server'
        ssh server@192.168.56.102 'echo server | sudo -S service apache2 restart'
	echo "Montar unidad en el host: sudo mount.davfs http://192.168.56.102/webdav /home/eduberrueta/pruebaWebDav/"
	echo "Cambiar permisos de los ficheros y directorios: sudo chmod 777 -R /home/eduberrueta/pruebaWebDav/*"
	echo "Comprueba que los permisos están bien"
fi

if [[ $1 == "webDavHTTPS" ]]; then
	ssh server@192.168.56.102 'echo server | sudo -S service smbd stop | echo server | sudo -S systemctl stop nfs-kernel-server'
	ssh server@192.168.56.102 'echo server | sudo -S service apache2 restart'
	echo "Montar unidad en el host: sudo mount.davfs http://192.168.56.102/webdav /home/eduberrueta/pruebaWebDav/"
        echo "Cambiar permisos de los ficheros y directorios: sudo chmod 777 -R /home/eduberrueta/pruebaWebDav/*"
        echo "Comprueba que los permisos están bien"
fi
#Arranca el cliente
#vboxmanage startvm Windows10_client
nohup vboxheadless --startvm Windows10_client &
#pid=$($!)
sleep 30
echo "Cliente arrancado. Conectate con remmina"
#Ransomware copiado en el cliente (en la carpeta compartida)
cp /home/cliente/comparacionv2v3/binarios/$2.exe /home/cliente/CompartidaClientVM/


if [[ $1 == "SMB3" ]]; then
        echo "Monta la carpeta compartida desde el explorador de archivos poniendo la ruta: \\10.0.0.2\compartida"
fi
if [[ $1 == "SMB2" ]]; then
        echo "Monta la carpeta compartida desde el explorador de archivos poniendo la ruta: \\10.0.0.2\compartida"
fi
if [[ $1 == "NFS" ]]; then
	echo "Monta la carpeta compartida desde el simbolo de systema poniendo: mount -o anon \\10.0.0.2\home\server\directorioCompartido Z:"
fi

if [[ $1 == "NFSCipher" ]]; then
	echo "NFSCIpher"
fi

if [[ $1 == "webDav" ]]; then
        echo "Monta la carpeta compartida desde el simbolo del sistema poniendo: net use Z: http://10.0.0.2/webdav /user:webdav webdav"
fi

if [[ $1 == "webDavHTTPS" ]]; then
        echo "Monta la carpeta compartida desde el símbolo del systema poniendo: net use Z: https://10.0.0.2/webdav /user:webdav webdav"
fi
echo "Pasa el ransomware al escritorio"
date
#Espera 10 minutos
sleep 600

echo "Puedes ejecutar el ransomware"

#########ACCIÓN################
echo "Comienza la hora de espera"
date
sleep 3600
################################


if [[ $1 == "SMB3" ]]; then
	
	ssh server@192.168.56.102 'echo server | sudo -S mv /etc/samba/smb.conf /etc/samba/smb.conf_v3'
	
fi

if [[ $1 == "SMB2" ]]; then
	
	ssh server@192.168.56.102 'echo server | sudo -S mv /etc/samba/smb.conf /etc/samba/smb.conf_v2'
	
fi

#Apaga las máquinas
kill $pid
vboxmanage controlvm Windows10_client poweroff
vboxmanage controlvm Server_ubuntu poweroff

#Quita la captura
sleep 30
VBoxManage modifyvm Windows10_client --nictrace2 off

#Recupera estado anterior.
vboxmanage snapshot Server_ubuntu restore v3
vboxmanage snapshot Windows10_client restore v2
