#!/bin/bash

PHP_VERSION=8.1
PHP_INI="/etc/php/$PHP_VERSION/apache2/php.ini"
GIT_USER="Jeterson Lordano"
GIT_EMAIL="jetersonlordano@gmail.com"
SUBJ="/C=BR/ST=Parana/L=Cafelandia/O=Jeterson Studio/OU=Jeterson Studio/CN=localhost/emailAddress=jeterson@gmail.com"
MYSQL_PASSWORD="MinhaNovaSenha"

# Atualiza os pacotes
sudo apt update && sudo apt full-upgrade -y
sudo dpkg --configure -a
sudo apt install -f -y

# Instala alguns pacotes necessários
sudo apt install software-properties-common curl libssl-dev autoconf automake javascript-common -y


# Ferramentas que eu uso no dia a dia
# Remova se não precisar

# Instala e configura o Git
sudo apt install git -y
git config --global user.name $GIT_USER
git config --global user.email $GIT_EMAIL
git config --global credential.helper cache
git config --list

# traceroute
sudo apt install net-tools traceroute -y

# Instala o Apache2
sudo apt install apache2 -y
echo  # nova linha
echo 'Apache2 instalado'
echo  # nova linha

# Adiciona o PPA do PHP > 8
#sudo add-apt-repository ppa:ondrej/php -y
#sudo add-apt-repository ppa:ondrej/apache2 -y
#sudo apt update -y

# remove o PPA do PHP > 8
#sudo add-apt-repository --remove ppa:ondrej/php
#sudo ppa-purge ppa:ondrej/php
#sudo apt update -y


# Instala o PHP e algumas extensões 
sudo apt install php$PHP_VERSION php$PHP_VERSION-common php$PHP_VERSION-gmp php$PHP_VERSION-cli php$PHP_VERSION-fpm libapache2-mod-php libapache2-mod-php$PHP_VERSION php$PHP_VERSION-mysql php$PHP_VERSION-curl php$PHP_VERSION-memcached php$PHP_VERSION-dev php$PHP_VERSION-pgsql php$PHP_VERSION-sqlite3 php$PHP_VERSION-mbstring php$PHP_VERSION-gd php$PHP_VERSION-xmlrpc php$PHP_VERSION-xml php$PHP_VERSION-zip php$PHP_VERSION-bcmath php$PHP_VERSION-soap php$PHP_VERSION-intl php$PHP_VERSION-readline php$PHP_VERSION-tokenizer php$PHP_VERSION-imagick -y


echo  # nova linha
echo 'PHP instalado'
echo  # nova linha

php -v
echo  # nova linha


# Comenta a linha <policy domain="coder" rights="none" pattern="PDF" /> no arquivo /etc/ImageMagick-6/policy.xml para trabalhar com PDF no Imagick
sudo sed -i -e 's/<policy domain="coder" rights="none" pattern="PDF" \/>/<!-- <policy domain="coder" rights="none" pattern="PDF" \/> -->/g' /etc/ImageMagick-6/policy.xml

# Reincia o Apache
sudo service apache2 restart

# Mostra Imagick instalado
php -m | grep imagick
php -r 'phpinfo();' | grep imagick
echo  # nova linha

# Deixar o PHP mais seguro
# Subistui ;cgi.fix_pathinfo=1 por cgi.fix_pathinfo=0 no arquivo /etc/php/7.*/apache2/php.ini
sudo sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' $PHP_INI


# Instalar Xdebug
cd Downloads
PHP_INFO=$(php -i)
sudo curl -X POST -d "data=$PHP_INFO&submit=Analyse my phpinfo() output" https://xdebug.org/wizard >> xdebug.html

XDEBUG_LINK=$(grep -o "https://x[^']*" xdebug.html)
XDEBUG_VERSION=${XDEBUG_LINK/https:\/\/xdebug.org\/files\/}
XDEBUG_VERSION=${XDEBUG_VERSION/.tgz}

