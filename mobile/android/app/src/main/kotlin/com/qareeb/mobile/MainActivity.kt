package com.qareeb.mobile

import android.annotation.SuppressLint
import android.location.Location
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.location.LocationListenerCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * GPS-only location. Network, Wi-Fi, fused, cached, and mock fixes are ignored.
 */
class MainActivity : FlutterFragmentActivity() {
    private var locationManager: LocationManager? = null
    private var streamListener: LocationListenerCompat? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        locationManager = getSystemService(LOCATION_SERVICE) as LocationManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GPS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getGpsFix" -> {
                        val timeoutMs = call.argument<Int>("timeoutMs") ?: 25000
                        requestSingleGpsFix(timeoutMs, result)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, GPS_STREAM)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    startGpsStream(events)
                }

                override fun onCancel(arguments: Any?) {
                    stopGpsStream()
                }
            })
    }

    @SuppressLint("MissingPermission")
    private fun requestSingleGpsFix(timeoutMs: Int, result: MethodChannel.Result) {
        val manager = locationManager
        if (manager == null || !manager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
            result.error("GPS_DISABLED", "GPS provider is off", null)
            return
        }

        var completed = false
        val handler = Handler(Looper.getMainLooper())
        lateinit var listener: LocationListenerCompat
        val timeout = Runnable {
            if (completed) return@Runnable
            completed = true
            manager.removeUpdates(listener)
            result.error("GPS_TIMEOUT", "No satellite GPS fix", null)
        }

        listener = object : LocationListenerCompat {
            override fun onLocationChanged(location: Location) {
                if (completed || !isSatelliteFix(location)) return
                completed = true
                handler.removeCallbacks(timeout)
                manager.removeUpdates(this)
                result.success(locationToMap(location))
            }
        }

        try {
            manager.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                0L,
                0f,
                listener,
                Looper.getMainLooper(),
            )
            handler.postDelayed(timeout, timeoutMs.toLong().coerceAtLeast(1000L))
        } catch (error: SecurityException) {
            if (!completed) {
                completed = true
                result.error("GPS_PERMISSION", error.message, null)
            }
        }
    }

    @SuppressLint("MissingPermission")
    private fun startGpsStream(events: EventChannel.EventSink?) {
        val manager = locationManager
        if (manager == null || events == null) return
        if (!manager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
            events.error("GPS_DISABLED", "GPS provider is off", null)
            return
        }

        stopGpsStream()
        val listener = object : LocationListenerCompat {
            override fun onLocationChanged(location: Location) {
                if (!isSatelliteFix(location)) return
                events.success(locationToMap(location))
            }
        }
        streamListener = listener
        try {
            manager.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                1000L,
                0f,
                listener,
                Looper.getMainLooper(),
            )
        } catch (error: SecurityException) {
            events.error("GPS_PERMISSION", error.message, null)
            streamListener = null
        }
    }

    private fun stopGpsStream() {
        streamListener?.let { listener ->
            locationManager?.removeUpdates(listener)
        }
        streamListener = null
    }

    private fun isSatelliteFix(location: Location): Boolean {
        val provider = location.provider
        if (provider != null && provider != LocationManager.GPS_PROVIDER) return false
        if (isMocked(location)) return false
        if (!location.hasAccuracy()) return false
        val accuracy = location.accuracy
        if (accuracy <= 0f || accuracy > MAX_GPS_ACCURACY_METERS) return false
        val ageMs = System.currentTimeMillis() - location.time
        if (ageMs > MAX_FIX_AGE_MS || ageMs < -5_000L) return false
        if (location.latitude == 0.0 && location.longitude == 0.0) return false
        return true
    }

    private fun isMocked(location: Location): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            location.isMock
        } else {
            @Suppress("DEPRECATION")
            location.isFromMockProvider
        }
    }

    private fun locationToMap(location: Location): Map<String, Any> {
        return mapOf(
            "latitude" to location.latitude,
            "longitude" to location.longitude,
            "accuracy" to location.accuracy.toDouble(),
            "timestamp" to location.time,
        )
    }

    override fun onDestroy() {
        stopGpsStream()
        super.onDestroy()
    }

    companion object {
        private const val GPS_CHANNEL = "com.qareeb.mobile/gps"
        private const val GPS_STREAM = "com.qareeb.mobile/gps_stream"
        private const val MAX_GPS_ACCURACY_METERS = 50f
        private const val MAX_FIX_AGE_MS = 15_000L
    }
}
