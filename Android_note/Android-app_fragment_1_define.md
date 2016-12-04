---
title: Android Fragment 基础概念
date: 2015-09-25 15:09:16
category: Android_note
tag: [Android_UI]
---

## 什么是Fragment
Fragment，直译为碎片，片段。Fragment 表示 Activity 中的行为或用户界面部分。您可以将多个片段组合在一个 Activity 中来构建多窗格 UI，以及在多个 Activity 中重复使用某个片段。您可以将片段视为 Activity 的模块化组成部分，它具有自己的生命周期，能接收自己的输入事件，并且您可以在 Activity 运行时添加或移除片段（有点像您可以在不同 Activity 中重复使用的“子 Activity”）。  
Fragment必须始终嵌入在 Activity 中，Fragment有自己的生命周期。其生命周期直接受宿主 Activity 生命周期的影响。  

### 为什么要用Fragment？
* Fragment加载灵活，替换方便。定制你的UI，在不同尺寸的屏幕上创建合适的UI，提高用户体验。
* 可复用，页面布局可以使用多个Fragment，不同的控件和内容可以分布在不同的Fragment上。
* 使用Fragment，可以少用一些Activity。一个Activity可以管辖多个Fragment。

## 创建Fragment
继承 Fragment（或其子类）。Fragment 类的代码与 Activity 非常相似。它包含与 Activity 类似的回调方法，如 onCreate()、onStart()、onPause() 和 onStop()。

至少复写以下几个方法：

onCreate()  
系统会在创建片段时调用此方法。您应该在实现内初始化您想在片段暂停或停止后恢复时保留的必需片段组件。

onCreateView()  
系统会在片段首次绘制其用户界面时调用此方法。 要想为您的片段绘制 UI，您从此方法中返回的 View 必须是片段布局的根视图。如果片段未提供 UI，您可以返回 null。

onPause()  
系统将此方法作为用户离开片段的第一个信号（但并不总是意味着此片段会被销毁）进行调用。 您通常应该在此方法内确认在当前用户会话结束后仍然有效的任何更改（因为用户可能不会返回）。

### 用于特定场景的几种Fragment的子类

`DialogFragment`  
显示浮动对话框。使用此类创建对话框可有效地替代使用 Activity 类中的对话框帮助程序方法，因为您可以将片段对话框纳入由 Activity 管理的片段返回栈，从而使用户能够返回清除的片段。

`ListFragment`  
显示由适配器（如 SimpleCursorAdapter）管理的一系列项目，类似于 ListActivity。它提供了几种管理列表视图的方法，如用于处理点击事件的 onListItemClick() 回调。

`PreferenceFragment`  
以列表形式显示 Preference 对象的层次结构，类似于 PreferenceActivity。这在为您的应用创建“设置” Activity 时很有用处。

### Fragment添加用户界面
 复写`onCreateView()`方法，Android 系统会在片段需要绘制其布局时调用该方法。此方法返回的 View 必须是片段布局的根视图。

例如，以下这个 Fragment 子类从 example_fragment.xml 文件加载布局：
```java
public static class ExampleFragment extends Fragment {
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.example_fragment, container, false);
    }
}
```
inflate() 方法带有三个参数：

* 您想要扩展的布局的资源 ID；
* 将作为扩展布局父项的 ViewGroup。传递 container 对系统向扩展布局的根视图（由其所属的父视图指定）应用布局参数具有重要意义；
* 指示是否应该在扩展期间将扩展布局附加至 ViewGroup（第二个参数）的布尔值。（在本例中，其值为 false，因为系统已经将扩展布局插入 container — 传递 true 值会在最终布局中创建一个多余的视图组。）