PHP_API_NR=$(grep -o "PHP API nr:[^li]*" xdebug.html)
PHP_API_NR=${PHP_API_NR/PHP API nr:<\/b> }
PHP_API_NR=${PHP_API_NR/<\/}

sudo wget -c $XDEBUG_LINK
sudo tar -xvzf xdebug-*.tgz
cd $XDEBUG_VERSION
sudo phpize
sudo ./configure
sudo make
sudo cp modules/xdebug.so /usr/lib/php/$PHP_API_NR


sudo rm -R xdebug*
sudo rm package.xml
cd ~
sudo rm -R ~/Downloads/xdebug*
sudo rm ~/Downloads/package.xml

XDEBUG_CONF = "/etc/php/$PHP_VERSION/apache2/conf.d/99-xdebug.ini"
XDEBUG_CONF="/etc/php/$PHP_VERSION/apache2/conf.d/99-xdebug.ini"
sudo touch $XDEBUG_CONF
sudo sh -c "echo zend_extension = xdebug >> $XDEBUG_CONF"

sudo sh -c "echo  >> $PHP_INI"
sudo sh -c "echo [xdebug] >> $PHP_INI"
sudo sh -c "echo zend_extension = /usr/lib/php/$PHP_API_NR/xdebug.so >> $PHP_INI"

sudo sh -c "echo xdebug.extended_info=1 >> $PHP_INI"
sudo sh -c "echo xdebug.max_nesting_level=1000 >> $PHP_INI"
sudo sh -c "echo xdebug.profiler_enable=1 >> $PHP_INI"
sudo sh -c "echo xdebug.profiler_enable_trigger=1 >> $PHP_INI"
sudo sh -c "echo xdebug.remote_enable=1 >> $PHP_INI"
sudo sh -c "echo xdebug.remote_host=127.0.0.1 >> $PHP_INI"
sudo sh -c "echo xdebug.remote_port=9000 >> $PHP_INI"
sudo sh -c "echo xdebug.remote_handler=\"dbgp\" >> $PHP_INI"
sudo sh -c "echo xdebug.remote_mode=req >> $PHP_INI"
sudo sh -c "echo xdebug.remote_log=\"/tmp/xdebug_remote.log\" >> $PHP_INI"
sudo sh -c "echo xdebug.show_local_vars=1 >> $PHP_INI"
sudo sh -c "echo xdebug.trace_output_dir=\"/tmp\" >> $PHP_INI"
sudo sh -c "echo xdebug.var_display_max_data=10240 >> $PHP_INI"
sudo sh -c "echo xdebug.var_display_max_depth=10 >> $PHP_INI"

# Reinicia o Apache
sudo service apache2 restart

# Premissões do diretório de projetos
sudo chmod -R 0777 /var/www


# Cria arquivo info.php
sudo rm /var/www/html/info.php
echo '<?php phpinfo();' >> /var/www/html/info.php
sudo chmod -R 0777 /var/www/html/info.php

# Instala MySQL
sudo apt install mysql-server -y
sudo service mysql start
sudo service mysql stop
sudo usermod -d /var/lib/mysql/ mysql
sudo service mysql start

# Ativar modulos de reescrita e headers
sudo a2enmod rewrite && sudo service apache2 restart

sudo a2enmod headers && sudo service apache2 restart

sudo a2enmod ssl && sudo service apache2 restart

echo  # nova linha
echo 'Certificado SSL'
echo  # nova linha

# Atualiza os pacotes
sudo apt update -y

# Configura certificado SSL Auto-assinado
sudo mkdir /etc/apache2/ssl
sudo chmod -R 777 /etc/apache2/ssl
cd /etc/apache2/ssl


# Cria arquivo v3.ext
sudo wget -c https://gist.githubusercontent.com/jetersonlordano/8baef460fb37bc0b7bdbf5716f2d25fa/raw/b93871c636d7d6009dfa472cfc37056ed10dbd10/v3.ext

