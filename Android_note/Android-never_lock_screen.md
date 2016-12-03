---
title: Android 永不锁屏，开机不锁屏，删除设置中休眠时间选项
date: 2015-11-04 15:10:02
category: Android_note
tag: [Android_frameworks]
---
Android 6.0.1

#### 1.Settings 删掉屏幕待机选项
packages/apps/Settings/res/xml/display_settings.xml
```xml
     <!-- Hide screen sleep
     <ListPreference
             android:key="screen_timeout"
             android:title="@string/screen_timeout"
             android:summary="@string/screen_timeout_summary"
             android:persistent="false"
             android:entries="@array/screen_timeout_entries"
             android:entryValues="@array/screen_timeout_values" /> -->
```
注释掉这个ListPreference

packages/apps/Settings/src/com/android/settings/DisplaySettings.java
添加if条件，如果没有找到这个preference就不执行相关操作；具体可以参考被隐藏的 night_mode
```java
        mScreenTimeoutPreference = (ListPreference) findPreference(KEY_SCREEN_TIMEOUT);
        if (mScreenTimeoutPreference !=null ) {
            final long currentTimeout = Settings.System.getLong(resolver, SCREEN_OFF_TIMEOUT,
                    FALLBACK_SCREEN_TIMEOUT_VALUE);
            mScreenTimeoutPreference.setValue(String.valueOf(currentTimeout));
            mScreenTimeoutPreference.setOnPreferenceChangeListener(this);
            disableUnusableTimeouts(mScreenTimeoutPreference);
            updateTimeoutPreferenceDescription(currentTimeout);
        }
```

#### 2.禁止锁屏
frameworks/base/packages/SettingsProvider/res/values/defaults.xml
`<bool name="def_lockscreen_disabled">false</bool>` 改为 true；即默认禁止锁屏

frameworks/base/core/res/res/values/config.xml
`<integer name="config_multiuserMaximumUsers">1</integer>` 不允许多用户；即最大用户数为1

分别编译frameworks/base/packages/SettingsProvider 与 frameworks/base
编译后push 到 system/priv-app/SettingsProvider/SettingsProvider.apk system/framework/framework.jar
删去机器中对应的oat目录。重启或恢复出厂设置。第一次开机时，会先出现status bar，launcher要等一会才出来。
之后重启就可以直接进入launcher。机器会默认不锁屏。但还是会进入sleep状态。


------

#### 源码流程：
frameworks/base/packages/SettingsProvider/src/com/android/providers/settings/DatabaseHelper.java
```java
if (upgradeVersion == 54)// 版本为54才会设置timeout
......
    private void upgradeScreenTimeoutFromNever(SQLiteDatabase db) {
        // See if the timeout is -1 (for "Never").
        Cursor c = db.query(TABLE_SYSTEM, new String[] { "_id", "value" }, "name=? AND value=?",
                new String[] { Settings.System.SCREEN_OFF_TIMEOUT, "-1" },
                null, null, null);

        SQLiteStatement stmt = null;
        if (c.getCount() > 0) {
            c.close();
            try {
                stmt = db.compileStatement("INSERT OR REPLACE INTO system(name,value)"
                        + " VALUES(?,?);");

                // Set the timeout to 30 minutes in milliseconds
                loadSetting(stmt, Settings.System.SCREEN_OFF_TIMEOUT,
                        Integer.toString(30 * 60 * 1000));
            } finally {
                if (stmt != null) stmt.close();
            }
        } else {
            c.close();
        }
    }
    ......
            if (SystemProperties.getBoolean("ro.lockscreen.disable.default", false) == true) {
                loadSetting(stmt, Settings.System.LOCKSCREEN_DISABLED, "1");
            } else {
                loadBooleanSetting(stmt, Settings.System.LOCKSCREEN_DISABLED,
                        R.bool.def_lockscreen_disabled);
            }
```
timeout若是-1，则永不锁屏
读取"ro.lockscreen.disable.default"，如果默认为true，则设置禁止锁屏；否则从xml中读配置

frameworks/base/packages/SettingsProvider/res/values/defaults.xml
```xml
    <integer name="def_screen_off_timeout">60000</integer>

    <bool name="def_lockscreen_disabled">false</bool>`
```
禁止锁屏默认为false
