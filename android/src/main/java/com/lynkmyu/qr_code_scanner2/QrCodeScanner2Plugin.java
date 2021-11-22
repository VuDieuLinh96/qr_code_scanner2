package com.lynkmyu.qr_code_scanner2;

import android.annotation.SuppressLint;
import android.os.AsyncTask;

import java.io.File;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import com.lynkmyu.qr_code_scanner2.factorys.QrReaderFactory;

/** QrCodeScanner2Plugin */
public class QrCodeScanner2Plugin implements  MethodCallHandler {
    private static final String CHANNEL_NAME = "com.lynkmyu.qr_code_scanner2";
    private static final String CHANNEL_VIEW_NAME = "com.lynkmyu.qr_code_scanner2.reader_view";
  
  
    private  Registrar registrar;
  
    QrCodeScanner2Plugin(Registrar registrar) {
      this.registrar = registrar;
    }
  
    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
      final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
      registrar.platformViewRegistry().registerViewFactory(CHANNEL_VIEW_NAME, new QrReaderFactory(registrar));
      final QrCodeScanner2Plugin instance = new QrCodeScanner2Plugin(registrar);
      channel.setMethodCallHandler(instance);
    }
  
    @Override
    public void onMethodCall(MethodCall call, Result result) {
      if (call.method.equals("imgQrCode")) {
        imgQrCode(call, result);
      } else {
        result.notImplemented();
      }
    }
  
    @SuppressLint("StaticFieldLeak")
    void imgQrCode(MethodCall call, final Result result) {
      final String filePath = call.argument("file");
      if (filePath == null) {
        result.error("Not found data", null, null);
        return;
      }
      File file = new File(filePath);
      if (!file.exists()) {
        result.error("File not found", null, null);
      }
  
      new AsyncTask<String, Integer, String>() {
        @Override
        protected String doInBackground(String... params) {
          // 解析二维码/条码
          return QRCodeDecoder.syncDecodeQRCode(filePath);
        }
        @Override
        protected void onPostExecute(String s) {
          super.onPostExecute(s);
          if(null == s){
            result.error("not data", null, null);
          }else {
            result.success(s);
          }
        }
      }.execute(filePath);
    }
}
