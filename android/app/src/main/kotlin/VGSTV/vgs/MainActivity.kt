package com.vgstv.radioapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CONFIG_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getYoutubeChannelId" -> {
                    try {
                        val id = getString(R.string.youtube_channel_id)
                        if (id.isNotBlank()) {
                            result.success(id)
                        } else {
                            result.error("EMPTY", "youtube_channel_id vazio", null)
                        }
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    companion object {
        private const val CONFIG_CHANNEL = "com.vgstv.radioapp/config"
    }
}
