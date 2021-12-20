pid=$(ps -aux | grep Windows10_client| awk '{if ($10!="0:00")print $2}')
kill $pid
vboxmanage controlvm Server_ubuntu poweroff
echo "Esperando a que se apaguen"
sleep 30
VBoxManage modifyvm Windows10_client --nictrace2 off
vboxmanage snapshot Server_ubuntu restore v3
vboxmanage snapshot Windows10_client restore v2
