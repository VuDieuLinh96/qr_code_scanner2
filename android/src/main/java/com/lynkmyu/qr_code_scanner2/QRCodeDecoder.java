package com.lynkmyu.qr_code_scanner2;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.util.Log;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.LuminanceSource;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.NotFoundException;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.common.GlobalHistogramBinarizer;
import com.google.zxing.common.HybridBinarizer;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

import com.lynkmyu.qr_code_scanner2.reader.MyMultiFormatReader;

public class QRCodeDecoder {
    private static Context context;
    public static final Map<DecodeHintType, Object> HINTS = new EnumMap<>(DecodeHintType.class);
    private static final String TAG = "QRCodeDecoder";

    static {
        List<BarcodeFormat> allFormats = new ArrayList<>();
        allFormats.add(BarcodeFormat.AZTEC);
        allFormats.add(BarcodeFormat.CODABAR);
        allFormats.add(BarcodeFormat.CODE_39);
        allFormats.add(BarcodeFormat.CODE_93);
        allFormats.add(BarcodeFormat.CODE_128);
        allFormats.add(BarcodeFormat.DATA_MATRIX);
        allFormats.add(BarcodeFormat.EAN_8);
        allFormats.add(BarcodeFormat.EAN_13);
        allFormats.add(BarcodeFormat.ITF);
        allFormats.add(BarcodeFormat.MAXICODE);
        allFormats.add(BarcodeFormat.PDF_417);
        allFormats.add(BarcodeFormat.QR_CODE);
        allFormats.add(BarcodeFormat.RSS_14);
        allFormats.add(BarcodeFormat.RSS_EXPANDED);
        allFormats.add(BarcodeFormat.UPC_A);
        allFormats.add(BarcodeFormat.UPC_E);
        allFormats.add(BarcodeFormat.UPC_EAN_EXTENSION);
        HINTS.put(DecodeHintType.TRY_HARDER, BarcodeFormat.QR_CODE);
        HINTS.put(DecodeHintType.POSSIBLE_FORMATS, allFormats);
        HINTS.put(DecodeHintType.CHARACTER_SET, "utf-8");
    }
    private QRCodeDecoder() {
    }

    public static String syncDecodeQRCode(Context context, String picturePath) {
        return syncDecodeQRCode(context, getDecodeAbleBitmap(picturePath));
    }

    public static String syncDecodeQRCode(Context context, Bitmap bitmap) {
        QRCodeDecoder.context = context;
        Result result = null;
        MyMultiFormatReader multiFormatReader = new MyMultiFormatReader();
        multiFormatReader.setHints(HINTS);
        try {
            int width = bitmap.getWidth();
            int height = bitmap.getHeight();
            
            int[] pixels = new int[width * height];
            bitmap.getPixels(pixels, 0, width, 0, 0, width, height);

            RGBLuminanceSource source = new RGBLuminanceSource(width, height, pixels);
            BinaryBitmap bitmap1 = new BinaryBitmap(new HybridBinarizer(source));
            result = multiFormatReader.decodeWithState(bitmap1);
            Log.i(TAG, "syncDecodeQRCode: " + result);
            return result.getText();
        } catch (Exception e) {
            e.printStackTrace();
            multiFormatReader.reset();
            try {
                Matrix matrix = new Matrix();
                matrix.setRotate(90);
               
                Bitmap resizedBitmap = Bitmap.createBitmap(bitmap, 0, 0,
                        bitmap.getWidth(), bitmap.getHeight(), matrix, true);
                int width = resizedBitmap.getWidth();
                int height = resizedBitmap.getHeight();
                Log.i(TAG, "syncDecodeQRCode: " + width + "--" + height);

                int[] pixels = new int[width * height];
                resizedBitmap.getPixels(pixels, 0, width, 0, 0, width, height);
                RGBLuminanceSource source = new RGBLuminanceSource(width, height, pixels);
                result = multiFormatReader.decode(new BinaryBitmap(new HybridBinarizer(source)), HINTS);
                return result.getText();
            } catch (Throwable e2) {
                e2.printStackTrace();
            }
            return null;
        }
    }

    private static Bitmap getDecodeAbleBitmap(String picturePath) {
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeFile(picturePath, options);
            int sampleSize = options.outWidth / 400;
            if (sampleSize <= 0) {
                sampleSize = 1;
            }
            options.inSampleSize = sampleSize;
            options.inJustDecodeBounds = false;
            Bitmap bitmap = BitmapFactory.decodeFile(picturePath, options);
            Matrix matrix = new Matrix();
            matrix.setRotate(90);
            Bitmap resizedBitmap = Bitmap.createBitmap(bitmap, 0, 0,
                    bitmap.getWidth(), bitmap.getHeight(), matrix, true);
            return resizedBitmap;
        } catch (Exception e) {
            return null;
        }
    }
}
