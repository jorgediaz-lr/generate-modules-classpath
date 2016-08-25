#!/bin/bash

ORIGINAL_WORKING_DIR=$(pwd)

if [ "X${1}" != "X" ]
then
	cd ${1}
fi

if [ ! -f .classpath ]
then
	echo "Error: '.classpath' file not found!!!"
	exit 0
fi

if [ ! -d modules ]
then
	echo "Error: 'modules' directory not found!!!"
	exit 0
fi

if [ ! -f .classpath_backup ]
then
	mv .classpath .classpath_backup
fi

NUMLINES=$(wc -l .classpath_backup | tr -d " " |cut -d"." -f1 )
let NUMLINES=NUMLINES-1

head -n $NUMLINES .classpath_backup | grep -v "path=\"modules" |grep -v "lib/development/jasper.jar" > .classpath
rm .classpath_aux 2> /dev/null

for i in $(find modules -name java |grep "src/main/java" | sort -u | grep -v "src/main/resources" | grep -v "samples/src" | grep -v "src/main/java/com/liferay" )
do
	echo -e "\t<classpathentry kind=\"src\" path=\"$i\"/>" >> .classpath_aux
done

for i in $(find modules -name service |grep docroot/WEB-INF/service |grep -v "com/liferay")
do
	echo -e "\t<classpathentry kind=\"src\" path=\"$i\"/>" >> .classpath_aux
done

for i in $(find modules -name "src" |grep "docroot/WEB-INF" )
do
	echo -e "\t<classpathentry kind=\"src\" path=\"$i\"/>" >> .classpath_aux
done

for i in $(find . -name java |grep -v "src/main/java" |grep "src/test" | sort -u )
do
	echo -e "\t<classpathentry kind=\"src\" path=\"$i\"/>" >> .classpath_aux
done

for i in $(find modules -name integration |grep "test/integration" | grep -v "src/main/java/com/liferay" | grep -v "src/main/resources/com/liferay" | sort -u )
do
	echo -e "\t<classpathentry kind=\"src\" path=\"$i\"/>" >> .classpath_aux
done

cat .classpath_aux | sort -u >> .classpath

rm .classpath_aux

for i in $(ls -1d .gradle/caches/modules-2/files-2.1/*/*); do find $i  -name "*.jar" |tail -1 ; done > jar_list

find .gradle/wrapper/dists -name "gradle*.jar"  |grep LIFERAY-PATCHED >> jar_list

find modules/apps/opensocial -name "shindig-*.jar" >> jar_list

find modules/apps/static -name "*.jar" |grep -v sources >> jar_list

for line in $(cat jar_list)
do
	jar=$(echo $line  |rev |cut -d"/" -f1 | cut -d"-" -f2- |rev)
	count=$(grep ${jar}.jar .classpath_backup |wc -l)
	if [ $count -eq 0 ]
	then
		echo -e "\t<classpathentry kind=\"lib\" path=\"$line\"/>" >> .classpath_aux
	fi
done

cat .classpath_aux | sort -u >> .classpath

echo "</classpath>" >> .classpath

rm jar_list
rm .classpath_aux

cd ${ORIGINAL_WORKING_DIR}


