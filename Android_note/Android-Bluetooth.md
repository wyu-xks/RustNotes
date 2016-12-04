---
title: Android Bluetooth 简析
date: 2015-10-28 15:09:33
category: Android_note
tag: [Bluetooth]
toc: true
---


源码基于 Android L


## Reference

### BluetoothAdapter
首先调用静态方法getDefaultAdapter()获取蓝牙适配器bluetoothadapter，
如果返回为空，则表明此设备不支持蓝牙。

代表本地蓝牙适配器。BluetoothAdapter 让你进行基础的蓝牙操作，比如初始化搜索设备，对已配对设备进行检索，根据一直MAC地址
实例化一个 BluetoothDevice，建立一个监听其他设备连接请求的 BluetoothServerSocket，启动对蓝牙LE设备的搜索。

这是使用蓝牙的起点。获得了本地适配器后，可以调用`getBondedDevices()`获得代表配对设备的 BluetoothDevice 对象
`startDiscovery()`启动搜索蓝牙设备。或者建立一个BluetoothServerSocket ，
调用`listenUsingRfcommWithServiceRecord(String, UUID)`来监听接入请求
`startLeScan(LeScanCallback)` 搜索Bluetooth LE 设备

相应的源码
BluetoothAdapter.java (frameworks/base/core/java/android/bluetooth)
```java
    /**
     * Get a handle to the default local Bluetooth adapter.
     * <p>Currently Android only supports one Bluetooth adapter, but the API
     * could be extended to support more. This will always return the default
     * adapter.
     * @return the default local adapter, or null if Bluetooth is not supported
     *         on this hardware platform
     */
    public static synchronized BluetoothAdapter getDefaultAdapter() {
        if (sAdapter == null) {
            IBinder b = ServiceManager.getService(BLUETOOTH_MANAGER_SERVICE);
            if (b != null) {
                IBluetoothManager managerService = IBluetoothManager.Stub.asInterface(b);
                sAdapter = new BluetoothAdapter(managerService);
            } else {
                Log.e(TAG, "Bluetooth binder is null");
            }
        }
        return sAdapter;
    }
```

### BluetoothSocket
一个连接上或连接中的socket
使用BluetoothServerSocket来创建一个监听的服务socket。
对于服务端，当BluetoothServerSocket接收了一个连接，会返回一个新的BluetoothSocket来管理这个连接。
对于客户端，使用一个单独的BluetoothSocket来初始化一个发送连接并管理这个连接。
蓝牙socket最普通的模式是RFCOMM，这是Android API支持的模式。
RFCOMM面向连接，使用流传输。也称为Serial Port Profile (SPP)

建立一个到已知蓝牙设备的BluetoothSocket，使用`BluetoothDevice.createRfcommSocketToServiceRecord()`
然后调用`connect()`来连接这个远程设备。调用这个方法会阻塞程序直到建立连接或者连接失败。
一旦socket连接上，不论初始化为客户端或者服务端，调用`getInputStream()`和`getOutputStream()`打开IO流来分别接收
输入流和输出流对象。流对象自动连接到socket

BluetoothSocket是线程安全的。特别的是，`close()`会立刻关闭进行中的操作并关闭socket。

需要 BLUETOOTH 相关权限

### BluetoothServerSocket
一个监听的蓝牙socket
在服务端，使用BluetoothServerSocket来建立一个监听的服务socket。

使用`BluetoothAdapter.listenUsingRfcommWithServiceRecord()`来建立一个监听接入连接的BluetoothServerSocket
然后调用`accept()`监听连接请求。这个调用会阻塞，直到建立连接，并返回一个管理连接的BluetoothSocket
获得了 BluetoothSocket，并且不再需要连接，可以调用`close()`来关闭掉 BluetoothServerSocket
关闭 BluetoothServerSocket 并不会关闭返回的 BluetoothSocket

BluetoothServerSocket 是线程安全的，特别的是，`close()`会立刻关闭进行中的操作并关闭服务 socket。

### BluetoothDevice
代表一个远程蓝牙设备。BluetoothDevice 能让你与其他设备建立连接，或者查询设备信息，比如名称，地址，类别和连接状态等。
这是蓝牙硬件地址的简单包装类。找个类的对象都说不可变的。这个类的操作会在远程蓝牙硬件地址上体现。

通过一个已知的MAC地址（可用BluetoothDevice来发现），或是通过`BluetoothAdapter.getBondedDevices()`返回的已连接设备
调用`BluetoothAdapter.getRemoteDevice(String)`来获得一个 BluetoothDevice。
然后就可以打开 BluetoothSocket 来与远程设备建立连接，调用`createRfcommSocketToServiceRecord(UUID)`

