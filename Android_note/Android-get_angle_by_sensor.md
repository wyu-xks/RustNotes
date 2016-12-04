---
title: Android 获取手机当前角度
date: 2017-1-6 22:01:40
category: Android_note
tag: [sensor]
---


获取手机当前姿态的角度。需要调用加速度传感器和地磁传感器，获取两者的数据后计算出角度。

测试环境：Android4.4.2  Android5.1

### 姿态角度信息
通过加速度传感器数据和地磁传感器数据计算得到的角度信息存储在一个float数组中，
按顺序分别是Azimuth，Pitch和Roll

* Azimuth   围绕z轴的偏转角度，[-π,π]，当面向南方时，值为0。
* Pitch     围绕x轴的偏转角度，[-π/2,π/2]，手机水平放置时为0。
* Roll      围绕y轴的偏转角度，[-π,π]，手机水平放置时为0。

数值范围经过手机（荣耀，魅族）实测

### 获取姿态角度信息过程
需要`SensorManager`和`Sensor`；计算用到的方法有
```java
SensorManager.getRotationMatrix(mRMatrix, null, mAccValues, mMagValues);
SensorManager.getOrientation(mRMatrix, mPhoneAngleValues);
```
`mRMatrix`是包含9个元素的一维数组。`SensorManager.getRotationMatrix`计算后得到的旋转矩阵存在其中。

#### SensorManager.getRotationMatrix(float[] R, float[] I, float[] gravity, float[] geomagnetic)

* `R`即旋转矩阵的计算结果，例子中为`mRMatrix`
* `I`是一个转换矩阵，将磁场数据转换进实际的重力坐标中，一般情况下可设为null
* `gravity` 加速度传感器获得的数据，通过`SensorEventListener.onSensorChanged`获取
* `geomagnetic` 地磁传感器获得的数据，通过`SensorEventListener.onSensorChanged`获取

#### SensorManager.getOrientation(float[] R, float values[])

最终的角度数据，需调用`SensorManager.getOrientation`。

* `R`即旋转矩阵，在这里用于计算
* 最终的手机姿态信息（弧度值）

主要代码
```java
/**
 * 用于监视陀螺仪的数据
 */
public class GyroActivity extends Activity implements SensorEventListener {

    private static final String TAG = "rustApp";

    // UI ......

    private SensorManager mSensorManager;
    private Sensor mGyroSensor;
    private Sensor mAccSensor;
    private Sensor mMagSensor;

    // 加速度传感器数据
    float mAccValues[] = new float[3];
    // 地磁传感器数据
    float mMagValues[] = new float[3];
    // 旋转矩阵，用来保存磁场和加速度的数据
    float mRMatrix[] = new float[9];
    // 存储方向传感器的数据（原始数据为弧度）
    float mPhoneAngleValues[] = new float[3];

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.act_gyro);
        initUtils();
        initPhoneSensors();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
        mSensorManager.unregisterListener(this, mGyroSensor);
        mSensorManager.unregisterListener(this, mAccSensor);
        mSensorManager.unregisterListener(this, mMagSensor);
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        switch (event.sensor.getType()) {
            case Sensor.TYPE_ACCELEROMETER:
                mAccXTv.setText(String.format(Locale.CHINA, "acc x : %f", event.values[0]));
                mAccYTv.setText(String.format(Locale.CHINA, "acc y : %f", event.values[1]));
                mAccZTv.setText(String.format(Locale.CHINA, "acc z : %f", event.values[2]));
                System.arraycopy(event.values, 0, mAccValues, 0, mAccValues.length);// 获取数据
                break;
            case Sensor.TYPE_GYROSCOPE:
                mPhoneGyroXTv.setText(String.format(Locale.CHINA, "PhoneGyro x : %f", event.values[0]));
                mPhoneGyroYTv.setText(String.format(Locale.CHINA, "PhoneGyro y : %f", event.values[1]));
                mPhoneGyroZTv.setText(String.format(Locale.CHINA, "PhoneGyro z : %f", event.values[2]));
                break;
            case Sensor.TYPE_MAGNETIC_FIELD:
                System.arraycopy(event.values, 0, mMagValues, 0, mMagValues.length);// 获取数据
                break;
        }
        SensorManager.getRotationMatrix(mRMatrix, null, mAccValues, mMagValues);
        SensorManager.getOrientation(mRMatrix, mPhoneAngleValues);// 此时获取到了手机的角度信息
        mPhoneAzTv.setText(String.format(Locale.CHINA, "Azimuth(地平经度): %f", Math.toDegrees(mPhoneAngleValues[0])));
        mPhonePitchTv.setText(String.format(Locale.CHINA, "Pitch: %f", Math.toDegrees(mPhoneAngleValues[1])));
        mPhoneRollTv.setText(String.format(Locale.CHINA, "Roll: %f", Math.toDegrees(mPhoneAngleValues[2])));
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    private void initUtils() {
        ButterKnife.bind(this);
    }

    private void initPhoneSensors() {
        mSensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        List<Sensor> sensorList = mSensorManager.getSensorList(Sensor.TYPE_ALL);
        for (Sensor sensor : sensorList) {
            Log.d(TAG, String.format(Locale.CHINA, "[Sensor] name: %s \tvendor:%s",
                    sensor.getName(), sensor.getVendor()));
        }
        // 获取传感器
        mGyroSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);
        mAccSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        mMagSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
        mSensorManager.registerListener(this, mGyroSensor, SensorManager.SENSOR_DELAY_UI);
        mSensorManager.registerListener(this, mAccSensor, SensorManager.SENSOR_DELAY_UI);
        mSensorManager.registerListener(this, mMagSensor, SensorManager.SENSOR_DELAY_UI);
    }
}

```
