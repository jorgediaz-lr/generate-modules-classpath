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

if [ ! -f .project ]
then
	echo "Error: '.project' file not found!!!"
	exit 0
fi

if [ ! -d modules ]
then
	echo "Error: 'modules' directory not found!!!"
	exit 0
fi

GRADLE_DIR=.gradle

if [ ! -d ${GRADLE_DIR}/caches/modules-2/files-2.1/com.liferay ]
then
	GRADLE_DIR=~/.gradle

	if [ ! -d ${GRADLE_DIR}/caches/modules-2/files-2.1/com.liferay ]
	then
		echo "Error: '.gradle' directory not found or it doesn't contain JARs!!!"
		echo "Try execute 'ant all' before using this script"
		exit 0
	fi

	echo "Info: '.gradle' directory not found in current folder, using from USER_HOME"
fi

if [ ! -f .classpath_backup ]
then
	cp .classpath .classpath_backup
fi

NUMLINES=$(wc -l .classpath_backup | tr -d " " |cut -d"." -f1 )
let NUMLINES=NUMLINES-2

head -n $NUMLINES .classpath_backup | grep -v "path=\"modules" |grep -v "lib/development/jasper.jar" > .classpath_new

echo "\t<classpathentry kind=\"output\" path=\"bin/portal\" />" >> .classpath_new

rm .classpath_aux 2> /dev/null

rm java_list_1 java_list_2 java_list_3 java_list_4 2> /dev/null

find modules -type d -name "java" |grep "src/main/java" | sort -u | grep -v "src/main/resources" | grep -v "samples/src" | grep -v "src/main/java/com/liferay" | grep -v "modules/test/" | grep -v "modules/sdk/" | grep -v "modules/third-party/" | grep -v "modules/util/" | grep -v "modules/post-upgrade-fix/" | grep -v "modules/etl/" >> java_list_1 &

find modules -type d -name "resources" |egrep "src/main/resources$" | sort -u | grep -v "src/main/resources/META-INF/resources" | grep -v "src/main/java" | grep -v "samples/src" | grep -v "src/main/java/com/liferay" | grep -v "resources/src/main/resources" | grep -v "modules/test/" | grep -v "modules/sdk/" | grep -v "modules/third-party/" | grep -v "modules/util/" | grep -v "modules/post-upgrade-fix/" | grep -v "modules/etl/" >> java_list_2 &

find modules -type d -name "service" |grep docroot/WEB-INF/service |grep -v "com/liferay" >> java_list_3 &

find modules -type d -name "src" |grep "docroot/WEB-INF" >> java_list_4 &

wait

for line in $(cat java_list_1 java_list_2 java_list_3 java_list_4)
do
	echo -e "\t<classpathentry kind=\"src\" path=\"$line\" output=\"bin/${line}\" />" >> .classpath_aux
done

rm java_list_1 java_list_2 java_list_3 java_list_4 2> /dev/null

cat .classpath_aux | sort -u >> .classpath_new

rm .classpath_aux

rm jar_list_1 jar_list_2 jar_list_3 jar_list_4 2> /dev/null

for i in $(ls -1d ${GRADLE_DIR}/caches/modules-2/files-2.1/*/*); do (find $i -type f -name "*.jar" |tail -1) & done |grep -v ".gradle/caches/modules-2/files-2.1/com.liferay/com.liferay." |grep -v ".gradle/caches/modules-2/files-2.1/com.liferay.portal" >> jar_list_1 &

touch jar_list_2 &

find modules/apps/opensocial -type f -name "shindig-*.jar" >> jar_list_3 &

find modules/apps/static -type f -name "*.jar" |grep -v sources |grep -v /build/tmp >> jar_list_4 &

wait

for line in $(cat jar_list_1 jar_list_2 jar_list_3 jar_list_4)
do
	jar=$(basename $line)
	if ! grep -q "/${jar%-*}.jar" .classpath_backup
	then
		echo -e "\t<classpathentry kind=\"lib\" path=\"$line\"/>" >> .classpath_aux
	fi
done

cat .classpath_aux | sort -u >> .classpath_new

echo "</classpath>" >> .classpath_new

rm jar_list_1 jar_list_2 jar_list_3 jar_list_4 2> /dev/null
rm .classpath_aux

mv .classpath_new .classpath

if [ ! -f .project_backup ]
then
	cp .project .project_backup
fi

grep -v 1.0-name-matches-false-false-.gradle .project_backup > .project

cd ${ORIGINAL_WORKING_DIR}


