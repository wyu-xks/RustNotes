---
title: Android Fragment 加载方法
date: 2015-09-24 15:09:17
category: Android_note
tag: [Android_UI]
toc: true
---

加载方法有两种，在xml文件中注册，或者是在Java代码中加载。

## xml中注册

例如在fragment_demo.xml中定义
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical" >
    <fragment
        android:id="@+id/main_fragment_up"
        android:name="com.rust.fragment.FirstFragment"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1" />

    <fragment
        android:id="@+id/main_fragment_bottom"
        android:name="com.rust.fragment.SecondFragment"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1" />
</LinearLayout>
```
com.rust.fragment.SecondFragment 就是Fragment子类

在SecondFragment.java里复写onCreateView方法，并返回定义好的view

activity中直接加载即可

setContentView(R.layout.fragment_demo);

## Java代码中加载

①准备好Fragment xml布局文件

②新建一个类，继承自Fragment；在这个类中找到Fragment布局文件

③在Activity中使用FragmentManager来操作Fragment

④别忘了commit

先自定义一个布局文件`fragment_first.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="#0011ff" >
<!-- <Button
    android:id="@+id/btn_fragment1_1"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="@string/btn_fragment1"
    android:textSize="16sp"
       />
<EditText
    /> -->
</LinearLayout>
```


新建一个类FirstFragment.java，继承自Fragment。复写onCreateView方法。在onCreateView方法中，可以操作Fragment上的控件。
```java
    @Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.fragment_first, container,false);
//    fragment_first是自定义好的布局
//    如果此Fragment上放了控件，比如Button，Edittext等。可以在这里定义动作
  btn_fragment1_send = (Button) rootView.findViewById(R.id.btn_fragment1_1);
//...
		return rootView;
	}
```


准备一个位置给Fragment，比如在activity_main.xml中用Framelayout来占位。
```xml
    <FrameLayout
        android:id="@+id/layout_container1"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="4" >
    </FrameLayout>
```


在MainActivity.java里，先获得FragmentManager，得到FragmentTransaction。Fragment的添加删除等操作由FragmentTransaction来完成。
```java
f1 = new FirstFragment();    //    获取实例
f2 = new SecondFragment();    //
FragmentTransaction fragmentTransaction = getFragmentManager().beginTransaction();
fragmentTransaction.add(R.id.layout_container1,f1);    //    添加
fragmentTransaction.replace(R.id.layout_container1,f1);    //    替换
// 或者也可以写成
fragmentTransaction.replace(R.id.layout_container1,new FirstFragment());
//				fragmentTransaction.addToBackStack(null);	//添加到返回栈，这样按返回键的时候能返回已添加的fragment
fragmentTransaction.commit();    //别忘了commit
//    移除操作 getFragmentManager().beginTransaction().remove(f1).commit();
```

相比与xml中注册，代码加载更为灵活一些。个人较为喜欢动态加载。

## Fragment 与 Activity 之间的配合
Activity 先执行`onResume` 然后当前Fragment执行`onResume`
当前Fragment被replace掉，再次replace回来时，有些状态并未重新初始化。  
执行replace时会把Fragment的声明周期再跑一遍。稳妥的做法是，在`onCreateView`中初始化必要
的变量。比如重置一些状态值。在多个Fragment中切换时需要特别注意。
