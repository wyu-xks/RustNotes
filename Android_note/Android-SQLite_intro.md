---
title: Android SQLite
date: 2016-03-18 15:10:06
category: Android_note
tag: [Android_Storage]
toc: true
---

Android中的轻量级关系型数据库。

## SQLite操作
### SQLiteOpenHelper是一个抽象类。创建一个帮助类去继承它。

在新的帮助类里重写onCreate()和onUpgrade()两个方法。在这两个方法中去实现创建、升级数据库的逻辑。

例如：
```java
import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class RustDatabaseHelper extends SQLiteOpenHelper {

    public static final int DATABASE_VERSION = 1;
    public static final String DATABASE_NAME = "data.db";// 数据库名称

    public interface Tables {
        String CONTACT_TABLE = "contact";// 表名，一般定好了就不动了
    }
    // 存放各种属性
    public interface Contact {
        String _ID = "contact_id";
        String NAME = "name";
        String PHONE = "phone";
        String EMAIL = "email";
    }

    public RustDatabaseHelper(Context context, String name,
                              SQLiteDatabase.CursorFactory factory, int version) {
        super(context, name, factory, version);
    }
    // 建立数据库
    @Override
    public void onCreate(SQLiteDatabase db) {
        String cmd = "CREATE TABLE IF NOT EXISTS " + Tables.CONTACT_TABLE + "("
                + Contact._ID + " INTEGER PRIMARY KEY AUTOINCREMENT, "
                + Contact.NAME + " VARCHAR, "
                + Contact.PHONE + " VARCHAR, "
                + Contact.EMAIL + " VARCHAR);";
        db.execSQL(cmd);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }
}
```

### 获取数据库
SQLiteOpenHelper有2个实例方法：

* getReadableDatabase()
* getWritableDatabase()

当数据库不可写入，getReadableDatabase()方法返回的对象将以只读的方式打开数据库。
而getWritableDatabase()方法会出现异常。

用一个SQLiteOpenHelper实例来调用这些方法。
```java
    RustDatabaseHelper databaseHelper;
    ......
    databaseHelper = new RustDatabaseHelper(getApplicationContext(), DATABASE_NAME, null, 1);
    SQLiteDatabase db = databaseHelper.getWritableDatabase();
```

### 查找数据
获取数据库实例，使用Cursor根据条件获取结果集；在结果集中利用列的名称获取索引，最后获取数据
```java
    SQLiteDatabase dbE = database.getReadableDatabase();// 获取数据库
    /* 查找表中所有的属性，以CONTACT_ID为关键字，匹配条件是CONTACT_ID=id（目标id） */
    Cursor cursor = dbE.query(CONTACT_TABLE,
            new String[]{CONTACT_ID, CONTACT_NAME, CONTACT_PHONE, CONTACT_EMAIL},
            CONTACT_ID + "=?", new String[]{id}, null, null, null);
    /* 此时cursor是一个结果集合，还需从中取出想要的数据。先获取索引 */
    int nameIndex = cursor.getColumnIndex(CONTACT_NAME);
    int phoneIndex = cursor.getColumnIndex(CONTACT_PHONE);// 获取索引值
    int emailIndex = cursor.getColumnIndex(CONTACT_EMAIL);
    /* 取数据，使用while循环 */
    while (cursor.moveToNext()) {
        currentID = cursor.getInt(cursor.getColumnIndex(CONTACT_ID));
        editName.setText(cursor.getString(nameIndex));
        editPhone.setText(cursor.getString(phoneIndex));// 取出的数据执行自定义操作
        editEmail.setText(cursor.getString(emailIndex));
    }
    cursor.close();
```
cursor.getColumnIndex("none") 返回-1的问题，因为构建Cursor时传入的列名称错误

Cursor是结果集游标，用于对结果集进行随机访问。
使用moveToNext()方法可以将游标从当前行移动到下一行，如果已经移过了结果集的最后一行，返回结果为false，  
否则为true。另外Cursor 还有常用的moveToPrevious()方法  
（用于将游标从当前行移动到上一行，如果已经移过了结果集的第一行，返回值为false，否则为true ）、  
moveToFirst()方法（用于将游标移动到结果集的第一行，如果结果集为空，返回值为false，否则为true ）  
和moveToLast()方法（用于将游标移动到结果集的最后一行，如果结果集为空，返回值为false，否则为true ） 。

### 向数据库中添加数据
使用ContentValues保存要添加的数据；获取数据库实例，将数据塞进去（或更新已有数据）
```java

    ContentValues values = new ContentValues();
    values.put(CONTACT_NAME, name);// 根据列名存放数据
    values.put(CONTACT_PHONE, TextUtils.isEmpty(phone) ? "" : phone);
    values.put(CONTACT_EMAIL, TextUtils.isEmpty(email) ? "" : email);
    SQLiteDatabase db = database.getWritableDatabase();

    if (editItem) {
        // 更新数据，判断条件是 CONTACT_ID
        db.update(CONTACT_TABLE, values, CONTACT_ID + "=?", new String[]{String.valueOf(currentID)});
    } else {
        db.insert(CONTACT_TABLE, null, values);// 塞到 CONTACT_TABLE 这个数据表中
    }

    db.close();
```

### 删除数据
删除单条数据
```java
    SQLiteDatabase dbR = databaseHelper.getWritableDatabase();// 获取实例
    // 删除数据，搜索依据是CONTACT_ID
    dbR.delete(CONTACT_TABLE, CONTACT_ID + "=?", new String[]{itemID});
    dbR.close();
```
删除数据表
```java
    SQLiteDatabase db = databaseHelper.getWritableDatabase();
    db.delete(CONTACT_TABLE, "1", null);// “1”是数据库版本号
```

## 附录
报错：
```
java.lang.IllegalStateException: This Activity already has an action bar supplied by the window decor. Do not request Window.FEATURE_SUPPORT_ACTION_BAR and set windowActionBar to false in your theme to use a Toolbar instead.
```
资源文件对应不同的API等级；在不同版本的机器上表现不一样。这里是style.xml的问题


更改了数据库的操作方法后，要卸掉原来的apk，重新装。或者恢复出厂设置
