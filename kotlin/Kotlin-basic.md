---
title: Kotlin 简介
date: 2017-06-06 23:16:04
category: Kotlin_note
toc: true
---

![](https://raw.githubusercontent.com/RustFisher/Rustnotes/master/kotlin/pics/kotlin_t1.png)

## 类与接口
### 类的集成和接口实现示例
例子展示了类的继承，方法和属性的重写，接口定义和实现，`companion object`的使用方法  
Kotlin中的类默认是不可被继承的（类似Java中的final），添加`open`关键字来允许被继承  
一个类中只允许有一个`companion object`，可以给它定一个名字

目录结构
```
`-- com
    `-- rustfisher
        |-- core
        |   |-- BaseInterface.kt
        |   `-- Vehicle.kt
        `-- kt
            `-- Client.kt
```

`BaseInterface.kt`定义接口
```kotlin
package com.rustfisher.core

interface ICannon {
    /**
     * 只有声明，在实现类中必须被重写
     */
    fun shoot()
    fun reload()

    /**
     * 已有实现，实现类中可以不重写
     */
    fun aim() {
        println("[ICannon] aim()")
    }

}
```

`Vehicle.kt`定义父类
```kotlin
package com.rustfisher.core

/**
 * 可被继承的类
 */
open class Vehicle {

    /**
     * 可被重写的属性
     */
    open val tyreCount: Int get() {
        return 4
    }

    open fun forward() {
        println("[Vehicle] forward()")
    }

    /**
     * 在这里定义一些公共方法  类似Java中的static方法
     * 一个类中只允许定义一个 companion
     */
    companion object {
        fun sum(num1: Int, num2: Int): Int {
            return num1 + num2
        }
    }
}

open class Animal {
    open fun eat() {
        println("[Animal] eat()")
    }

    fun die() {
        println("[Animal] die()")
    }
}
```

`Client.kt` 子类和测试
```kotlin
package com.rustfisher.kt

import com.rustfisher.core.Vehicle
import com.rustfisher.core.Animal
import com.rustfisher.core.ICannon

class Cat : Animal() {
    override fun eat() {
        println("[Cat] eat")
    }
}

/**
 * 步兵车
 * @param solderCount 乘坐人数
 * @param number 车辆编号
 */
class InfantryVehicle(var solderCount: Int, var number: Int) : Vehicle(), ICannon {
    var vName = "[InfantryVehicle - $number]"
    fun resetNumber(num: Int) {
        number = num
        vName = "[InfantryVehicle - $number]"
    }

    override fun reload() {
        println(vName + " reload")
    }

    /**
     * 必须重写的方法
     */
    override fun shoot() {
        println(vName + " shoot")
    }

    /**
     * 重写获取属性的方法
     */
    override val tyreCount: Int
        get() = 6 // 轮胎数量

    override fun forward() {
        println(vName + " forward")
    }

    /**
     * 可以不重写这个方法  默认使用接口中的实现
     */
    override fun aim() {
        super.aim()
        println(vName + " aim")
    }

    companion object Function {
        fun carry(name: String) {
            println("carry " + name)
        }
    }
}

fun main(args: Array<String>) {
    val v1 = InfantryVehicle(8, 65536)
    v1.reload()
    v1.aim()
    v1.shoot()
    v1.forward()
    v1.resetNumber(10086)
    v1.forward()

    println(v1.vName + " tyreCount=" + v1.tyreCount)
    InfantryVehicle.Function.carry("Boat")
    val cat = Cat()
    cat.eat()
    cat.die()

    println(Vehicle.sum(1, 3))

}


/*
[InfantryVehicle - 65536] reload
[ICannon] aim()
[InfantryVehicle - 65536] aim
[InfantryVehicle - 65536] shoot
[InfantryVehicle - 65536] forward
[InfantryVehicle - 10086] forward
[InfantryVehicle - 10086] tyreCount=6
carry Boat
[Cat] eat
[Animal] die()
4
```
