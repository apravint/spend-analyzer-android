package com.apravint.spendanalyzer;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.provider.Telephony;
import android.telephony.SmsMessage;

public class SmsBroadcastReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION.equals(intent.getAction())) {
            SmsMessage[] messages = Telephony.Sms.Intents.getMessagesFromIntent(intent);
            if (messages != null && messages.length > 0) {
                MainActivity activity = MainActivity.getInstance();
                if (activity != null) {
                    for (SmsMessage sms : messages) {
                        String sender = sms.getOriginatingAddress();
                        String body = sms.getMessageBody();
                        long timestamp = sms.getTimestampMillis();
                        if (sender != null && body != null) {
                            activity.handleIncomingSms(sender, body, timestamp);
                        }
                    }
                }
            }
        }
    }
}
