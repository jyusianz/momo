-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication

# Flutter-specific rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Stripe-specific rules
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.** { *; }

# Kotlin-specific rules
-keepclassmembers class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keep class kotlin.** { *; }

# AndroidX rules
-keep class androidx.** { *; }
-dontwarn androidx.**

# Prevent stripping of annotations
-keepattributes *Annotation*

# Exclude Stripe push provisioning-related classes
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }
-keepclassmembers class com.stripe.android.pushProvisioning.** { *; }
-dontnote com.stripe.android.pushProvisioning.**
