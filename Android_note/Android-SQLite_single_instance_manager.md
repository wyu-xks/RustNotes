---
title: Android - 单例模式的数据库管理中心
date: 2016-10-26 14:47:12
category: Android_note
tag: [Android_Storage]
toc: true
---

创建好数据库后，需要增删查改等等操作。为了避免重复代码，并让代码更清晰一些，我们可以
创建一个单例化的数据库管理中心。需要操作数据库时直接调用即可。
相关方法都封装在管理中心（manager）里面。

## 部分文件目录
```
`-- rustfisher
    |-- db
    |   |-- ContactEntity.java
    |   |-- RustDBHelper.java
    |   `-- RustDBManager.java
    |-- DBDemoActivity.java
    |-- RustApp.java
```

## 代码示例
### 创建数据库

`RustDBHelper.java`先把数据库定义出来。

```java
/**
* 创建数据库
*/
public class RustDBHelper extends SQLiteOpenHelper {

    public static final int DATABASE_VERSION = 1;
    public static final String DATABASE_NAME = "data.db";// 数据库名称

    public interface Tables {
        String CONTACT_TABLE = "contact";// 表名，一般定好了就不动了
    }

    // 存放各种属性 —— 不建议使用接口来表示属性
    public interface Contact {
        String _ID = "contact_id";
        String NAME = "name";
        String PHONE = "phone";
        String EMAIL = "email";
    }

    public RustDBHelper(Context context, String name,
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

在这里要定义一个数据库存储的对象，这样方便管理，逻辑更清晰
以`ContactEntity.java`为例
```java
/**
* 基础类
*/
public final class ContactEntity {
    private int id = -1;
    private String name;
    private String phone;
    private String email;

    public ContactEntity(String name, String phone, String email) {
        this.name = name;
        this.phone = phone;
        this.email = email;
    }

    public ContactEntity(int id, String name, String phone, String email) {
        this.id = id;
        this.name = name;
        this.phone = phone;
        this.email = email;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getPhone() {
        return phone;
    }

    public String getEmail() {
        return email;
    }

    @Override
    public String toString() {
        return id + " " + name + " " + phone + " " + email;
    }
}
```

### 创建数据库管理者

为了获取context，将application的实例开放接口

```java
public class RustApp extends Application {

    private static RustApp instance;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
    }

    // 需要context时使用
    public static RustApp getInstance() {
        return instance;
    }

}
```

创建`RustDBManager.java`；可以看到，使用`ContactEntity`来封装数据十分方便

```java
/**
* 数据库控制中心
* 双重校验锁单例模式，在这里提供数据库的相关方法，调用方便
*/
public final class RustDBManager {

    private volatile static RustDBManager manager;
    private SQLiteDatabase db;

    private RustDBManager() {
        RustDBHelper helper = new RustDBHelper(RustApp.getInstance(), RustDBHelper.DATABASE_NAME, null, RustDBHelper.DATABASE_VERSION);
        db = helper.getReadableDatabase();
    }

    public static RustDBManager getManager() {
        if (null == manager) {
            synchronized (RustDBManager.class) {
                manager = new RustDBManager();
            }
        }
        return manager;
    }

    // 插入一条数据
    public void insertOneContact(ContactEntity entity) {
        ContentValues cv = new ContentValues();
        cv.put(RustDBHelper.Contact.NAME, entity.getName());
        cv.put(RustDBHelper.Contact.PHONE, entity.getPhone());
        cv.put(RustDBHelper.Contact.EMAIL, entity.getEmail());
        db.insert(RustDBHelper.Tables.CONTACT_TABLE, null, cv);
    }

    // 删除库中第一条数据
    public void deleteFirstItem() {
        Cursor cursor = db.query(RustDBHelper.Tables.CONTACT_TABLE, new String[]{RustDBHelper.Contact._ID,
                RustDBHelper.Contact.NAME,
                RustDBHelper.Contact.PHONE,
                RustDBHelper.Contact.EMAIL}, null, null, null, null, null);
        if (cursor.getCount() == 0) {
            cursor.close();
            return;
        }
        cursor.moveToFirst();
        db.delete(RustDBHelper.Tables.CONTACT_TABLE, RustDBHelper.Contact._ID + "=" + cursor.getInt(0), null);
        cursor.close();
    }

    // 查询所有数据
    public List queryAll() {
        Cursor cursor = db.query(RustDBHelper.Tables.CONTACT_TABLE, new String[]{RustDBHelper.Contact._ID,
                RustDBHelper.Contact.NAME,
                RustDBHelper.Contact.PHONE,
                RustDBHelper.Contact.EMAIL}, null, null, null, null, null);
        ArrayList<ContactEntity> list = new ArrayList<>();
        if (cursor.getCount() == 0) {
            cursor.close();
            return list;
        }
        while (cursor.moveToNext()) {
            list.add(new ContactEntity(cursor.getInt(0), cursor.getString(1), cursor.getString(2), cursor.getString(3)));
        }
        cursor.close();
        return list;
    }

}
```

### 操作数据库

在`DBDemoActivity.java`中演示如何使用数据库管理的方法

```java
/**
* 演示数据库操作
*/
public class DBDemoActivity extends Activity {

    private static final String TAG = "rustApp";
    private RustDBManager mDBManager = RustDBManager.getManager();

    private EditText mNameEt;
    private EditText mPhoneEt;
    private EditText mEmailEt;

    private TextView mContentTv;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.act_db_demo);

        mNameEt = (EditText) findViewById(R.id.nameEt);
        mPhoneEt = (EditText) findViewById(R.id.phoneEt);
        mEmailEt = (EditText) findViewById(R.id.emailEt);
        mContentTv = (TextView) findViewById(R.id.dbContent);

        findViewById(R.id.insertItem).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = mNameEt.getText().toString();
                String phone = mPhoneEt.getText().toString();
                String email = mEmailEt.getText().toString();
                if (TextUtils.isEmpty(name) || TextUtils.isEmpty(phone) || TextUtils.isEmpty(email)) {
                    Toast.makeText(getApplicationContext(), "input wrong", Toast.LENGTH_SHORT).show();
                    return;
                }
                mDBManager.insertOneContact(new ContactEntity(name, phone, email));// 插入新数据到表尾
                queryShow();
            }
        });
        findViewById(R.id.deleteItem).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDBManager.deleteFirstItem();// 删除数据库中第一条数据的操作
                queryShow();
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        queryShow();
    }

    // 查询数据库的操作要放在子线程里面，避免阻塞UI线程
    private void queryShow() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                List list = mDBManager.queryAll();
                Iterator i = list.iterator();
                StringBuilder sb = new StringBuilder();
                while (i.hasNext()) {
                    sb.append(i.next().toString());
                    sb.append("\n");
                }
                final String content = sb.toString();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mContentTv.setText(content);
                    }
                });
            }
        }).start();
    }

}
```

## 结束
这样封装的好处是：可以方便的调用数据库的相关方法。减少了重复代码。

对于需要全局来管理的对象，可以尝试提供一个单例的接口。调用起来方便。或者放在服务里面。  
比如音乐播放服务等等。
