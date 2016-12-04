---
title: Android 关于设备版本号
date: 2015-10-04 15:09:39
category: Android_note
tag: [Android_frameworks]
---

设备信息可以在Settings - About 里看到

最近想改机器的build number，找到了build/core/Makefile里的定义
```mk
# Display parameters shown under Settings -> About Phone

ifeq ($(TARGET_BUILD_VARIANT),user)
  # User builds should show:
  # release build number or branch.buld_number non-release builds

  # Dev. branches should have DISPLAY_BUILD_NUMBER set
  ifeq "true" "$(DISPLAY_BUILD_NUMBER)"
    BUILD_DISPLAY_ID := $(BUILD_ID)-$(BUILD_NUMBER) $(BUILD_KEYS)
  else
    BUILD_DISPLAY_ID := $(BUILD_ID) $(BUILD_KEYS)
  endif
else
  # Non-user builds should show detailed build information
  BUILD_DISPLAY_ID := $(build_desc)
endif
```

可看出非user版BUILD_DISPLAY_ID用的是build_desc

可以搜索到

`build_desc := $(TARGET_PRODUCT)-$(TARGET_BUILD_VARIANT) $(PLATFORM_VERSION) $(BUILD_ID) $(BUILD_NUMBER) $(BUILD_VERSION_TAGS)`

打开build/core/build_id.mk，可以修改BUILD_ID

重新编译代码即可

源码 Build.java (base/core/java/android/os)	有对这些信息的引用

想要在apk中取得的话，直接调用Build这个类即可

例如：Build.DISPLAY  返回的就是一个String

```java
    /** A build ID string meant for displaying to the user */
    public static final String DISPLAY = getString("ro.build.display.id");
```

## Build相关信息

打印出各个状态信息
```java
  Log.d(TAG, "Build.DISPLAY: " + Build.DISPLAY);
  Log.d(TAG, "Build.ID: " + Build.ID);
  Log.d(TAG, "Build.PRODUCT: " + Build.PRODUCT);
  Log.d(TAG, "Build.BOARD: " + Build.BOARD);
  Log.d(TAG, "Build.DEVICE: " + Build.DEVICE);

// Build.DISPLAY: KTU84P
// Build.ID: KTU84P
// Build.PRODUCT: gucci
// Build.BOARD: msm8916
// Build.DEVICE: gucci

```

可以从`Build`类中获取设备的相关信息；结合时间戳来用，可以作为日志文件名。
```java
private static final long TIME_7_DAYS_MM = 1000 * 60 * 60 * 24 * 7; // 7 days in millisecond

    private String timestamp() {
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd_HH-MM-SS", Locale.CHINA);
        return format.format(new Date(System.currentTimeMillis()));
    }	// 2017-12-26_11-35-14

    private void myDeviceId() {
        String id = Build.BRAND + "-" + Build.MODEL + "-" + Build.DEVICE + "-" + Build.ID;
        id = id.replace(" ", "_");
        Log.d(TAG, "id: " + id);
        String id64 = Base64.encodeToString(id.getBytes(), Base64.DEFAULT);
        byte[] decodedId64 = Base64.decode(id64, Base64.DEFAULT);
        Log.d(TAG, "id in base64: " + id64 + ", decodedId64: " + new String(decodedId64));
    }

// id: Xiaomi-HM_NOTE_1S-gucci-KTU84P
// id in base64: WGlhb21pLUhNX05PVEVfMVMtZ3VjY2ktS1RVODRQ
// , decodedId64: Xiaomi-HM_NOTE_1S-gucci-KTU84P
```

检查base64加密解密
```
$ echo Xiaomi-HM_NOTE_1S-gucci-KTU84P | base64
WGlhb21pLUhNX05PVEVfMVMtZ3VjY2ktS1RVODRQCg==

$ echo WGlhb21pLUhNX05PVEVfMVMtZ3VjY2ktS1RVODRQ | base64 -d
Xiaomi-HM_NOTE_1S-gucci-KTU84P
```
