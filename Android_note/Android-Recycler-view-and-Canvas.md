---
title: 使用Recycler view和自定义UI来创建颜色选择板
date: 2016-08-09 21:39:12
category: Android_note
tag: [Android_UI]
toc: true
---

目的：使用Recycler view 和自定义UI来创建一个颜色选择板。  

### 实现的效果  

* 能够添加多个颜色，数量不定；能够滑动
* 选择板的选项有点击选中效果

效果图如下：  

![ColorBoard](https://raw.githubusercontent.com/RustFisher/aboutView/master/pics/ColorBoard.gif)

### 实现代码

| Files | Function |
|:------:|:------------|
|CircleImageView.java|自定义UI——圆点；这里是一个能改变颜色的圆点|
|ColorBoardListAdapter.java| RecyclerView.Adapter；用于适配 |
|color_item_view.xml| 圆点的布局文件 |
|attr.xml| 圆点的自定义属性 |
| ColorBoardActivity.java | 用于演示 |
| activity_color_board.xml | 用于演示 |

给RecyclerView设定点击事件，获取点击position；然后通知各个item，改变状态  
圆点的大小和背景大小是预先设定好的。

### 代码片段说明

`CircleImageView.java` 自定义圆点UI；一定要复写setSelected(boolean selected)方法  
```java
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        mPaint.setAntiAlias(true);
        mPaint.setStyle(Paint.Style.FILL);
        mPaint.setStrokeWidth(1.5f);
        if (mSelected) {
            mPaint.setColor(Color.WHITE);// 若被选中，则画一个圆形背景
            canvas.drawCircle(getWidth() / 2, getHeight() / 2, mRadius, mPaint);
        }
        mPaint.setColor(mColor);
        canvas.drawCircle(getWidth() / 2, getHeight() / 2, mRadius - 10, mPaint);
    }

    @Override
    public void setSelected(boolean selected) {
        mSelected = selected;// 确定此UI是否被选中
        super.setSelected(selected);
        invalidate();
    }
```

`ColorBoardListAdapter.java`适配器中默认点中的item position为-1  
```java
    // 供外部调用，获取点击的position；通知item更改
    public void setSelectedPosition(int position) {
        this.mSelectedPosition = position;
        notifyDataSetChanged();
        notifyItemChanged(position);
    }
// ......
    @Override
    public void onBindViewHolder(ViewHolder holder, final int position) {
        holder.mImageView.setColor(mDataList.get(position).color);
        holder.mImageView.setSelected(mSelectedPosition == position);// 判断是否被选中
        if (mOnItemClickListener != null) {
            holder.mImageView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mOnItemClickListener.onItemClick(v, position);
                }
            });
            holder.mImageView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    mOnItemClickListener.onItemLongClick(v, position);
                    return true;
                }
            });
        }
    }
```

`ColorBoardActivity.java`设定点击事件，然后传回点击position

```java
    private void initColorBoard() {
        final ArrayList<ColorBoardListAdapter.ColorItemViewEntity> colorItemEntities = new ArrayList<>();
        colorItemEntities.add(new ColorBoardListAdapter.ColorItemViewEntity(1, Color.rgb(0, 10, 50)));
        // 想加几个加几个......

        GridLayoutManager gridLayoutManager = new GridLayoutManager(this, 3);// 3行
        gridLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mColorBoard.setLayoutManager(gridLayoutManager);
        final ColorBoardListAdapter ColorBoardListAdapter = new ColorBoardListAdapter(colorItemEntities);
        ColorBoardListAdapter.setOnItemClickListener(new ColorBoardListAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                int clickID = colorItemEntities.get(position).id;
                int color = colorItemEntities.get(position).color;
                ColorBoardListAdapter.setSelectedPosition(position);// 点击item位置传回去
                Log.d(TAG, "onItemClick: " + clickID + ";  color = " + color);
            }

            @Override
            public void onItemLongClick(View view, int position) {

            }
        });
        mColorBoard.setAdapter(ColorBoardListAdapter);
    }
```

使用RecyclerView，添加子项非常方便。扩展也很方便。

项目地址： https://github.com/RustFisher/aboutView   

参考：
http://stackoverflow.com/questions/27194044/how-to-properly-highlight-selected-item-on-recyclerview
