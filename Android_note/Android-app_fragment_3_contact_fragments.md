---
title: Android Fragment 间的通信
date: 2015-09-29 15:09:18
category: Android_note
tag: [Android_UI]
toc: true
---

在Fragment的java文件中，可以使用getActivity()来获得调用它的activity，
然后再找到另一个Fragment，进行通信

`getActivity().getFragmentManager().findFragmentById(R.id.fragment_list);`  
但这样做耦合度太高，不方便后续的修改操作

Fragment与其附着的Activity之间的通信，都应该由Activity来完成；不能是多个Fragment之间直接通信

## Fragment与其附着的Activity之间通信最佳方式：

* 1.在发起事件的Fragment中定义一个接口，接口中声明你的方法

* 2.在onAttach方法中要求Activity实现该接口

* 3.在Activity中实现该方法

例如一个activity中布置了2个Fragment，它们之间的通信要依靠activity来完成

代码：`ListStoreActivity.java` `NewItemFragment.java` `ListStoreFragment.java`  
布局文件为：`liststore.xml` `new_item_fragment.xml`

### 准备布局文件：

liststore.xml用LinearLayout中放置了2个fragment，分别指向2个Fragment文件  
new_item_fragment.xml 中并排放置一个EditText和一个按钮

`ListStoreFragment.java` 使用前面定义的界面

```java
public class ListStoreFragment extends ListFragment{
///	继承自ListFragment，已经封装好了listview
/// 不需要自己写ListView了
}
```
NewItemFragment.java
```java
    /**
	 * 声明一个接口，定义向activity传递的方法
	 * 绑定的activity必须实现这个方法
	 */
	public interface OnNewItemAddedListener {
		public void newItemAdded(String content);
	}
	private OnNewItemAddedListener onNewItemAddedListener;
	private Button btnAddItem;
	/*复写onAttach方法*/
	@Override
	public void onAttach(Activity activity) {
		super.onAttach(activity);
		try {
			onNewItemAddedListener = (OnNewItemAddedListener) activity;
		} catch (ClassCastException e){
			throw new ClassCastException(activity.toString() + "must implement OnNewItemAddedListener");
		}
	}
```
ListStoreActivity.java 加载主视图`liststore.xml`;

两个Fragment通过`ListStoreActivity`来通信

在onCreate方法中获取ListStoreFragment的实例；并且复写newItemAdded方法，在里面加上业务逻辑
```java
public class ListStoreActivity extends Activity implements OnNewItemAddedListener{

	private ArrayList<String> data;
	private ArrayAdapter<String> adapter;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.liststore);
		data = new ArrayList<String>();
		// 把data装入adapter中
		adapter = new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, data);
		// ListFragment并不需要再定义一个listview		
		ListStoreFragment listStoreFragment = (ListStoreFragment) getFragmentManager().findFragmentById(R.id.fragment_listview);
		listStoreFragment.setListAdapter(adapter);
	}

	@Override
	public void newItemAdded(String content) {
		//	复写接口中的方法，业务代码在这里实现
		if(!content.equals("")) {
			data.add(content);
			adapter.notifyDataSetChanged();
		}
	}
}
```
这样做的缺点是耦合度很高
