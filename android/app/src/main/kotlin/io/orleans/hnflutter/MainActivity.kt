package io.orleans.hnflutter

import android.content.Intent
import android.net.Uri
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

import io.orleans.hnflutter.constants.Channels

class MainActivity(): FlutterActivity() {
  private var deepLinkChannel: MethodChannel? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    deepLinkChannel = MethodChannel(flutterView, Channels.DEEP_LINK_RECEIVED)
  }
}
