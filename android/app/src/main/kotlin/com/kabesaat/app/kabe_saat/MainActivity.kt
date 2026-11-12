package com.kabesaat.app.kabe_saat

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(), SensorEventListener {
    private val COMPASS_CHANNEL = "com.kabesaat.app/compass"
    private val WIDGET_CHANNEL = "com.kabesaat.app/widget"
    private var sensorManager: SensorManager? = null
    private var rotationVectorSensor: Sensor? = null
    private var accelerometer: Sensor? = null
    private var magnetometer: Sensor? = null

    private var eventSink: EventChannel.EventSink? = null

    private val rotationMatrix = FloatArray(9)
    private val orientationAngles = FloatArray(3)
    private val lastAccelerometer = FloatArray(3)
    private val lastMagnetometer = FloatArray(3)
    private var lastAccelerometerSet = false
    private var lastMagnetometerSet = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        rotationVectorSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        magnetometer = sensorManager?.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, COMPASS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startSensors()
                }

                override fun onCancel(arguments: Any?) {
                    stopSensors()
                    eventSink = null
                }
            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateWidgetData") {
                try {
                    val prefs = getSharedPreferences(KabeSaatWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().apply {
                        putString("city_name", call.argument<String>("city_name") ?: "İstanbul")
                        putString("next_name", call.argument<String>("next_name") ?: "AKŞAM VAKTİ")
                        putString("next_time", call.argument<String>("next_time") ?: "18:04")
                        putString("countdown", call.argument<String>("countdown") ?: "")
                        putString("time_imsak", call.argument<String>("time_imsak") ?: "")
                        putString("time_ogle", call.argument<String>("time_ogle") ?: "")
                        putString("time_ikindi", call.argument<String>("time_ikindi") ?: "")
                        putString("time_aksam", call.argument<String>("time_aksam") ?: "")
                        putString("time_yatsi", call.argument<String>("time_yatsi") ?: "")
                        apply()
                    }
                    KabeSaatWidgetProvider.updateAllWidgets(applicationContext)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("WIDGET_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startSensors() {
        if (rotationVectorSensor != null) {
            sensorManager?.registerListener(this, rotationVectorSensor, SensorManager.SENSOR_DELAY_GAME)
        } else {
            sensorManager?.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_GAME)
            sensorManager?.registerListener(this, magnetometer, SensorManager.SENSOR_DELAY_GAME)
        }
    }

    private fun stopSensors() {
        sensorManager?.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null || eventSink == null) return

        var azimuthInDegrees = 0.0

        if (event.sensor.type == Sensor.TYPE_ROTATION_VECTOR) {
            SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
            SensorManager.getOrientation(rotationMatrix, orientationAngles)
            // orientationAngles[0] is azimuth in radians [-pi, pi]
            val azimuthInRadians = orientationAngles[0]
            azimuthInDegrees = (Math.toDegrees(azimuthInRadians.toDouble()) + 360.0) % 360.0
            eventSink?.success(azimuthInDegrees)
        } else if (event.sensor.type == Sensor.TYPE_ACCELEROMETER) {
            System.arraycopy(event.values, 0, lastAccelerometer, 0, event.values.size)
            lastAccelerometerSet = true
        } else if (event.sensor.type == Sensor.TYPE_MAGNETIC_FIELD) {
            System.arraycopy(event.values, 0, lastMagnetometer, 0, event.values.size)
            lastMagnetometerSet = true
        }

        if (event.sensor.type != Sensor.TYPE_ROTATION_VECTOR && lastAccelerometerSet && lastMagnetometerSet) {
            if (SensorManager.getRotationMatrix(rotationMatrix, null, lastAccelerometer, lastMagnetometer)) {
                SensorManager.getOrientation(rotationMatrix, orientationAngles)
                val azimuthInRadians = orientationAngles[0]
                azimuthInDegrees = (Math.toDegrees(azimuthInRadians.toDouble()) + 360.0) % 360.0
                eventSink?.success(azimuthInDegrees)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Unused
    }

    override fun onPause() {
        super.onPause()
        stopSensors()
    }

    override fun onResume() {
        super.onResume()
        if (eventSink != null) {
            startSensors()
        }
    }

    override fun onDestroy() {
        stopSensors()
        super.onDestroy()
    }
}
