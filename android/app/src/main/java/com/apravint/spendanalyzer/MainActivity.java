package com.apravint.spendanalyzer;

import android.Manifest;
import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Vibrator;
import android.provider.Settings;
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

        // App opens cleanly with ZERO permission popups on startup
        webView.loadUrl("file:///android_asset/web/index.html");
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

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == SMS_PERMISSION_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "Permission granted! Reading bank SMS...", Toast.LENGTH_SHORT).show();
                readInboxSmsInternal();
            } else {
                Toast.makeText(this, "SMS Permission restricted or not granted.", Toast.LENGTH_SHORT).show();
                if (webView != null) {
                    webView.evaluateJavascript("if (window.onPermissionDenied) { window.onPermissionDenied(); }", null);
                }
            }
        }
    }

    public void readInboxSmsInternal() {
        new Thread(() -> {
            int count = 0;
            try {
                Uri inboxUri = Uri.parse("content://sms/inbox");
                String[] projection = new String[]{"address", "body", "date"};
                // Use standard sort order without LIMIT clause for maximum OEM compatibility
                Cursor cursor = getContentResolver().query(inboxUri, projection, null, null, "date DESC");
                if (cursor == null) {
                    cursor = getContentResolver().query(Uri.parse("content://sms"), projection, null, null, "date DESC");
                }

                if (cursor != null) {
                    int addressCol = cursor.getColumnIndex("address");
                    int bodyCol = cursor.getColumnIndex("body");
                    int dateCol = cursor.getColumnIndex("date");

                    while (cursor.moveToNext() && count < 250) {
                        String address = cursor.getString(addressCol);
                        String body = cursor.getString(bodyCol);
                        long date = cursor.getLong(dateCol);

                        if (address != null && body != null) {
                            final String fAddress = address;
                            final String fBody = body;
                            final long fDate = date;

                            runOnUiThread(() -> handleIncomingSms(fAddress, fBody, fDate));
                            count++;
                        }
                    }
                    cursor.close();
                }

                final int finalCount = count;
                runOnUiThread(() -> {
                    Toast.makeText(this, "Synced " + finalCount + " SMS messages locally.", Toast.LENGTH_SHORT).show();
                    if (webView != null) {
                        webView.evaluateJavascript("if (window.onSyncFinished) { window.onSyncFinished(" + finalCount + "); }", null);
                    }
                });
            } catch (SecurityException se) {
                se.printStackTrace();
                runOnUiThread(() -> {
                    Toast.makeText(this, "SMS Permission restricted by Android.", Toast.LENGTH_LONG).show();
                    if (webView != null) {
                        webView.evaluateJavascript("if (window.onPermissionDenied) { window.onPermissionDenied(); }", null);
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
                runOnUiThread(() -> Toast.makeText(this, "Error reading inbox: " + e.getMessage(), Toast.LENGTH_LONG).show());
            }
        }).start();
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
            runOnUiThread(() -> Toast.makeText(context, message, Toast.LENGTH_SHORT).show());
        }

        @JavascriptInterface
        public boolean hasSmsPermission() {
            return checkSelfPermission(Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED;
        }

        @JavascriptInterface
        public void syncDeviceSms() {
            // Must run on UI Thread so Android shows permission dialog properly
            runOnUiThread(() -> {
                if (checkSelfPermission(Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
                    requestPermissions(new String[]{Manifest.permission.READ_SMS}, SMS_PERMISSION_CODE);
                } else {
                    readInboxSmsInternal();
                }
            });
        }

        @JavascriptInterface
        public void openAppSettings() {
            runOnUiThread(() -> {
                try {
                    Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                    intent.setData(Uri.parse("package:" + getPackageName()));
                    startActivity(intent);
                } catch (Exception e) {
                    Toast.makeText(context, "Please open Settings > Apps > SpendAnalyzer", Toast.LENGTH_LONG).show();
                }
            });
        }

        @JavascriptInterface
        public String getClipboardText() {
            try {
                ClipboardManager clipboard = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
                if (clipboard != null && clipboard.hasPrimaryClip()) {
                    ClipData clip = clipboard.getPrimaryClip();
                    if (clip != null && clip.getItemCount() > 0) {
                        CharSequence text = clip.getItemAt(0).getText();
                        return text != null ? text.toString() : "";
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return "";
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
