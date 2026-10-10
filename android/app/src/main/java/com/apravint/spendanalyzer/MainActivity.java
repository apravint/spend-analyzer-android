package com.apravint.spendanalyzer;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Vibrator;
import android.provider.Telephony;
import android.webkit.JavascriptInterface;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import org.json.JSONObject;

public class MainActivity extends Activity {
    private static MainActivity instance;
    private WebView webView;
    private static final int SMS_PERMISSION_CODE = 101;

    public static MainActivity getInstance() {
        return instance;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        instance = this;

        webView = new WebView(this);
        setContentView(webView);

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(true);
        settings.setAllowContentAccess(true);
        settings.setDatabaseEnabled(true);

        webView.addJavascriptInterface(new SmsBridge(this), "AndroidBridge");

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                if (request.isForMainFrame()) {
                    view.loadUrl("file:///android_asset/index.html");
                }
            }
        });

        webView.loadUrl("file:///android_asset/web/index.html");

        checkAndRequestSmsPermissions();
    }

    private void checkAndRequestSmsPermissions() {
        if (checkSelfPermission(Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED ||
            checkSelfPermission(Manifest.permission.RECEIVE_SMS) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(new String[]{
                Manifest.permission.READ_SMS,
                Manifest.permission.RECEIVE_SMS
            }, SMS_PERMISSION_CODE);
        }
    }

    public void handleIncomingSms(String sender, String body, long timestamp) {
        if (webView != null) {
            runOnUiThread(() -> {
                try {
                    String cleanSender = JSONObject.quote(sender);
                    String cleanBody = JSONObject.quote(body);
                    String script = String.format("if (window.onSmsReceived) { window.onSmsReceived(%s, %s, %d); }",
                            cleanSender, cleanBody, timestamp);
                    webView.evaluateJavascript(script, null);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        }
    }

    public class SmsBridge {
        private Context context;

        public SmsBridge(Context context) {
            this.context = context;
        }

        @JavascriptInterface
        public void vibrate(long milliseconds) {
            Vibrator v = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
            if (v != null && v.hasVibrator()) {
                v.vibrate(milliseconds);
            }
        }

        @JavascriptInterface
        public void showToast(String message) {
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
        }

        @JavascriptInterface
        public void syncDeviceSms() {
            if (checkSelfPermission(Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.READ_SMS}, SMS_PERMISSION_CODE);
                showToast("Please grant SMS permission to sync transactions.");
                return;
            }

            new Thread(() -> {
                int count = 0;
                try {
                    Uri inboxUri = Uri.parse("content://sms/inbox");
                    String[] projection = new String[]{"address", "body", "date"};
                    Cursor cursor = getContentResolver().query(inboxUri, projection, null, null, "date DESC LIMIT 150");

                    if (cursor != null) {
                        int addressCol = cursor.getColumnIndex("address");
                        int bodyCol = cursor.getColumnIndex("body");
                        int dateCol = cursor.getColumnIndex("date");

                        while (cursor.moveToNext()) {
                            String address = cursor.getString(addressCol);
                            String body = cursor.getString(bodyCol);
                            long date = cursor.getLong(dateCol);

                            if (address != null && body != null) {
                                final String fAddress = address;
                                final String fBody = body;
                                final long fDate = date;

                                runOnUiThread(() -> {
                                    handleIncomingSms(fAddress, fBody, fDate);
                                });
                                count++;
                            }
                        }
                        cursor.close();
                    }

                    final int finalCount = count;
                    runOnUiThread(() -> showToast("Parsed " + finalCount + " SMS messages from inbox."));
                } catch (Exception e) {
                    e.printStackTrace();
                    runOnUiThread(() -> showToast("Error reading SMS inbox: " + e.getMessage()));
                }
            }).start();
        }
    }

    @Override
    public void onBackPressed() {
        if (webView != null && webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