## API Guides
* 搜索其他蓝牙设备
* 检索匹配到的蓝牙设备
* 建立RFCOMM频道
* 通过发现服务来连接其他设备
* 管理多个连接

### Setting Up Bluetooth 设置蓝牙
使用蓝牙通信前，确定设备支持蓝牙，并将蓝牙打开

1.获取 BluetoothAdapter
使用静态方法`BluetoothAdapter.getDefaultAdapter()`获取机器的蓝牙适配器；若返回null，则表示机器不支持蓝牙
```java
BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
if (mBluetoothAdapter == null) {
    // Device does not support Bluetooth
}
```
2.激活蓝牙
检查蓝牙是否已经打开；若没打开，可以使用下面的方法打开蓝牙
```java
if (!mBluetoothAdapter.isEnabled()) {
    Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
    startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
}
```
会弹出一个对话框，请求用户打开蓝牙。如果成功打开，activity 的 onActivityResult() 会收到 RESULT_OK ， 如果未打开，
则收到 RESULT_CANCELED

可以让应用监听 ACTION_STATE_CHANGED ，当蓝牙状态改变时会发出这个广播。这个广播包括蓝牙原先状态和现在状态，分别装在
EXTRA_PREVIOUS_STATE 和 EXTRA_STATE 里。
状态可能是 STATE_TURNING_ON， STATE_ON， STATE_TURNING_OFF， 和 STATE_OFF

### Finding Devices 寻找设备
使用 BluetoothAdapter，可以寻找远程蓝牙设备或检索匹配设备

搜索设备是搜索本地区域已开启的蓝牙设备程序。蓝牙设备有可见模式和不可见模式。如果一个设备是可发现的，它会相应搜索请求并
返回一些信息，比如设备名，类别，独立的MAC地址。利用这些信息，设备可以初始化一个到被发现设备的连接。

第一次与其他设备连接建立，会自动弹出一个配对请求给用户。成功配对后，设备的基本信息会被保存下来，并且可以被蓝牙API调用。
使用已知的远程设备的MAC地址，可以在不搜索设备的情况下建立连接。

配对和连接是不同的。配对表示两个设备知道对方的存在，有相互认证的key，能够与对方建立加密的连接。
连接意味着设备目前共享一个RFCOMM频道，并能相互发送数据。目前android蓝牙API要求设备先配对，再进行连接。

注意：Android设备并不是默认蓝牙可见的。用户可以在系统设置中让设备蓝牙可被搜索到。

#### Querying paired devices 检索已配对的设备
搜索设备前，可以调用`getBondedDevices()`检索一下已配对的设备。这会返回配对设备的BluetoothDevices集合。
例如，你可以检索配对设备并把每个设备信息存入 ArrayAdapter ：
```java
Set<BluetoothDevice> pairedDevices = mBluetoothAdapter.getBondedDevices();
// If there are paired devices
if (pairedDevices.size() > 0) {
    // Loop through paired devices
    for (BluetoothDevice device : pairedDevices) {
        // Add the name and address to an array adapter to show in a ListView
        mArrayAdapter.add(device.getName() + "\n" + device.getAddress());
    }
}
```
只需要MAC地址，就能够用BluetoothDevice对象建立连接。

#### Discovering devices 搜索设备
调用`startDiscovery()`搜索设备。这个异步进程会立刻返回是否启动成功的boolean值。搜索进程通常是inquiry scan进行12秒，
接下来是每个发现设备的 page scan 。

你的应用必须注册一个广播接收器来监听 ACTION_FOUND ，接收发现的每个设备的信息。每发现一个设备，系统会发送 ACTION_FOUND
这个 Intent 带有 EXTRA_DEVICE 和 EXTRA_CLASS，里面分别包含 BluetoothDevice 和一个 BluetoothClass
例如，注册一个广播接收器来监听被发现设备：

```java
// Create a BroadcastReceiver for ACTION_FOUND
private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        // When discovery finds a device
        if (BluetoothDevice.ACTION_FOUND.equals(action)) {
            // Get the BluetoothDevice object from the Intent
            BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
            // Add the name and address to an array adapter to show in a ListView
            mArrayAdapter.add(device.getName() + "\n" + device.getAddress());
        }
    }
};
// Register the BroadcastReceiver
IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
registerReceiver(mReceiver, filter); // Don't forget to unregister during onDestroy
```

