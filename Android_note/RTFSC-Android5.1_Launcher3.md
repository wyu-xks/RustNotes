---
title: Android 源码 Launcher3
date: 2015-12-14 20:10:21
category: Android_note
tag: [Android_frameworks,RTFSC]
---
Android L

目的：探究UI

## Launcher结构：

DragLayer：与拖动相关的操作都在这个类中处理，比如app和Widget的拖动

Hotseat：最下方的那排应用的布局，不随屏幕滑动

SearchDropTargetbar：最上方的搜索栏

Workspace：中间可滑动的部分，app和widget所在的位置，位于搜索栏和Hotseat之间

PageIndicator：页面标识，那个小点点

LinearLayout（id/overview_panel)：长按屏幕进入编辑界面的视图

AppsCustomizeTabHost：显示所有app和Widget的视图

Cling：帮助视图

## 资源文件
配置文件位置： packages/apps/Trebuchet/res/xml  
里面有不同的配置文件，比如 default_workspace_4x4.xml 或者 default_workspace_5x6.xml  
xml里面可以配置APP快捷方式、Widget、Search搜索栏等。

## 源码解析

### Launcher Activity
源文件位置： packages/apps/Trebuchet/src/com/android/launcher3/Launcher.java

先看`onCreate`方法
```java
    @Override
    protected void onCreate(Bundle savedInstanceState) {
	......

        super.onCreate(savedInstanceState);

        initializeDynamicGrid();// 初始化动态网格  
        setUpBlurAppPage();// 设定模糊app页面

    ......

        setContentView(R.layout.launcher);

        setupViews();// 加载所有需要的视图；包括拖动区，hotseat，workspace，搜索栏等等
        mGrid.layout(this);

        registerContentObservers();

    ......

        updateGlobalIcons();

        // On large interfaces, we want the screen to auto-rotate based on the current orientation
        unlockScreenOrientation(true);
   ......
    }
```

### Workspace.java
源文件位置： packages/apps/Trebuchet/src/com/android/launcher3/Workspace.java

### 长按后的设置模式
长按桌面后，进入设置模式，OverviewSettingsPanel.java  
布局文件：  
packages/apps/Trebuchet/res/layout-sw720dp/launcher.xml  
packages/apps/Trebuchet/res/layout/overview_panel.xml  
packages/apps/Trebuchet/res/layout/settings_pane.xml  
屏幕最下面 SlidingUpPanelLayout

#### 设置下拉栏 - Scoll effect 相关代码
##### Scoll effect 设置界面的主要布局文件：  
packages/apps/Trebuchet/res/layout/settings_transitions_screen.xml

##### 界面文件：  
- packages/apps/Trebuchet/src/com/android/launcher3/TransitionEffectsFragment.java

```java
View v = inflater.inflate(R.layout.settings_transitions_screen, container, false);
```

- packages/apps/Trebuchet/src/com/android/launcher3/list/SettingsPinnedHeaderAdapter.java

响应点击事件：  
```java
OnClickListener mSettingsItemListener = new OnClickListener();
```
##### 点击最上方的标题栏，设置滑页动画：  
packages/apps/Trebuchet/src/com/android/launcher3/TransitionEffectsFragment.java

```java
        LinearLayout titleLayout = (LinearLayout) v.findViewById(R.id.transition_title);
        titleLayout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                setEffect();
            }
        });
        View options = v.findViewById(R.id.transition_options_menu);
        options.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                launcher.onClickTransitionEffectOverflowMenuButton(view, mIsDrawer);
            }
        });

......

    public void setEffect() {// 由 Launcher 来设置效果
        ((Launcher) getActivity()).setTransitionEffect(mIsDrawer, mCurrentState);
    }
```

##### 滑动效果预览动画代码：
packages/apps/Trebuchet/src/com/android/launcher3/TransitionEffectsFragment.java

首先取得ImageView，然后为ImageView设置背景；最后AnimationDrawable取得背景动画
```java
ImageView mTransitionIcon;
......
        mTransitionIcon = (ImageView) v.findViewById(R.id.settings_transition_image);
......
    private void setImageViewToEffect() {
        mTransitionIcon.setBackgroundResource(mTransitionDrawables
                .getResourceId(mCurrentPosition, R.drawable.transition_none));
        // transition_none.xml 是默认动画效果

        AnimationDrawable frameAnimation = (AnimationDrawable) mTransitionIcon.getBackground();
        frameAnimation.start();
    }

```
setImageViewToEffect() 放到子线程里面去启动

## 附录
Compat 兼容

下拉设置界面：  
packages/apps/Trebuchet/src/com/android/launcher3/OverviewSettingsPanel.java
