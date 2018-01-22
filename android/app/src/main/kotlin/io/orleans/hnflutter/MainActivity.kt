package io.orleans.hnflutter

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

import io.orleans.hnflutter.constants.Channels

class MainActivity: FlutterActivity() {

  private val LOG_TAG = "Android: A:Main"
  private var deepLinkChannel: MethodChannel? = null

  override fun onCreate (savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    deepLinkChannel = MethodChannel(flutterView, Channels.DEEP_LINK_RECEIVED)

    val route = checkForLinkEvent(intent)
    if (route != null) {
      Log.d(LOG_TAG, "setting initial route to $route")
      flutterView.setInitialRoute(route)
    }
  }

  override fun onResume() {
    super.onResume()

    checkForLinkEvent(intent)
  }

  override fun onNewIntent(intent: Intent?) {
    super.onNewIntent(intent)
    setIntent(intent)
  }

  private fun checkForLinkEvent (intent: Intent): String? {
    Log.d(LOG_TAG, "CHECKING INTENT FOR LINK")
    Log.d(LOG_TAG, intent.toString())
    Log.d(LOG_TAG, intent.action?.toString() ?: "no action")
    Log.d(LOG_TAG, intent.data?.toString() ?: "no data")

    if (intent.action == Intent.ACTION_VIEW && intent.data != null) {
      val regex = Regex("""id=([0-9]+)(?:$|&)""")
      val itemId = regex.matchEntire(intent.data.query)?.groups?.get(1)?.value
      val route = "${intent.data.path}:$itemId"

      // val passedObjs = mutableMapOf<String, Any>("route" to route)
      // deepLinkChannel?.invokeMethod("linkReceived", passedObjs)
      flutterView.pushRoute(route)
      Log.d(LOG_TAG, "Sent message to flutter: linkReceived=$route")
      return route
    }

    return null
  }
}
