---
title: Android 用builder形式构建自定义Dialog
date: 2016-10-12 15:31:01
category: Android_note
tag: [Android_widget]
---

根据项目需求，构建自定义dialog。可以自己定义layout。
一般都是实现UI方面的需求，比如更改dialog背景，按钮样式等等。
同一个应用里，会统一dialog的样式（主题）。但是根据场景不同又有细微的调整。
比如dialog宽高度的调整，是否显示标题，是否显示按钮等等。

可以构建一个通用的Dialog，根据不同需求来设定效果。若有多个可选效果，考虑使用builder模式。

Dialog的大小用屏幕的比例来确定。这个比例是可以调节的。如果不显示按钮，可以将高度调小一些。
如果文字很多，可以设高一些。

可以设置更多地交互在上面。调用时传入设置参数即可。

以下为完整代码：

```java
public class ConfirmDialog extends Dialog {

    private static final float DEFAULT_HEIGHT_RATIO = 0.25F;
    private static final float DEFAULT_WIDTH_RATIO = 0.85F;

    private Context context;
    private CharSequence msg;
    private CharSequence leftButtonText;
    private CharSequence rightButtonText;
    private OnClickListener onClickListener;
    private String titleText;

    private float heightRatio = DEFAULT_HEIGHT_RATIO;
    private float widthRatio = DEFAULT_WIDTH_RATIO;

    private boolean hasButtons = true;

    public interface OnClickListener {
        void clickLeft();

        void clickRight();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        init();
    }

    public void init() {
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.confirm_dialog, null);
        setContentView(view);

        TextView msgTv = (TextView) view.findViewById(R.id.confirm_msg_tv);
        Button leftBtn = (Button) view.findViewById(R.id.confirm_btn_left);
        Button rightBtn = (Button) view.findViewById(R.id.confirm_btn_right);
        TextView titleTv = (TextView) view.findViewById(R.id.confirm_title_tv);
        View divider = view.findViewById(R.id.confirm_divider);

        msgTv.setText(msg);
        leftBtn.setText(leftButtonText);
        rightBtn.setText(rightButtonText);

        leftBtn.setOnClickListener(new clickListener());
        rightBtn.setOnClickListener(new clickListener());

        if (TextUtils.isEmpty(titleText)) {
            divider.setVisibility(View.GONE);
            titleTv.setVisibility(View.GONE);
        } else {
            divider.setVisibility(View.VISIBLE);// 自己画的分隔线
            titleTv.setText(titleText);
            msgTv.setTextColor(Color.WHITE);
        }

        if (!hasButtons) {
            leftBtn.setVisibility(View.GONE);
            rightBtn.setVisibility(View.GONE);
        }

        Window dialogWindow = getWindow();
        WindowManager.LayoutParams lp = dialogWindow.getAttributes();
        DisplayMetrics d = context.getResources().getDisplayMetrics();
        lp.width = (int) (d.widthPixels * widthRatio);
        lp.height = (int) (d.heightPixels * heightRatio);
        dialogWindow.setAttributes(lp);
    }

    private class clickListener implements View.OnClickListener {
        @Override
        public void onClick(View v) {
            int id = v.getId();
            switch (id) {
                case R.id.confirm_btn_left:
                    onClickListener.clickLeft();
                    dismiss();
                    break;
                case R.id.confirm_btn_right:
                    onClickListener.clickRight();
                    dismiss();
                    break;
            }
        }

    }

    public static class Builder {
        private Context context;
        private CharSequence msg;
        private CharSequence leftButtonText;
        private CharSequence rightButtonText;
        private OnClickListener onClickListener;
        private String titleText;

        private float heightRatio = DEFAULT_HEIGHT_RATIO;
        private float widthRatio = DEFAULT_WIDTH_RATIO;
        private boolean hasButtons = true;

        /**
         * @param context Needs activity instance
         */
        public Builder(Context context) {
            this.context = context;
        }

        public Builder setMsg(CharSequence msg) {
            this.msg = msg;
            return this;
        }

        public Builder setLeftButtonText(CharSequence leftButtonText) {
            this.leftButtonText = leftButtonText;
            return this;
        }

        public Builder setRightButtonText(CharSequence rightButtonText) {
            this.rightButtonText = rightButtonText;
            return this;
        }

        public Builder setOnClickListener(OnClickListener onClickListener) {
            this.onClickListener = onClickListener;
            return this;
        }

        public Builder setTitleText(CharSequence titleText) {
            this.titleText = titleText.toString();
            return this;
        }

        public Builder hasButton(boolean hasButtons) {
            this.hasButtons = hasButtons;
            return this;
        }

        public Builder setHeightRatio(float heightRatio) {
            this.heightRatio = heightRatio;
            return this;
        }

        public Builder setWidthRatio(float widthRatio) {
            this.widthRatio = widthRatio;
            return this;
        }

        public ConfirmDialog create() {
            return new ConfirmDialog(context, this);
        }

        public ConfirmDialog show() {
            final ConfirmDialog confirmDialog = create();
            confirmDialog.show();
            return confirmDialog;
        }
    }

    private ConfirmDialog(Context context, Builder builder) {
        super(context, R.style.TransparentBgDialog);
        this.context = context;
        this.msg = builder.msg;
        this.leftButtonText = builder.leftButtonText;
        this.rightButtonText = builder.rightButtonText;
        this.heightRatio = builder.heightRatio;
        this.widthRatio = builder.widthRatio;
        this.titleText = builder.titleText;
        this.onClickListener = builder.onClickListener;
        this.hasButtons = builder.hasButtons;
    }
}
```

