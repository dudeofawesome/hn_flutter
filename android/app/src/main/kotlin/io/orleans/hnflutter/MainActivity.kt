package io.orleans.hnflutter

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.WindowManager.LayoutParams

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.view.FlutterView

import io.orleans.hnflutter.constants.Channels

class MainActivity: FlutterActivity() {

  private val LOG_TAG = "Android: A:Main"
  private var deepLinkChannel: MethodChannel? = null

  override fun onCreate (savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    deepLinkChannel = MethodChannel(flutterView, Channels.DEEP_LINK_RECEIVED)
  }

  override fun createFlutterView (context: Context): FlutterView {
    val view = FlutterView(this)
    view.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
    setContentView(view)

    val route = checkForLinkEvent(intent, false)
    if (route != null) {
      view.setInitialRoute(route)
    }

    return view
  }

  override fun onResume() {
    super.onResume()

    checkForLinkEvent(intent)
  }

  override fun onNewIntent(intent: Intent?) {
    super.onNewIntent(intent)
    setIntent(intent)
  }

  private fun checkForLinkEvent (intent: Intent, pushRoute: Boolean = true): String? {
    if (intent.action == Intent.ACTION_VIEW && intent.data != null) {
      val regex = Regex("""id=([0-9]+)(?:$|&)""")
      val itemId = regex.matchEntire(intent.data.query)?.groups?.get(1)?.value
      val route = "${intent.data.path}:$itemId"

      if (pushRoute) {
        // val passedObjs = mutableMapOf<String, Any>("route" to route)
        // deepLinkChannel?.invokeMethod("linkReceived", passedObjs)
        flutterView.pushRoute(route)
        Log.d(LOG_TAG, "Sent message to flutter: linkReceived=$route")
      }

      return route
    }

    return null
  }
}