警告：搜索设备对于蓝牙适配器来说是一个耗费资源的进程。发现目标设备后，一定要在连接前调用`cancelDiscovery()`停止搜索。
不要在与设备连接时启动搜索。搜索设备会减小连接的带宽。

##### Enabling discoverability 激活设备蓝牙可见
如果想让本地设备对其他设备蓝牙可见，调用`startActivityForResult(Intent, int)`，传入ACTION_REQUEST_DISCOVERABLE
这会请求激活系统设置。默认激活120秒。可以用EXTRA_DISCOVERABLE_DURATION来请求别的时间。应用可设最长时间是3600秒。
0表示设备永远可见。在0~3600外的数字会被设置为120秒。比如，将时间设置为300秒：
```java
Intent discoverableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
discoverableIntent.putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, 300);
startActivity(discoverableIntent);
```
会显示一个对话框来请求用户。如果用户点击“Yes”，设备会变得蓝牙可见。activity会收到`onActivityResult()`回调，并传回
设置蓝牙可见时间的数值。如果用户点击“No”或出现错误，返回代码会是 RESULT_CANCELED 。

注意：如果设备未开启蓝牙，将设备蓝牙设为可见会自动打开蓝牙

设备会在允许时间内保持沉默。可以注册广播接收器来监听 ACTION_SCAN_MODE_CHANGED 。这个Intent会带着 EXTRA_SCAN_MODE
和 EXTRA_PREVIOUS_SCAN_MODE，分别是新的和旧的状态。可能的状态值会是：
SCAN_MODE_CONNECTABLE_DISCOVERABLE， SCAN_MODE_CONNECTABLE， 或 SCAN_MODE_NONE

如果要与远程设备连接，可以不激活设备可见。当应用想要建立服务socket获取接入时，必须打开设备可见。因为远程设备必须要发现
本地设备来建立连接。

### Connecting Devices 连接设备
服务端设备和客户端设备以不同的方式获取 BluetoothSocket。连接建立时，服务端获取一个 BluetoothSocket。
客户端打开一个RFCOMM时会得到 BluetoothSocket 。

#### Connecting as a server 在连接中作为服务端
当你要连接2个设备，其中一个必须作为服务器并持有一个打开的 BluetoothServerSocket 。服务socket的目的是获取接入请求并
给已连上设备一个 BluetoothSocket 。当从 BluetoothServerSocket 获取到 BluetoothSocket，BluetoothServerSocket
可以关闭掉，除非你想接入更多连接。
1. 调用`listenUsingRfcommWithServiceRecord(String, UUID)`来获得一个 `BluetoothServerSocket`
2. 调用`accept()` 来监听接入请求
3. 如果不需要接入更多连接，调用`close()`

`accept()`不应该在UI线程中调用，因为它是阻塞式的。通常在应用中启动新的线程来操作BluetoothServerSocket 或 BluetoothSocket
在另一个线程调用BluetoothServerSocket （或 BluetoothSocket）的`close()`能跳出阻塞，并立刻返回

例子：
```java

private class AcceptThread extends Thread {
   private final BluetoothServerSocket mmServerSocket;
   public AcceptThread() {
       // Use a temporary object that is later assigned to mmServerSocket,
       // because mmServerSocket is final
       BluetoothServerSocket tmp = null;
       try {
           // MY_UUID is the app's UUID string, also used by the client code
           tmp = mBluetoothAdapter.listenUsingRfcommWithServiceRecord(NAME, MY_UUID);
       } catch (IOException e) { }
       mmServerSocket = tmp;
   }
   public void run() {
       BluetoothSocket socket = null;
       // Keep listening until exception occurs or a socket is returned
       while (true) {
           try {
               socket = mmServerSocket.accept();
           } catch (IOException e) {
               break;
           }
           // If a connection was accepted
           if (socket != null) {
               // Do work to manage the connection (in a separate thread)
               manageConnectedSocket(socket);
               mmServerSocket.close();
               break;
           }
       }
   }
   /** Will cancel the listening socket, and cause the thread to finish */
   public void cancel() {
       try {
           mmServerSocket.close();
       } catch (IOException e) { }
   }
}
```
上面这个例子只需要一个接入连接。连接建立并获得 BluetoothSocket 后，应用将这个 BluetoothSocket 发给单独的线程来处理
并关闭 BluetoothServerSocket 结束循环。

当`accept()`返回 BluetoothSocket，这个socket已经是连接上的了。因此不必调用`connect()`（客户端也一样）

`manageConnectedSocket()`是一个虚构的方法，用来初始化传输数据的线程，在连接管理中来讨论它

监听接入连接结束后通常要立刻关闭 BluetoothServerSocket 。这个例子中，获取 BluetoothSocket 后立刻调用了`close()`。
可以在线程中写一个公共方法来关闭私有的 BluetoothSocket 。当需要停止监听服务socket时可以使用这个方法。

#### Connecting as a client 在连接中作为客户端
与远程设备（服务端）建立连接，先获取一个代表远程设备的 BluetoothDevice 对象。必须使用 BluetoothDevice 来获取
BluetoothSocket 并初始化连接。

基本流程：
1. 调用BluetoothDevice的`createRfcommSocketToServiceRecord(UUID)`获取BluetoothSocket
2. 调用`connect()`来初始化连接

注意：在调用`connect()`时必须确保设备不在搜索进行中。在搜索设备时，连接尝试会变慢并且很容易失败。

```java
private class ConnectThread extends Thread {
   private final BluetoothSocket mmSocket;
   private final BluetoothDevice mmDevice;
   public ConnectThread(BluetoothDevice device) {
       // Use a temporary object that is later assigned to mmSocket,
       // because mmSocket is final
       BluetoothSocket tmp = null;
       mmDevice = device;
       // Get a BluetoothSocket to connect with the given BluetoothDevice
       try {
           // MY_UUID is the app's UUID string, also used by the server code
           tmp = device.createRfcommSocketToServiceRecord(MY_UUID);
       } catch (IOException e) { }
       mmSocket = tmp;
   }
   public void run() {
       // Cancel discovery because it will slow down the connection
       mBluetoothAdapter.cancelDiscovery();
       try {
           // Connect the device through the socket. This will block
           // until it succeeds or throws an exception
           mmSocket.connect();
       } catch (IOException connectException) {
           // Unable to connect; close the socket and get out
           try {
               mmSocket.close();
           } catch (IOException closeException) { }
           return;
       }
       // Do work to manage the connection (in a separate thread)
       manageConnectedSocket(mmSocket);
   }
   /** Will cancel an in-progress connection, and close the socket */
   public void cancel() {
       try {
           mmSocket.close();
       } catch (IOException e) { }
   }
}
```
建立连接前，调用`cancelDiscovery()`。

`manageConnectedSocket()`是一个虚构的方法，在连接管理中讨论它。
使用完`BluetoothSocket`，一定要调用`close()`来结束

### Managing a Connection
成功连接2个或更多的设备后，每个设备有一个 BluetoothSocket 。设备直接可以共享数据。使用BluetoothSocket传输任意数据

获取处理传输的 InputStream 和 OutputStream，分别调用 `getInputStream()` 和 `getOutputStream()`
调用`read(byte[])` 和 `write(byte[])` 来读写数据

线程的主循环中应该用于专门从InputStream中读数据。线程中要有专门的public方法来写数据到OutputStream

```java
private class ConnectedThread extends Thread {
    private final BluetoothSocket mmSocket;
    private final InputStream mmInStream;
    private final OutputStream mmOutStream;
    public ConnectedThread(BluetoothSocket socket) {
        mmSocket = socket;
        InputStream tmpIn = null;
        OutputStream tmpOut = null;
        // Get the input and output streams, using temp objects because
        // member streams are final
        try {
            tmpIn = socket.getInputStream();
            tmpOut = socket.getOutputStream();
        } catch (IOException e) { }
        mmInStream = tmpIn;
        mmOutStream = tmpOut;
    }
    public void run() {
        byte[] buffer = new byte[1024];  // buffer store for the stream
        int bytes; // bytes returned from read()
        // Keep listening to the InputStream until an exception occurs
        while (true) {
            try {
                // Read from the InputStream
                bytes = mmInStream.read(buffer);
                // Send the obtained bytes to the UI activity
                mHandler.obtainMessage(MESSAGE_READ, bytes, -1, buffer)
                        .sendToTarget();
            } catch (IOException e) {
                break;
            }
        }
    }
    /* Call this from the main activity to send data to the remote device */
    public void write(byte[] bytes) {
        try {
            mmOutStream.write(bytes);
        } catch (IOException e) { }
    }
    /* Call this from the main activity to shutdown the connection */
    public void cancel() {
        try {
            mmSocket.close();
        } catch (IOException e) { }
    }
}
```
构造方法需要数据流，一旦执行，线程会等InputStream中传来的数据。当`read(byte[])`返回数据流，通过handler将数据送往
主activity。然后等待数据流中更多的字节

向外发送数据调用`write()`

线程的`cancel()`方法很重要。完成了蓝牙连接的所有操作后，应当cancel掉
