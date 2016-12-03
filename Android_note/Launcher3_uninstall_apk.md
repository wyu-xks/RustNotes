---
title: Android Launcher3 workspace 删除apk图标改为卸载apk
date: 2015-08-08 11:20:09
category: Android_note
tag: [Android_frameworks]
---

### 删除图标，apk界面；那个X
“删除应用”和“应用信息”界面  
packages/apps/Trebuchet/res/layout/search_drop_target_bar.xml  
packages/apps/Trebuchet/res/layout/drop_target_bar.xml

图标拖上去，“叉子”由白变红  
drop_target_bar里引用  
packages/apps/Trebuchet/res/drawable/remove_target_selector.xml

workspace拖动图标显示的Remove界面，和allApp拖动apk的删除界面是同一个文件定义的  
都由 com.android.launcher3.DeleteDropTarget 控制

### 删除apk指令

packages/apps/Trebuchet/src/com/android/launcher3/Launcher.java

```java
    // returns true if the activity was started
    boolean startApplicationUninstallActivity(ComponentName componentName, int flags,
            UserHandleCompat user) {
        if ((flags & AppInfo.DOWNLOADED_FLAG) == 0) {
            // System applications cannot be installed. For now, show a toast explaining that.
            // We may give them the option of disabling apps this way.
            int messageId = R.string.uninstall_system_app_text;
            Toast.makeText(this, messageId, Toast.LENGTH_SHORT).show();
            return false;
        } else {
            String packageName = componentName.getPackageName();
            String className = componentName.getClassName();
            Intent intent = new Intent(
                    Intent.ACTION_DELETE, Uri.fromParts("package", packageName, className));
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK |
                    Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
            if (user != null) {
                user.addToIntent(intent, Intent.EXTRA_USER);
            }
            startActivity(intent);
            return true;
        }
    }
```

packages/apps/Trebuchet/src/com/android/launcher3/DeleteDropTarget.java

```java
    private void completeDrop(DragObject d) {
        ItemInfo item = (ItemInfo) d.dragInfo;
        boolean wasWaitingForUninstall = mWaitingForUninstall;
        mWaitingForUninstall = false;
        if (isAllAppsApplication(d.dragSource, item)) {
            // Uninstall the application if it is being dragged from AppsCustomize
            AppInfo appInfo = (AppInfo) item;
            mLauncher.startApplicationUninstallActivity(appInfo.componentName, appInfo.flags,
                    appInfo.user);
        } else if (isUninstallFromWorkspace(d)) {
            ShortcutInfo shortcut = (ShortcutInfo) item;
            if (shortcut.intent != null && shortcut.intent.getComponent() != null) {
                final ComponentName componentName = shortcut.intent.getComponent();
                final DragSource dragSource = d.dragSource;
                final UserHandleCompat user = shortcut.user;
                mWaitingForUninstall = mLauncher.startApplicationUninstallActivity(
                        componentName, shortcut.flags, user);
                if (mWaitingForUninstall) {
                    final Runnable checkIfUninstallWasSuccess = new Runnable() {
                        @Override
                        public void run() {
                            mWaitingForUninstall = false;
                            String packageName = componentName.getPackageName();
                            boolean uninstallSuccessful = !AllAppsList.packageHasActivities(
                                    getContext(), packageName, user);
                            if (dragSource instanceof Folder) {
                                ((Folder) dragSource).
                                    onUninstallActivityReturned(uninstallSuccessful);
                            } else if (dragSource instanceof Workspace) {
                                ((Workspace) dragSource).
                                    onUninstallActivityReturned(uninstallSuccessful);
                            }
                        }
                    };
                    mLauncher.addOnResumeCallback(checkIfUninstallWasSuccess);
                }
            }
        } else if (isWorkspaceOrFolderApplication(d)) {
            LauncherModel.deleteItemFromDatabase(mLauncher, item);
        } else if (isWorkspaceFolder(d)) {
            // Remove the folder from the workspace and delete the contents from launcher model
            FolderInfo folderInfo = (FolderInfo) item;
            mLauncher.removeFolder(folderInfo);
            LauncherModel.deleteFolderContentsFromDatabase(mLauncher, folderInfo);
        } else if (isWorkspaceOrFolderWidget(d)) {
            // Remove the widget from the workspace
            mLauncher.removeAppWidget((LauncherAppWidgetInfo) item);
            LauncherModel.deleteItemFromDatabase(mLauncher, item);

            final LauncherAppWidgetInfo launcherAppWidgetInfo = (LauncherAppWidgetInfo) item;
            final LauncherAppWidgetHost appWidgetHost = mLauncher.getAppWidgetHost();
            if ((appWidgetHost != null) && launcherAppWidgetInfo.isWidgetIdValid()) {
                // Deleting an app widget ID is a void call but writes to disk before returning
                // to the caller...
                new AsyncTask<Void, Void, Void>() {
                    public Void doInBackground(Void ... args) {
                        appWidgetHost.deleteAppWidgetId(launcherAppWidgetInfo.appWidgetId);
                        return null;
                    }
                }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void) null);
            }
        }
        if (wasWaitingForUninstall && !mWaitingForUninstall) {
            if (d.dragSource instanceof Folder) {
                ((Folder) d.dragSource).onUninstallActivityReturned(false);
            } else if (d.dragSource instanceof Workspace) {
                ((Workspace) d.dragSource).onUninstallActivityReturned(false);
            }
        }
    }
```
DeleteDropTarget.java
```java
    public void onFlingToDelete(final DragObject d, int x, int y, PointF vel)

    private void animateToTrashAndCompleteDrop(final DragObject d)

```

