load("@rules_java//java:defs.bzl", "java_binary", "java_library")

exports_files(["defs.bzl"])

java_binary(
    name = "crashlytics",
    srcs = ["com/bazel/crashlytics/Crashlytics.java"],
    main_class = "com.bazel.crashlytics.Crashlytics",
    visibility = ["//visibility:public"],
)

java_binary(
    name = "generate_uuid",
    srcs = ["com/bazel/crashlytics/GenerateRandomUUID.java"],
    main_class = "com.bazel.crashlytics.GenerateRandomUUID",
    visibility = ["//visibility:public"],
)
