package com.example.fitsync_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine  // Add this import
import io.flutter.embedding.engine.plugins.FlutterPlugin
import com.baseflow.permissionhandler.PermissionHandlerPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Manually register the permission_handler plugin
        flutterEngine.plugins.add(PermissionHandlerPlugin())
    }
}