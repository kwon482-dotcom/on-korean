package com.kwon.onkorean

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import kotlin.random.Random

class OnKoreanWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        var level = widgetData.getString("widget_level", null) ?: "TOPIK 1"
        var word = widgetData.getString("widget_word", null) ?: "안녕하세요"
        var furigana = widgetData.getString("widget_furigana", null) ?: "[An-nyeong-ha-se-yo]"
        var meaning = widgetData.getString("widget_meaning", null) ?: "Hello / こんにちは"

        val isManualUpdate = widgetData.getBoolean("widget_manual_updated", false)
        val poolJson = widgetData.getString("widget_words_pool", null)

        if (isManualUpdate) {
            // 앱 내에서 방금 직접 세팅한 최신 단어 표시 후 플래그 초기화
            widgetData.edit().putBoolean("widget_manual_updated", false).apply()
        } else if (!poolJson.isNullOrEmpty()) {
            // 백그라운드 주기적(1시간) 갱신 시 캐시된 단어 풀에서 다음 단어로 자동 교체
            try {
                val jsonArray = JSONArray(poolJson)
                if (jsonArray.length() > 0) {
                    val randomIndex = Random.nextInt(jsonArray.length())
                    val item = jsonArray.getJSONObject(randomIndex)
                    level = item.optString("level", level)
                    word = item.optString("word", word)
                    furigana = item.optString("furigana", furigana)
                    meaning = item.optString("meaning", meaning)

                    widgetData.edit()
                        .putString("widget_level", level)
                        .putString("widget_word", word)
                        .putString("widget_furigana", furigana)
                        .putString("widget_meaning", meaning)
                        .apply()
                }
            } catch (e: Exception) {
                // 파싱 실패 시 기존 단어 유지
            }
        }

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.on_vocab_widget).apply {
                setTextViewText(R.id.widget_level, level)
                setTextViewText(R.id.widget_word, word)
                setTextViewText(R.id.widget_furigana, furigana)
                setTextViewText(R.id.widget_meaning, meaning)

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