sudo chmod 777 /etc/apache2/ssl/v3.ext

# Cria uma chave Raiz
sudo openssl genrsa -des3 -passout pass:password -out localhost.key 2048

# Cria um certificado Raiz
sudo openssl req -x509 -new -nodes -key localhost.key -sha256 -days 1024 -out localhost.pem --passin pass:password -subj "$SUBJ"

# Criar um arquivo de solicitação de assinatura de certificado e um arquivo de chave
sudo openssl req -new -nodes -out server.csr -newkey rsa:2048 -keyout server.key --passin pass:password -subj "$SUBJ"

# Emiti o certificado SSL
sudo openssl x509 -req -in server.csr -CA localhost.pem -CAkey localhost.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile v3.ext --passin pass:password

# Certificado para Google Chrome WSL
#sudo openssl req -new -out server.csr -subj "$SUBJ" --passin pass:password
#sudo openssl rsa -in privkey.pem -out server.key
#sudo openssl x509 -in server.csr -out server.crt -req -signkey server.key -days 365 -sha256 -extfile v3.ext


# Editar /etc/apache2/sites-available/000-default.conf
# Mudar porta de 80 para 443

sudo mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/copia-000-default.conf

cd /etc/apache2/sites-available/
sudo wget -c https://gist.githubusercontent.com/jetersonlordano/8d2e6bf61d573c603092332e08f991e6/raw/544b33723f94722f282b3664428b45c00effcbd1/000-default.conf

# teste de configurações apache2
sudo apachectl configtest 

echo  # nova linha
echo "Certificado SSL Configurado"

# Reinicia o Apache
sudo service apache2 restart


echo  # nova linha
echo  # nova linha
echo "Instalação do phpMyadmin"
echo  # nova linha
echo  # nova linha


echo  # nova linha
read -r -p "Digite sua nova senha Mysql: " MYSQL_PASSWORD

echo "Sua senha é: $MYSQL_PASSWORD"

echo  # nova linha

sudo mysql -u root -p -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_PASSWORD';"

sudo mysql -u root -p$MYSQL_PASSWORD -e "flush privileges;"

echo  # nova linha
echo "Nas configurações selecione Y na primeira pergunta, sua senha mysql: $MYSQL_PASSWORD sempre que pedir e Y no restante"
echo  # nova linha

sudo mysql_secure_installation

# Instala phpmyadmin - Desativar componente de validadeção de senha para evitar erro no phpmyadmin
sudo mysql -u root -p$MYSQL_PASSWORD -e 'UNINSTALL COMPONENT "file://component_validate_password";'

sudo apt install phpmyadmin -y

sudo mysql -u root -p$MYSQL_PASSWORD -e 'INSTALL COMPONENT "file://component_validate_password";'

sudo phpenmod mbstring

# Adiciona o Include do phpmyadmin no apache2.conf /etc/apache2/apache2.conf
#echo '' >> /etc/apache2/apache2.conf
sudo sh -c "echo  >> /etc/apache2/apache2.conf"

# Na última linha
#echo Include /etc/phpmyadmin/apache.conf >> /etc/apache2/apache2.conf
sudo sh -c "echo Include /etc/phpmyadmin/apache.conf  >> /etc/apache2/apache2.conf"

# Reinicia o Apache
sudo service apache2 restart

echo #Nova Linha
echo 'Se alguma coisa no PHP não funcionar. Ative o módulo correspondente.'
echo #Nova Linha

# Configuração Manual
echo  # nova linha
echo 'Configuração Manual:'
echo  # nova linha
echo "Faça a importação do arquivo /etc/apache2/ssl/localhost.pem nos navegadores que desejar"
echo  # nova linha
#echo "Para Chrome Windows com WSL importe o arquivo server.crt"
echo 'Concluído! Abra o link http://localhost/html/info.php'
