package com.example.delivery_app // KEEP YOUR OWN package line here

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createOrderChannel()
    }

    // A "high importance" channel makes notifications pop up and make a sound.
    private fun createOrderChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "orders_channel",
                "Order updates",
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = "New orders and order status updates"

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}