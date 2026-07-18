package com.example.flutter_todo_app

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.widget.RemoteViews
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.Rect
import android.graphics.RectF

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_todo_app/notifications"
    private val NOTIFICATION_CHANNEL_ID = "todo_notifications"
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1001
    private var notificationIdCounter = 1000

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestNotificationPermissionIfNeeded()
    }

    // Android 13+ requires runtime permission to post notifications.
    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ActivityCompat.checkSelfPermission(
                    this, Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this, arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_REQUEST_CODE
                )
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showNotification" -> {
                        val title = call.argument<String>("title") ?: "Todo"
                        val body = call.argument<String>("body") ?: ""
                        val profileName = call.argument<String>("profileName") ?: "User"
                        showCustomNotification(title, body, profileName)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Todo Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications shown when a new todo is added"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    // Builds a custom RemoteViews layout (profile pic + title + body + Like
    // button) rather than the default template. The Like button has no
    // click handler attached, matching the "non-functional" requirement.
    private fun showCustomNotification(title: String, body: String, profileName: String) {
        createNotificationChannel()

        val contentView = RemoteViews(packageName, R.layout.notification_custom)
        contentView.setTextViewText(R.id.notification_title, title)
        contentView.setTextViewText(R.id.notification_body, body)

        val profileBitmap = BitmapFactory.decodeResource(resources, R.drawable.profile_photo)
        contentView.setImageViewBitmap(
            R.id.notification_profile_image,
            getCircularBitmap(profileBitmap)
        )

        val builder = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setCustomContentView(contentView)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)

        val canPost = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            ActivityCompat.checkSelfPermission(
                this, Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED

        if (canPost) {
            NotificationManagerCompat.from(this).notify(notificationIdCounter++, builder.build())
        }
    }

    // Crops a rectangular bitmap into a circle (center-cropped) for the avatar.
    private fun getCircularBitmap(bitmap: Bitmap): Bitmap {
        val size = minOf(bitmap.width, bitmap.height)
        val output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val rect = Rect(0, 0, size, size)

        canvas.drawARGB(0, 0, 0, 0)
        paint.color = Color.WHITE
        canvas.drawOval(RectF(rect), paint)

        paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
        val srcLeft = (bitmap.width - size) / 2
        val srcTop = (bitmap.height - size) / 2
        val srcRect = Rect(srcLeft, srcTop, srcLeft + size, srcTop + size)
        canvas.drawBitmap(bitmap, srcRect, rect, paint)

        return output
    }
}
