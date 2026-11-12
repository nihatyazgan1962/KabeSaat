package com.kabesaat.app.kabe_saat

import android.os.Handler
import android.os.Looper
import android.service.dreams.DreamService
import android.widget.TextView
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class KabeDreamService : DreamService() {
    private val handler = Handler(Looper.getMainLooper())
    private var timeTextView: TextView? = null
    private val timeFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())

    private val timeRunnable = object : Runnable {
        override fun run() {
            timeTextView?.text = timeFormat.format(Date())
            handler.postDelayed(this, 1000)
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        isInteractive = false
        isFullscreen = true
        setContentView(R.layout.dream_kabe_saat)
        timeTextView = findViewById(R.id.dream_time)
    }

    override fun onDreamingStarted() {
        super.onDreamingStarted()
        handler.post(timeRunnable)
    }

    override fun onDreamingStopped() {
        super.onDreamingStopped()
        handler.removeCallbacks(timeRunnable)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        handler.removeCallbacks(timeRunnable)
    }
}

