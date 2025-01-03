# Preserve Razorpay SDK classes and annotations
-keep class com.razorpay.** { *; }

# Preserve Google Pay classes
-keep class com.google.android.apps.nbu.paisa.** { *; }
-keep class com.google.android.gms.wallet.** { *; }

# Preserve annotation classes
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-keep @proguard.annotation.Keep class *
-keep @proguard.annotation.KeepClassMembers class *

# Razorpay and related dependencies
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }

# Keep specific classes used in Razorpay and Google Pay
-dontwarn com.google.android.apps.nbu.paisa.**
-dontwarn com.google.android.gms.wallet.**
-dontwarn proguard.annotation.**

# Keep everything in Razorpay and its dependencies
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
