---
title: Android SPP连接蓝牙设备注意事项
date: 2016-09-07 21:28:33
category: Android_note
tag: [Bluetooth]
---

使用SPP协议

尝试连接蓝牙设备时，最好新开一个线程。然后用远程设备的MAC地址来重启获取一下。

```java
public ConnectThread(BluetoothDevice device) {
    mmDevice = mAdapter.getRemoteDevice(device.getAddress());// get this device again
    // ......
}
```

连接另一台蓝牙设备之前，先断开前一个设备的socket  
如果当前连接意外断开，可以不关闭当前socket
```java
/**
 * Stop all bluetooth threads
 */
public synchronized void stopAllBtThreads(boolean closeSocket) {
    if (BTConstants.isDebug) Log.d(TAG, "stop all Bt threads");
    if (mConnectThread != null) {
        if (closeSocket) {
            mConnectThread.cancel();
        }
        mConnectThread.interrupt();
        mConnectThread = null;
    }
    if (mConnectedThread != null) {
        if (closeSocket) {
            mConnectedThread.cancel();
        }
        mConnectedThread.interrupt();
        mConnectedThread = null;
    }
    recordBtStateAndPost(BTConstants.BLUETOOTH_STATE_NONE);
}
```

注意：如果不断开当前socket而去连接另一台蓝牙设备，是有可能同时接收到多个蓝牙设备的数据
传输的。只要它们跑在不同的线程中。

在最近的真机实验中（2016-12-29），同一台手机同时能SPP连接7个蓝牙设备。
7个是系统规定的连接上限。
