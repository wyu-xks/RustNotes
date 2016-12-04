---
title: 建造者模式 Builder Pattern
date: 2017-03-19 19:47:02
category: Design_pattern
tag: [design_pattern]
toc: true
---


## 定义
也叫作生成器模式。  
Separate the construction of a complex object from its representation 
so that the same construction process can create different representations.

## 优点
* 封装性：客户端不必知道模型内部细节
* 建造者独立，易于扩展
* 便于控制细节风险 - 可对建造者进行单独的细化

## 使用场景
* 相同的方法，不同的执行顺序，产生不同的事件结果的场景
* 产品类非常复杂，客户端需要进行多项配置

## 示例
### AOSP中的 `AlertDialog.Builder`
android-25  
AlertDialog是Android APP开发中常用的一个类。采用了Builder模式。通过builder可以对dialog进行
配置。其中dialog的各项属性可以设置默认值。
```java
public class AlertDialog extends Dialog implements DialogInterface {
    public static class Builder {
        public Builder(Context context) {}
        public Builder setTitle(CharSequence title) {}
        public Builder setMessage(@StringRes int messageId) {}
        public Builder setPositiveButton(@StringRes int textId, final OnClickListener listener) {}
        public Builder setNegativeButton(@StringRes int textId, final OnClickListener listener) {}
        public Builder setCancelable(boolean cancelable) {}
        // ..................................................
        public AlertDialog create() {} //创建dialog
        public AlertDialog show() {} // 创建并显示真正的dialog
    }
}
```

> 参考：
> 《设计模式之禅》  秦小波
> *Effective Java*
