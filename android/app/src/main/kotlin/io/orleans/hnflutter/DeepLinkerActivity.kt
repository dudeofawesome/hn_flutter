package io.orleans.hnflutter

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log

class DeepLinkerActivity: Activity() {

  private val LOG_TAG = "Kotlin: A:Main"

  override fun onCreate (savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    Log.d(LOG_TAG, "DEEP LINK ACTIVITY CREATED")
  }

  override fun onResume() {
    super.onResume()
    Log.d(LOG_TAG, "DEEP LINK ACTIVITY RESUMED")
    Log.d(LOG_TAG, intent.toString())
  }
}