### 删除workspace图标
src/com/android/launcher3/DragController.java
```java
    /**
     * Call this from a drag source view.
     */
    public boolean onTouchEvent(MotionEvent ev) {
        if (!mDragging) {
            return false;
        }
        // Update the velocity tracker
        acquireVelocityTrackerAndAddMovement(ev);

        final int action = ev.getAction();
        final int[] dragLayerPos = getClampedDragLayerPos(ev.getX(), ev.getY());
        final int dragLayerX = dragLayerPos[0];
        final int dragLayerY = dragLayerPos[1];

        switch (action) {
        case MotionEvent.ACTION_DOWN:
            // Remember where the motion event started
            mMotionDownX = dragLayerX;
            mMotionDownY = dragLayerY;

            if ((dragLayerX < mScrollZone) || (dragLayerX > mScrollView.getWidth() - mScrollZone)) {
                mScrollState = SCROLL_WAITING_IN_ZONE;
                mHandler.postDelayed(mScrollRunnable, SCROLL_DELAY);
            } else {
                mScrollState = SCROLL_OUTSIDE_ZONE;
            }
            handleMoveEvent(dragLayerX, dragLayerY);
            break;
        case MotionEvent.ACTION_MOVE:
            handleMoveEvent(dragLayerX, dragLayerY);
            break;
        case MotionEvent.ACTION_UP:
            // Ensure that we've processed a move event at the current pointer location.
            handleMoveEvent(dragLayerX, dragLayerY);
            mHandler.removeCallbacks(mScrollRunnable);
            if (mDragging) {
                PointF vec = isFlingingToDelete(mDragObject.dragSource);

                if (!DeleteDropTarget.willAcceptDrop(mDragObject.dragInfo)) {
                    vec = null;
                }
                if (vec != null) {
                    dropOnFlingToDeleteTarget(dragLayerX, dragLayerY, vec);
                } else {
                    drop(dragLayerX, dragLayerY);// vec = null 进入drop
                }
            }
            endDrag();
            break;
        case MotionEvent.ACTION_CANCEL:
            mHandler.removeCallbacks(mScrollRunnable);
            cancelDrag();
            break;
        }

        return true;
    }

......

    private void drop(float x, float y) {
        final int[] coordinates = mCoordinatesTemp;
        final DropTarget dropTarget = findDropTarget((int) x, (int) y, coordinates);

        mDragObject.x = coordinates[0];
        mDragObject.y = coordinates[1];
        boolean accepted = false;
        if (dropTarget != null) {
            mDragObject.dragComplete = true;
            dropTarget.onDragExit(mDragObject);
            if (dropTarget.acceptDrop(mDragObject)) {
                dropTarget.onDrop(mDragObject);
                accepted = true;
            }
        }
        // 使用 Workspace.java 回调方法，onDropCompleted
        mDragObject.dragSource.onDropCompleted((View) dropTarget, mDragObject, false, accepted);
    }

```

Workspace.java
```java
    /**
     * Called at the end of a drag which originated on the workspace.
     */
    public void onDropCompleted(final View target, final DragObject d,
            final boolean isFlingToDelete, final boolean success) {
        if (mDeferDropAfterUninstall) {
            mDeferredAction = new Runnable() {
                public void run() {
                    onDropCompleted(target, d, isFlingToDelete, success);
                    mDeferredAction = null;
                }
            };
            return;
        }

        boolean beingCalledAfterUninstall = mDeferredAction != null;
        // 这里的DragObject d是 com.android.launcher3.ShortcutInfo
        //com.android.launcher3.ShortcutInfo cannot be cast to com.android.launcher3.AppInfo
        if (success && !(beingCalledAfterUninstall && !mUninstallSuccessful)) {
            if (target != this && mDragInfo != null) {
                CellLayout parentCell = getParentCellLayoutForView(mDragInfo.cell);
                if (parentCell != null) {
                    parentCell.removeView(mDragInfo.cell);// 删除图标
                } else if (LauncherAppState.isDogfoodBuild()) {
                    throw new NullPointerException("mDragInfo.cell has null parent");
                }
                if (mDragInfo.cell instanceof DropTarget) {
                    mDragController.removeDropTarget((DropTarget) mDragInfo.cell);
                }
            }
        } else if (mDragInfo != null) {
        ......
```
