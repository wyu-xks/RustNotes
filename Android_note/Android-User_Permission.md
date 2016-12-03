---
title: Android 自定义 permission
date: 2015-08-02 11:10:11
category: Android_note
tag: [Android]
---
Android 添加自定义权限

* permission-tree 权限的根节点，3个成员都要定义
  name 一般来说需要2个“.”；比如下面的"rust.permission.user"；  
  否则报错`INSTALL_PARSE_FAILED_MANIFEST_MALFORMED`  
  icon 和 label 正常添加即可

* permission 权限声明，定义权限组、等级等信息

* uses-permission 使用权限

```xml
    <!-- user define permission
         permission tree and permission -->
    <permission-tree
        android:name="rust.permission.user"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name" />
    <permission
        android:name="rust.permission.user.TEST"
        android:label="@string/app_name"
        android:permissionGroup="@string/action_settings"
        android:protectionLevel="normal" />

    <!-- use user permission -->
    <uses-permission android:name="rust.permission.user.TEST" />
```
代码中检查是否申请了权限  
使用PackageManager的方法来检查
```java
    private static final String TestPermission = "rust.permission.user.TEST";
    ......
    checkUserPermission(getApplicationContext(), TestPermission);
    ......

    /**
     * check permission
     *
     * @param context - the application context
     */
    private void checkUserPermission(Context context, String permissionName) {
        PackageManager pm = getPackageManager();
        boolean permitTest = (PackageManager.PERMISSION_GRANTED ==
                pm.checkPermission(permissionName, getPackageName()));
        Toast.makeText(context, permitTest ? "Test YES!" : "Test NO!", Toast.LENGTH_SHORT)
                .show();
    }
```
