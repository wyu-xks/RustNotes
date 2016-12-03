#! /bin/sh
# 提取apk库文件名，整理成mk文件需要的形式
# 2015-11-25 14:51:07
sed -i 's/.so/.so\n/g' $1 #.so后面加上换行
sed -i 's/lib/\nlib/g' $1 #lib前面也换行
sed -i '/^$/d' $1 #删除空行
sed -i '/ /d' $1 #删除有空格的行
sed -i 's/lib/@\/lib\/armeabi\/lib/g' $1 #lib -> @\lib\
sed -i 's/.so/.so\ \\/g' $1 #.so后面加上空格和'\'，即 .so -> .so \
sed -i 's/@\/lib/    @lib/g' $1 #@\lib\去掉左边的反斜杠，并在@前加上4个空格
