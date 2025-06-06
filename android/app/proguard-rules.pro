-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
# Firebase
-keep class com.google.firebase.** { *; }
-keep class io.grpc.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keepattributes Signature
-keepattributes *Annotation*
-keepnames class com.google.protobuf.** { *; }
-keepclassmembers class com.google.protobuf.GeneratedMessageLite$Builder {
  static ** parseFrom(byte[], int, int);
}
-keepclassmembers class * implements com.google.protobuf.Message {
  static ** parseFrom(com.google.protobuf.CodedInputStream);
}

# Google Play Services
-keep class com.google.android.gms.common.api.** { *; }
-keep class com.google.android.gms.auth.api.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
