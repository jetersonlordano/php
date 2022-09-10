#!/bin/bash

echo "Remoção de ambiente de desenvolvimento PHP"

echo  # nova linha

echo "Esta ação ira remover totalmente qualquer versão dos seguintes items:"
echo "PHP, Mysql, MariaDB, Apache e phpMyadmin."

echo  # nova linha

echo "É recomendado fazer backup de possíveis arquivos no diretório /var/www e também banco de dados existentes no Mysql."

echo  # nova linha
read -r -p "Deseja continuar? [Yy/n] " reply
if [[ ! $reply =~ ^[Yy]$ ]]
then
echo "Script interrompido"
exit
fi

echo  # nova linha

# Remove PHP
sudo apt remove --purge php* -y
sudo rm -rf /etc/php
echo "PHP removido"
echo  # nova linha

# Remove Apache
sudo apt remove --purge apache* -y
sudo rm -rf /etc/apache2
echo  # nova linha
echo "Apache removido"
echo  # nova linha

# Remove Mysql e MariaDB
sudo apt remove --purge *mysql* -y
sudo apt remove --purge *mariadb* -y
sudo rm -rf /etc/mysql /var/lib/mysql 
dpkg -l | grep mariadb 
dpkg -l | grep mysql
echo  # nova linha
echo "Mysql e MariaDB removido"
echo  # nova linha

# Remove phpmyadmin
sudo apt remove --purge phpmyadmin* -y
sudo rm -rf /etc/phpmyadmin
echo  # nova linha
echo "phpmyadmin removido"
echo  # nova linha

sudo apt autoremove -y
sudo apt autoclean -y
sudo apt install -f -y
sudo apt update -y
echo  # nova linha
echo "Ambiente PHP removido com sucesso."
