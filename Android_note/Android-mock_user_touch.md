---
title: Android 模拟用户点击
date: 2018-02-05 20:56:57
category: Android_note
---

Android模拟用户点击。在自动化测试中可使用的工具。
可以利用adb命令，也可以使用Android SDK中的`monkeyrunner`工具。

* win7-64
* gitbash

### 使用adb命令
主要使用input命令
```
usage: input ...

       input text <string>
       input keyevent <key code number or name>
       input tap <x> <y>
       input swipe <x1> <y1> <x2> <y2>
```
keyevent指的是android对应的keycode，比如home键的keycode=3，back键的keycode=4

tap是touch屏幕的事件，只需给出x、y坐标即可

swipe模拟滑动的事件，给出起点和终点的坐标即可

```
# 模拟点击位置 (100,100)
adb shell input tap 100 100

# 模拟滑动 从(650, 250)到(200,300)
adb shell input swipe 650 250 200 300
```

编写一个bat脚本，模拟用户滑动
```
@echo off
echo --------- Mock start ----------

:tag_start
echo running...
adb shell input swipe 650 250 200 666
@ping 127.0.0.1 -n 8 >nul
goto tag_start

echo --------- Mock finish ---------
pause
```
死循环发送滑动命令，延时语句`@ping 127.0.0.1 -n 8 >nul`

### monkeyrunner
环境配置，配置好Java与Android SDK的环境变量。手机连接到电脑。
系统变量中加入`ANDROID_SWT`，此例中路径为`G:\SDK\tools\lib\x86_64`

修改后的脚本`rustmonkeyrunner.bat`，Windows环境下需要在gitbash或CMD里运行

来自[unable-to-access-jarfile-framework-monkeyrunner-25-3-2-jar](https://stackoverflow.com/questions/44666939/unable-to-access-jarfile-framework-monkeyrunner-25-3-2-jar)
```
@echo off
rem Copyright (C) 2010 The Android Open Source Project
rem
rem Licensed under the Apache License, Version 2.0 (the "License");
rem you may not use this file except in compliance with the License.
rem You may obtain a copy of the License at
rem
rem      http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing, software
rem distributed under the License is distributed on an "AS IS" BASIS,
rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem See the License for the specific language governing permissions and
rem limitations under the License.

rem don't modify the caller's environment
setlocal

rem Set up prog to be the path of this script, including following symlinks,
rem and set up progdir to be the fully-qualified pathname of its directory.
set prog=%~f0

rem Change current directory and drive to where the script is, to avoid
rem issues with directories containing whitespaces.
cd /d %~dp0

rem Check we have a valid Java.exe in the path.
set java_exe=
call ..\lib\find_java.bat
if not defined java_exe goto :EOF
for /f %%a in ("%APP_HOME%\lib\monkeyrunner-25.3.2.jar") do set jarfile=%%~nxa
set frameworkdir=.
set libdir=

if exist %frameworkdir%\%jarfile% goto JarFileOk
    set frameworkdir=..\lib

if exist %frameworkdir%\%jarfile% goto JarFileOk
    set frameworkdir=..\framework

:JarFileOk

set jarpath=%frameworkdir%\%jarfile%

if not defined ANDROID_SWT goto QueryArch
    set swt_path=%ANDROID_SWT%
    goto SwtDone

:QueryArch

    for /f "delims=" %%a in ('%frameworkdir%\..\bin\archquery') do set swt_path=%frameworkdir%\%%a

:SwtDone

if exist "%swt_path%" goto SetPath
    echo SWT folder '%swt_path%' does not exist.
    echo Please set ANDROID_SWT to point to the folder containing swt.jar for your platform.
    exit /B

:SetPath

call "%java_exe%" -Xmx512m "-Djava.ext.dirs=%frameworkdir%;%swt_path%" -Dcom.android.monkeyrunner.bindir=..\..\platform-tools -jar %jarpath% %*
```

运行脚本
```
Administrator@rust-PC ~
$ /cygdrive/g/SDK/tools/bin/rustmonkeyrunner.bat
Jython 2.5.3 (2.5:c56500f08d34+, Aug 13 2012, 14:54:35)
[Java HotSpot(TM) 64-Bit Server VM (Oracle Corporation)] on java1.8.0_77
```

首次运行时import模块迟迟没有反应
```
>>> from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice, MonkeyImage
```
尝试运行脚本`an_test2.py`

```python
import os

print("importing module...")
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice, MonkeyImage

print("waiting for connection...")
device = MonkeyRunner.waitForConnection()
print("device found!")

s_wid = int(device.getProperty("display.width"))     # 获取屏幕宽度像素
s_height = int(device.getProperty("display.height")) # 获取屏幕高度像素

print("build.version.sdk " + str(device.getProperty("build.version.sdk")))
print("display.width     " + str(s_wid))
print("display.height    " + str(s_height))

drag_point_left_x = 20
drag_point_right_x = s_wid - 20
drag_point_y = s_height / 2

for i in range(0, 10):
    print("current loop is " + str(i))
    device.drag((drag_point_right_x, drag_point_y), (drag_point_left_x, drag_point_y), 1.0, 50)
    print("waiting...")
    MonkeyRunner.sleep(1)
    print("continue")
    device.drag((drag_point_left_x, drag_point_y), (drag_point_right_x, drag_point_y), 0.5, 3)
    MonkeyRunner.sleep(3)

print("-------- finish --------")
```

命令行直接执行，可以看到执行结果和相应的报错信息
```
C:\Users\Administrator>G:\SDK\tools\bin\rustmonkeyrunner.bat H:\fisher_p\py_ws\an_test2.py
importing module...
waiting for connection...
device found!
build.version.sdk 23
display.width     1440
display.height    2560
current loop is 0
waiting...
continue
current loop is 1
# .....
-------- finish --------
```
测试中发现，脚本可以运行在系统app。若当前打开的是第三方app，会直接报错，获取不到相应信息

### 参考
* [monkeyrunner 获取系统信息](https://stackoverflow.com/questions/15935622/getproperty-getsystemproperty-in-monkeyrunner-return-none)
* [Android MonkeyDevice - Google](https://developer.android.com/studio/test/monkeyrunner/MonkeyDevice.html)
