###########
# Flutter #
###########
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Your app package
-keep class com.doyel_live.** { *; }
-keep class com.taksoft.** { *; }


############
# Firebase #
############
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.iid.FirebaseInstanceIdReceiver { *; }
-keep class com.google.firebase.auth.** { *; }

#########################
# Google Play Services  #
#########################
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

#############
# LiveKit   #
#############
-keep class io.livekit.** { *; }
-dontwarn io.livekit.**

# WebRTC (used by LiveKit)
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

#########
# Dio / OkHttp #
#########
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

#########
# Gson  #
#########
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

###################
# Camera / Image  #
###################
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

#################
# Notifications #
#################
-keep class com.dexterous.** { *; }   # awesome_notifications
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.android.gms.notifications.** { *; }

########################
# Secure Storage       #
########################
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

############
# AndroidX #
############
-dontwarn androidx.**
-keep class androidx.** { *; }

#########################
# Reflection & Metadata #
#########################
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable
