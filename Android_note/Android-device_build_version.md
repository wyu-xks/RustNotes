---
title: Android 关于设备版本号
date: 2015-10-04 15:09:39
category: Android_note
tag: [Android_frameworks]
---
设备信息可以在Settings - About 里看到

最近想改机器的build number，找到了build/core/Makefile里的定义
```
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

弄一个界面show_info.xml，显示当前版本的信息。界面里放着很多TextView。

MainActivity.java 如下。取出各个状态信息
```java
public class MainActivity extends Activity {

	private TextView buildTextView;
	private TextView idTextView;
	private TextView productTextView;
	private TextView boardTextView;
	private TextView deviceTextView;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.show_info);
		buildTextView = (TextView) findViewById(R.id.build_number);
		idTextView = (TextView) findViewById(R.id.build_id);
		productTextView= (TextView) findViewById(R.id.product);
		boardTextView= (TextView) findViewById(R.id.board);
		deviceTextView= (TextView) findViewById(R.id.device);

		buildTextView.setText(Build.DISPLAY);
		idTextView.setText(Build.ID);
		productTextView.setText(Build.PRODUCT);
		boardTextView.setText(Build.BOARD);
		deviceTextView.setText(Build.DEVICE);

	}

}
```

装上后，在机器上可以看到相关信息