显示这个Dialog时需要Activity的实例

调用方法：
```java
new ConfirmDialog.Builder(Activity.this/*当前Activity*/).setMsg("是否保存？")
        .setLeftButtonText("yes")
        .setRightButtonText("no"))
        .setOnClickListener(new ConfirmDialog.OnClickListener() {
            @Override
            public void clickLeft() {
            }

            @Override
            public void clickRight() {
            }
        }).show();
```

附上`confirm_dialog.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="278dp"
    android:layout_height="180dp"
    android:background="#00000000">

    <View
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@mipmap/dialog_bg" />

    <RelativeLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout_margin="20dp">

        <Button
            android:id="@+id/confirm_btn_left"
            android:layout_width="90dp"
            android:layout_height="32dp"
            android:layout_alignParentBottom="true"
            android:layout_alignParentStart="true"
            android:layout_marginStart="14dp"
            android:background="@drawable/btn_light_bg"
            android:text="@string/cancel"
            android:textColor="#071228"
            android:textSize="16sp" />

        <Button
            android:id="@+id/confirm_btn_right"
            android:layout_width="90dp"
            android:layout_height="32dp"
            android:layout_alignParentBottom="true"
            android:layout_alignParentEnd="true"
            android:layout_marginEnd="14dp"
            android:background="@drawable/btn_light_bg"
            android:text="@string/yes"
            android:textColor="#071228"
            android:textSize="16sp" />

        <RelativeLayout
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:layout_above="@id/confirm_btn_left">

            <TextView
                android:id="@+id/confirm_title_tv"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_centerHorizontal="true"
                android:textAlignment="center"
                android:textColor="#c5dbeb"
                android:textSize="16.5sp" />

            <View
                android:id="@+id/confirm_divider"
                android:layout_width="match_parent"
                android:layout_height="0.5dp"
                android:layout_below="@id/confirm_title_tv"
                android:layout_centerVertical="true"
                android:layout_marginEnd="30dp"
                android:layout_marginStart="30dp"
                android:layout_marginTop="10dp"
                android:background="#7995aa" />

            <RelativeLayout
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:layout_below="@id/confirm_title_tv">

                <TextView
                    android:id="@+id/confirm_msg_tv"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_centerInParent="true"
                    android:layout_marginEnd="14dp"
                    android:layout_marginStart="14dp"
                    android:text="msg"
                    android:textAlignment="center"
                    android:textColor="#c5dbeb"
                    android:textSize="16sp" />

            </RelativeLayout>

        </RelativeLayout>
    </RelativeLayout>

</RelativeLayout>
```
