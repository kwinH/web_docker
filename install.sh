#!/bin/bash                                                                                                                                                                                                                                      
# author:kwin
# Email:kwinwong@hotmail.com

basePath=`pwd`

 docker network create web

 docker image ls |grep php7.3-apache > /dev/null

 #$? 退出状态是一个数字，一般情况下，大部分命令执行成功会返回 0，失败返回 1
 if [ $? -eq 1 ]; then
 echo 创建php7.3-apache镜像中...
 docker build -t php7.3-apache .
 fi


 cd nginx
 docker-compose up  -d --no-recreate

 cd ${basePath}/mysql
 docker-compose up  -d --no-recreate




createProject(){
cd ${basePath}  

echo '请输入你要创建的项目名称:'
read projectName

sed -i 's/\(container_name: \).*/\1'"$projectName"'/' docker-compose.yml
sed -i 's/\(\/nginx\/www\/\).*:/\1'"$projectName"':/' docker-compose.yml


echo '启动文件是否在public文件夹下[n/y] 直接回车 默认y 其他目录则请输入目录名:'
read isPublic 
isPublic=${isPublic:-"y"}

if [ $isPublic == "y" ]; then
projectPath="${basePath}/nginx/www/${projectName}/public"
projectRoot="\/${projectName}\/public"
sed -i 's/\(APACHE_DOCUMENT_ROOT=\/var\/www\/html\).*/\1\/public/' docker-compose.yml
elif [ $isPublic == "n" ]; then
projectPath="${basePath}/nginx/www/${projectName}"
projectRoot="\/${projectName}"
sed -i 's/\(APACHE_DOCUMENT_ROOT=\/var\/www\/html\).*/\1/' docker-compose.yml
else
projectPath="${basePath}/nginx/www/${projectName}/${isPublic}"
projectRoot="\/${projectName}\/${isPublic}"
sed -i 's/\(APACHE_DOCUMENT_ROOT=\/var\/www\/html\).*/\1\/'"$isPublic"'/' docker-compose.yml
fi

if test ! -d ${projectPath}
then
mkdir -p ${projectPath}
fi


nginxConfPath="${basePath}/nginx/conf/conf.d/"
cp ${nginxConfPath}default ${nginxConfPath}${projectName}.conf 

sed -i 's/\(\/var\/www\).*/\1'"$projectRoot"';/' ${nginxConfPath}${projectName}.conf
sed -i 's/\(http:\/\/\).*/\1'"$projectName"':9000;/' ${nginxConfPath}${projectName}.conf


echo '请输入要绑定的域名:'
read serverName 
sed -i 's/\(server_name\s*\).*/\1'"$serverName"';/' ${nginxConfPath}${projectName}.conf

docker-compose up  -d --no-recreate   

docker exec -d nginx nginx -s reload
}


createProject