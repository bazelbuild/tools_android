# Firebase Crashlytics support with Bazel

In order to integrate Crashlytics into your app, Bazel needs to generate
configuration files containing information about your Crashlytics setup to
include in the final APK.

Ensure that you have a Firebase app with Firebase Crashlytics enabled. For more
information, read the [Before you
begin](https://firebase.google.com/docs/crashlytics/get-started#android) section
on the Firebase Crashlytics documentation.

Also ensure that the `google-services.json` file is in your project workspace.

To fetch Crashlytics dependencies, use a Maven resolver tool. For the following
examples, we will use [rules_maven](https://github.com/jin/rules_maven):

In the WORKSPACE, add the Crashlytics and Google Maven repositories, as well as
the dependencies:

```python
maven_install(
    artifacts = [
        "com.crashlytics.sdk.android:crashlytics:2.9.8",
        "io.fabric.sdk.android:fabric:1.4.7",
    ],
    repositories = [
        "https://maven.fabric.io/public",
        "https://bintray.com/bintray/jcenter",
        "https://maven.google.com",
        "https://repo1.maven.org/maven2",
    ],
)
```

In your BUILD file, create a `crashlytics_android_library`. For convenience, you
can also create an `android_library` that exports the two artifacts dependencies.

```python
load("@rules_maven//:defs.bzl", "artifact")
load("@tools_android//tools/crashlytics:defs.bzl", "crashlytics_android_library")

android_library(
    name = "crashlytics_deps",
    exports = [
        artifact("com.crashlytics.sdk.android:crashlytics"),
        artifact("io.fabric.sdk.android:fabric"),
    ],
)

crashlytics_android_library(
    name = "crashlytics_lib",
    package_name = "com.example.package",
    build_id = "9dfea8fe-4d75-48a7-ba28-4ddb7fe74780",
    google_services_json = "google-services.json",
)
```

To generate the Build ID, we have created a tool called `generate_uuid`. Run it
with Bazel:

```
$ bazel run @tools_android//tools/crashlytics:generate_uuid

...

76196b85-5620-4435-81e1-1c0515e0e271
```

Finally, depend on the `crashlytics_deps` and `crashlytics_lib` libraries in
your `android_library` target:

```python
android_library(
    name = "my_release_lib",
    srcs = glob(["src/main/**/*.java"]),
    manifest = "AndroidManifest.xml",
    resource_files = glob(["res/**/*"]),
    deps = [
        ":crashlytics_lib",
        ":crashlytics_deps", 
    ],
)
```

To force a crash and find out if Crashlytics is working properly, [follow the
steps in Crashlytics
documentation](https://firebase.google.com/docs/crashlytics/force-a-crash).
