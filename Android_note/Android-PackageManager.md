---
title: Android PackageManager
date: 2016-03-14 15:10:04
category: Android_note
tag: [Android_note]
---
## ResolveInfo 获取app个数，名称
```java
    /*************************************************
     * 获取 resolveInfo list
     * 即获取 launcher 上的app
     *************************************************/
    PackageManager packageManager = getPackageManager();
    Intent intent = new Intent(Intent.ACTION_MAIN, null);

    intent.addCategory(Intent.CATEGORY_LAUNCHER);

    List<ResolveInfo> appList = packageManager.queryIntentActivities(intent, 0);
```
获取结果：
```log
ResolveInfo{e5e3bad com.android.contacts/.activities.PeopleActivity m=0x108000}
ResolveInfo{291c4ee2 com.android.dialer/.DialtactsActivity m=0x108000}
ResolveInfo{5e2a273 com.android.mms/.ui.ConversationList m=0x108000}
ResolveInfo{26f06530 com.android.settings/.Settings m=0x108000}
ResolveInfo{64fe5a9 cn.kuwo.player/.activities.EntryActivity m=0x108000}
```
