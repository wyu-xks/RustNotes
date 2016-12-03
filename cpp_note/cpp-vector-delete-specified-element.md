---
title: C++ vector iterator 删除符合条件的元素
date: 2016-07-11 21:36:20
category: Cpp_note
tag: [C++,vector]
toc: true
---

#### 删除特定元素
使用erase方法删除元素后，要避免iterator失效。
将erase方法返回值赋给iterator。

代码中的注释`avoid markdown error`为了消除markdown渲染错误

```cpp
#include <iostream>
#include <string>
#include <vector>

using std::cout;
using std::vector;
using std::endl;

/**
* In order to find a solution to delete specified element.
*/
int main() {
    vector<int> intVec;
    intVec.push_back(3);
    intVec.push_back(2);
    for (int i = 0; i < 3; i++) {
        intVec.push_back(3);
        intVec.push_back(3);
        intVec.push_back(1);
        intVec.push_back(3);
    }
    vector<int>::iterator it_int;
    cout << "Origin int vector: " ;
    for(it_int = intVec.begin(); it_int != intVec.end(); it_int++) {
        cout << *it_int << " ";// avoid markdown error*
    }
    cout << "\nDelete the \"3\""<< endl;
    for(it_int = intVec.begin(); it_int != intVec.end(); ) {
        if(*it_int == 3) {// avoid markdown error*
            it_int = intVec.erase(it_int);// Reload here
        } else {
            it_int++;
        }
    }
    cout << "After deletion:    " ;
    for(it_int = intVec.begin(); it_int != intVec.end(); it_int++) {
        cout << *it_int << " ";// avoid markdown error*
    }
    return 0;
}
```
Output
```
Origin int vector: 3 2 3 3 1 3 3 3 1 3 3 3 1 3
Delete the "3"
After deletion:    2 1 1 1
```

#### 删除连续的元素，但保留连续元素中的第一个

以Person类为例子，删除vector中连续的相同岁数的元素  
删除后iterator失效。要回到vector起点，重新遍历。此法效率不是很高。
```cpp
// Person.h
#include <string>

using std::string;

class Person {
    private:
        int age;
        string name;
    public:
        Person(int a, string n) {
            age = a;
            name = n;
        }

        void setAge(int a) {
            age = a;
        }

        void setName(string n) {
            name = n;
        }

        int getAge() {
            return age;
        }

        string getName() {
            return name;
        }
};
```


```cpp
#include <iostream>
#include <string>
#include <vector>
#include "Person.h"

using std::cout;
using std::string;
using std::vector;
using std::endl;

/**
* In order to find a solution to delete continual element.
*/
int main() {
    // Person exsample
    vector<Person> personVec;
    vector<Person>::iterator it_person;
    Person a(27,"Jack");
    Person b(34,"Joy");
    Person c(34,"Alex");
    Person d(34,"Cat");
    personVec.push_back(a);
    personVec.push_back(c);
    personVec.push_back(b);
    personVec.push_back(d);
    cout << "\nOrigin person vector:" << endl;
    for(it_person = personVec.begin(); it_person != personVec.end(); it_person++) {
        Person person = *it_person;// avoid markdown error*
        cout << person.getName() << "\tage:" << person.getAge() << endl;
    }

    cout << "\nDelete the continual age 32 person but leave the first one"<< endl;
    if(personVec.size() == 2) {
        it_person = personVec.begin();
        Person pre = *(it_person);
        Person cur = *(it_person + 1);// avoid markdown error*
        if(pre.getAge() == cur.getAge()) {
            personVec.erase(it_person + 1);
        }
    } else if(personVec.size() > 2) {
        for(it_person = personVec.begin() + 1; it_person != personVec.end() && personVec.size() > 2; it_person++) {
            Person pre = *(it_person - 1);
            Person cur = *it_person;// avoid markdown error*
            if(pre.getAge() == cur.getAge()) {
                personVec.erase(it_person);
                it_person = personVec.begin();// Back to the beginning
            }
        }
        if(personVec.size() == 2) {
            it_person = personVec.begin();
            Person pre = *(it_person);
            Person cur = *(it_person + 1);// avoid markdown error*
            if(pre.getAge() == cur.getAge()) {
                personVec.erase(it_person + 1);
            }
        }
    }

    cout << "\nAfter deletion "<< endl << "Person vector:" << endl;
    for(it_person = personVec.begin(); it_person != personVec.end(); it_person++) {
        Person person = *it_person;// avoid markdown error*
        cout << person.getName() << "\tage:" << person.getAge() << endl;
    }
    // The problem is efficiency

    return 0;
}
```
输出结果：
```
Origin person vector:
Jack    age:27
Alex    age:34
Joy     age:34
Cat     age:34

Delete the continual age 32 person but leave the first one

After deletion
Person vector:
Jack    age:27
Alex    age:34
```
