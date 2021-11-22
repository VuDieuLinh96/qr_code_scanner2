package com.google.zxing.client.android.camera.open;

import android.hardware.Camera;

import com.lynkmyu.qr_code_scanner2.readerView.SimpleLog;

public final class OpenCameraInterface {
    private static final String TAG = OpenCameraInterface.class.getName();

    private OpenCameraInterface() {
    }

    /** For {@link #open(int)}, means no preference for which google.zxing.client.android.android.com.google.zxing.client.android.camera to open. */
    public static final int NO_REQUESTED_CAMERA = -1;

    /**
     * Opens the requested google.zxing.client.android.android.com.google.zxing.client.android.camera with {@link Camera#open(int)}, if one exists.
     *
     * @param cameraId google.zxing.client.android.android.com.google.zxing.client.android.camera ID of the google.zxing.client.android.android.com.google.zxing.client.android.camera to use. A negative value
     *  or {@link #NO_REQUESTED_CAMERA} means "no preference", in which case a rear-facing
     *  google.zxing.client.android.android.com.google.zxing.client.android.camera is returned if possible or else any google.zxing.client.android.android.com.google.zxing.client.android.camera
     * @return handle to {@link com.google.zxing.client.android.camera.open.OpenCamera} that was opened
     */
    public static OpenCamera open(int cameraId) {

        int numCameras = Camera.getNumberOfCameras();
        if (numCameras == 0) {
            SimpleLog.w(TAG, "No cameras!");
            return null;
        }

        boolean explicitRequest = cameraId >= 0;

        Camera.CameraInfo selectedCameraInfo = null;
        int index;
        if (explicitRequest) {
            index = cameraId;
            selectedCameraInfo = new Camera.CameraInfo();
            Camera.getCameraInfo(index, selectedCameraInfo);
        } else {
            index = 0;
            while (index < numCameras) {
                Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
                Camera.getCameraInfo(index, cameraInfo);
                com.google.zxing.client.android.camera.open.CameraFacing reportedFacing = com.google.zxing.client.android.camera.open.CameraFacing.values()[cameraInfo.facing];
                if (reportedFacing == com.google.zxing.client.android.camera.open.CameraFacing.BACK) {
                    selectedCameraInfo = cameraInfo;
                    break;
                }
                index++;
            }
        }

        Camera camera;
        if (index < numCameras) {
            SimpleLog.i(TAG, "Opening google.zxing.client.android.android.com.google.zxing.client.android.camera #" + index);
            camera = Camera.open(index);
        } else {
            if (explicitRequest) {
                SimpleLog.w(TAG, "Requested google.zxing.client.android.android.com.google.zxing.client.android.camera does not exist: " + cameraId);
                camera = null;
            } else {
                SimpleLog.i(TAG, "No google.zxing.client.android.android.com.google.zxing.client.android.camera facing " + com.google.zxing.client.android.camera.open.CameraFacing.BACK + "; returning google.zxing.client.android.android.com.google.zxing.client.android.camera #0");
                camera = Camera.open(0);
                selectedCameraInfo = new Camera.CameraInfo();
                Camera.getCameraInfo(0, selectedCameraInfo);
            }
        }

        if (camera == null) {
            return null;
        }
        return new OpenCamera(index,
                camera,
                CameraFacing.values()[selectedCameraInfo.facing],
                selectedCameraInfo.orientation);
    }
}
