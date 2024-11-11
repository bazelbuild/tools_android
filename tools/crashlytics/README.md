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

In your BUILD file, declare `crashlytics_android_library` and
`google_services_xml`. For convenience, you can also create an `android_library`
that exports the two artifacts dependencies.

```python
load("@rules_maven//:defs.bzl", "artifact")
load("@tools_android//tools/crashlytics:defs.bzl", "crashlytics_android_library")
load("@tools_android//tools/googleservices:defs.bzl", "google_services_xml")

GOOGLE_SERVICES_RESOURCES = google_services_xml(
    package_name = "com.example.package",
    google_services_json = "google-services.json",
)

crashlytics_android_library(
    name = "crashlytics_lib",
    package_name = "com.example.package",
    build_id = "9dfea8fe4d7548a7ba284ddb7fe74780",
    resource_files = GOOGLE_SERVICES_RESOURCES,
)

android_library(
    name = "crashlytics_deps",
    exports = [
        artifact("com.crashlytics.sdk.android:crashlytics"),
        artifact("io.fabric.sdk.android:fabric"),
    ],
)
```

To generate the Build ID (which is a UUID without hyphens),
we have created a tool called `generate_uuid`. Run it with Bazel:

```
$ bazel run @tools_android//tools/crashlytics:generate_uuid

...

76196b855620443581e11c0515e0e271
```

Finally, depend on the `crashlytics_deps` and `crashlytics_lib` libraries.

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
