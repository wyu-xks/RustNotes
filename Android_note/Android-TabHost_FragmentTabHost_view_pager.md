---
title: Android TabHost/FragmentTabHost 与 Fragment 制作页面切换效果
date: 2016-03-20 15:10:07
category: Android_note
tag: [Android_UI]
---
Android API 19 ， API 23
Create：2016-03-07

[TOC]

## 使用 TabHost 三个标签页置于顶端
效果图：
![](https://raw.githubusercontent.com/RustFisher/imagesRaw/master/demo_images/tab1.png) ![](https://raw.githubusercontent.com/RustFisher/imagesRaw/master/demo_images/tab2_tab3.png)

在文件`BoardTabHost.java`中定义页面切换的效果；切换页面时，当前页面滑出，目标页面滑入。这是2个不同的动画
设定动画时要区分对待
```java

import android.content.Context;
import android.util.AttributeSet;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.widget.TabHost;

public class BoardTabHost extends TabHost {

    private int currentTab = 0;
    int duration = 1000;// ms; the bigger the slower

    public BoardTabHost(Context context) {
        super(context);
    }

    public BoardTabHost(Context context, AttributeSet attr) {
        super(context, attr);
    }

    @Override
    public void setCurrentTab(int index) {
        // we need two animation here: first one is fading animation, 2nd one is coming animation
        // translateAnimation of fading fragment
        if (index > currentTab) {// fly right to left and leave the screen
            TranslateAnimation translateAnimation = new TranslateAnimation(
                    Animation.RELATIVE_TO_SELF/* fromXType */, 0f/* fromXValue */,
                    Animation.RELATIVE_TO_SELF/* toXType */, -1.0f/* toXValue */,
                    Animation.RELATIVE_TO_SELF, 0f,
                    Animation.RELATIVE_TO_SELF, 0f
            );
            translateAnimation.setDuration(duration);
            getCurrentView().startAnimation(translateAnimation);
        } else if (index < currentTab) {// fly left to right
            TranslateAnimation translateAnimation = new TranslateAnimation(
                    Animation.RELATIVE_TO_SELF, 0f,
                    Animation.RELATIVE_TO_SELF, 1.0f,
                    Animation.RELATIVE_TO_SELF, 0f,
                    Animation.RELATIVE_TO_SELF, 0f
            );
            translateAnimation.setDuration(duration);
            getCurrentView().startAnimation(translateAnimation);
        }
        super.setCurrentTab(index);// the current tab is index now
        // translateAnimation of adding fragment
        if (index > currentTab) {
            TranslateAnimation translateAnimation = new TranslateAnimation(
                    Animation.RELATIVE_TO_PARENT, 1.0f,/* fly into screen */
                    Animation.RELATIVE_TO_PARENT, 0f,  /* screen location */
                    Animation.RELATIVE_TO_PARENT, 0f,
                    Animation.RELATIVE_TO_PARENT, 0f
            );
            translateAnimation.setDuration(duration);
            getCurrentView().startAnimation(translateAnimation);
        } else if (index < currentTab) {
            TranslateAnimation translateAnimation = new TranslateAnimation(
                    Animation.RELATIVE_TO_PARENT, -1.0f,
                    Animation.RELATIVE_TO_PARENT, 0f,
                    Animation.RELATIVE_TO_PARENT, 0f,
                    Animation.RELATIVE_TO_PARENT, 0f
            );
            translateAnimation.setDuration(duration);
            getCurrentView().startAnimation(translateAnimation);
        }
        currentTab = index;
    }
}
```
对应的布局文件`activity_board.xml`
使用BoardTabHost，装载一个竖直的LinearLayout；上面是TabWidget，装载标签；后面是fragment的FrameLayout
可以看到这里有3个fragment，待会在activity中也设置3个标签
```xml
<?xml version="1.0" encoding="utf-8"?>
<com.rust.tabhostdemo.BoardTabHost
    android:id="@android:id/tabhost"
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context="com.rust.tabhostdemo.BoardActivity">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical">

        <TabWidget
            android:id="@android:id/tabs"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"/>

        <FrameLayout
            android:id="@android:id/tabcontent"
            android:layout_width="match_parent"
            android:layout_height="match_parent">

            <fragment
                android:id="@+id/fragment_tab1"
                android:name="com.rust.tabhostdemo.TabFragment1"
                android:layout_width="match_parent"
                android:layout_height="match_parent"/>

            <fragment
                android:id="@+id/fragment_tab2"
                android:name="com.rust.tabhostdemo.TabFragment2"
                android:layout_width="match_parent"
                android:layout_height="match_parent"/>

            <fragment
                android:id="@+id/fragment_tab3"
                android:name="com.rust.tabhostdemo.TabFragment3"
                android:layout_width="match_parent"
                android:layout_height="match_parent"/>

        </FrameLayout>
    </LinearLayout>
</com.rust.tabhostdemo.BoardTabHost>
```
值得一提的是，这里的id要用android指定的id；
比如`@android:id/tabhost`，`@android:id/tabcontent`，`@android:id/tabs`；否则系统找不到对应控件而报错

`BoardActivity.java`中设置了3个标签页，并指定了标签对应的fragment
```java
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;

public class BoardActivity extends FragmentActivity {

    public static final String TAB1 = "tab1";
    public static final String TAB2 = "tab2";
    public static final String TAB3 = "tab3";

    public static BoardTabHost boardTabHost;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_board);

        boardTabHost = (BoardTabHost) findViewById(android.R.id.tabhost);
        boardTabHost.setup();

        boardTabHost.addTab(boardTabHost.newTabSpec(TAB1).setIndicator(getString(R.string.tab1_name))
                .setContent(R.id.fragment_tab1));
        boardTabHost.addTab(boardTabHost.newTabSpec(TAB2).setIndicator(getString(R.string.tab2_name))
                .setContent(R.id.fragment_tab2));
        boardTabHost.addTab(boardTabHost.newTabSpec(TAB3).setIndicator(getString(R.string.tab3_name))
                .setContent(R.id.fragment_tab3));

        boardTabHost.setCurrentTab(0);

    }
}
```

主要文件目录：
```
── layout
   ├── activity_board.xml
   ├── fragment_tab1.xml
   ├── fragment_tab2.xml
   └── fragment_tab3.xml

── tabhostdemo
   ├── BoardActivity.java
   ├── BoardTabHost.java
   ├── TabFragment1.java
   ├── TabFragment2.java
   └── TabFragment3.java
```

## 使用 FragmentTabHost 与 Fragment 制作页面切换效果
API 19

效果图：
![](https://raw.githubusercontent.com/RustFisher/imagesRaw/master/demo_images/f_tab1.png) ![](https://raw.githubusercontent.com/RustFisher/imagesRaw/master/demo_images/f_tab2.png)

主文件是`FragmentTabHostDemo.java`
* 继承自FragmentActivity；
* 设置3个底部标签，自定义了标签切换时的标签变化；
* 添加标签页有多种方式，每个标签页对应一个fragment
* 每次切换fragment，都会调用fragment的`onCreateView()`和`onResume()`方法；
* v4包使用`getSupportFragmentManager()`；
* 动态加载fragment，不用在xml中注册；
* 其他的大体和TabHost一样；比如xml文件中的id要用android指定的id；

```java
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTabHost;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TabHost;
import android.widget.TextView;

import com.rust.aboutview.fragment.TabFragment1;
import com.rust.aboutview.fragment.TabFragment2;
import com.rust.aboutview.fragment.TabFragment3;

import java.util.HashMap;

public class FragmentTabHostDemo extends FragmentActivity {

    public static final int COLOR_GRAY_01 = 0xFFADADAD; //自定义的颜色
    public static final int COLOR_GREEN_01 = 0xFF73BF00;

    public static final String TAB1 = "tab1";
    public static final String TAB2 = "tab2";
    public static final String TAB3 = "tab3";
    public static final String TABS[] = {TAB1, TAB2, TAB3};

    public static HashMap<String, Integer> mTabMap;
    public static FragmentTabHost mTabHost;
    LayoutInflater mLayoutInflater;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_fragment_tab_host);
        mTabMap = new HashMap<>();
        mTabMap.put(TAB1, 0);
        mTabMap.put(TAB2, 1);
        mTabMap.put(TAB3, 2);
        mLayoutInflater = LayoutInflater.from(getApplicationContext());

        mTabHost = (FragmentTabHost) findViewById(android.R.id.tabhost);
        mTabHost.setup(this, getSupportFragmentManager(), R.id.realtabcontent);
        mTabHost.getTabWidget().setMinimumHeight(120);// 设置tab的高度
        mTabHost.getTabWidget().setDividerDrawable(null);

        TabHost.TabSpec tabSpec = mTabHost.newTabSpec(TABS[0]);
        View tabView1 = mLayoutInflater.inflate(R.layout.tab_item, null);
        final ImageView tabImage1 = (ImageView) tabView1.findViewById(R.id.tab_image);
        final TextView tabText1 = (TextView) tabView1.findViewById(R.id.tab_text);
        tabImage1.setImageResource(R.drawable.a4a);
        tabText1.setText(getString(R.string.tab_label_1));
        tabText1.setTextColor(COLOR_GREEN_01);

        tabSpec.setIndicator(tabView1);
        mTabHost.addTab(tabSpec, TabFragment1.class, null);

        View tabView2 = mLayoutInflater.inflate(R.layout.tab_item, null);
        final ImageView tabImage2 = (ImageView) tabView2.findViewById(R.id.tab_image);
        tabImage2.setImageResource(R.drawable.a49);
        final TextView tabText2 = (TextView) tabView2.findViewById(R.id.tab_text);
        tabText2.setText(getString(R.string.tab_label_2));

        mTabHost.addTab(mTabHost.newTabSpec(TABS[1]).setIndicator(tabView2),
                TabFragment2.class, null);

        View tabView3 = mLayoutInflater.inflate(R.layout.tab_item, null);
        final ImageView tabImage3 = (ImageView) tabView3.findViewById(R.id.tab_image);
        tabImage3.setImageResource(R.drawable.a49);
        final TextView tabText3 = (TextView) tabView3.findViewById(R.id.tab_text);
        tabText3.setText(getString(R.string.tab_label_3));

        mTabHost.addTab(mTabHost.newTabSpec(TABS[2])
                .setIndicator(tabView3), TabFragment3.class, null);

        mTabHost.setCurrentTab(0);

        mTabHost.setOnTabChangedListener(new TabHost.OnTabChangeListener() {
            @Override
            public void onTabChanged(String tabId) {
                int child = mTabMap.get(tabId);
                tabImage1.setImageResource(R.drawable.a49);
                tabImage2.setImageResource(R.drawable.a49);
                tabImage3.setImageResource(R.drawable.a49);
                tabText1.setTextColor(COLOR_GRAY_01);
                tabText2.setTextColor(COLOR_GRAY_01);
                tabText3.setTextColor(COLOR_GRAY_01);
                switch (child) {
                    case 0:
                        tabImage1.setImageResource(R.drawable.a4a);
                        tabText1.setTextColor(COLOR_GREEN_01);
                        break;
                    case 1:
                        tabImage2.setImageResource(R.drawable.a4a);
                        tabText2.setTextColor(COLOR_GREEN_01);
                        break;
                    case 2:
                        tabImage3.setImageResource(R.drawable.a4a);
                        tabText3.setTextColor(COLOR_GREEN_01);
                        break;
                }
            }
        });

    }
}

```

`activity_fragment_tab_host.xml`，使用FragmentTabHost；
标签放在页面底部；注意这里的id，以及layout的宽高设置
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
              android:layout_width="fill_parent"
              android:layout_height="fill_parent"
              android:orientation="vertical" >

    <FrameLayout
        android:id="@+id/realtabcontent"
        android:layout_width="fill_parent"
        android:layout_height="0dip"
        android:layout_weight="1" />

    <android.support.v4.app.FragmentTabHost
        android:id="@android:id/tabhost"
        android:layout_width="fill_parent"
        android:layout_height="wrap_content"
        android:background="@color/colorYellow01">

        <FrameLayout
            android:id="@android:id/tabcontent"
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_weight="0" />
    </android.support.v4.app.FragmentTabHost>

</LinearLayout>
```

因为切换标签时会重载fragment，可以在fragment中判断一下，已经加载过的，不需要重新加载；

`TabFragment1.java` 中定义了一个rootView
```java
public class TabFragment1 extends Fragment {

    private View rootView;// cache fragment view
    TextView centerTV;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        Log.d("rust", "TabFragment1 onCreateView");
        if (rootView == null) {
            rootView = inflater.inflate(R.layout.fragment_tab1, null);
        }
        ViewGroup parent = (ViewGroup) rootView.getParent();
        // if root view had a parent, remove it.
        if (parent != null) {
            parent.removeView(rootView);
        }
        centerTV = (TextView) rootView.findViewById(R.id.center_tv);
        centerTV.setOnClickListener(new View.OnClickListener() {
            // @Override
            public void onClick(View v) {
                centerTV.setText(String.format("%s","Tab1 clicked"));
                centerTV.setTextColor(Color.BLACK);
            }
        });
        return rootView;
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d("rust", "TabFragment1 onResume");
    }
}
```
已点击的效果图：
![](https://raw.githubusercontent.com/RustFisher/imagesRaw/master/demo_images/f_tab1_c.png)
