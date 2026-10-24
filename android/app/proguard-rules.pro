# Flutter Deferred Components 및 Play Core 경고 무시 (R8 최적화 필수)
-dontwarn com.google.android.play.core.**

# Flutter 엔진 기본 보존 규칙
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-dontwarn io.flutter.**

# WorkManager & Room Database 보존 규칙 (크래시 방지 필수)
-keepclassmembers class * extends androidx.room.RoomDatabase {
    public void clearAllTables();
}
-keep class * extends androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# Google Play Services & AdMob 보존 규칙
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-keep class androidx.startup.** { *; }
-dontwarn com.google.android.gms.**

# Firebase & Google Auth
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Billing (인앱 결제)
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# Flutter Local Notifications (로컬 푸시 알림)
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**
