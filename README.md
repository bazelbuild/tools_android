# tools_android

This repository hosts tools for use with building Android apps with Bazel.

## Setup

To use this with Bazel, add the following snippet to your MODULE.bazel file:

```python
bazel_dep(name = "tools_android", version = "0.3.0")  # Or latest version
```

Note: using WORKSPACE is deprecated. If you are still using WORKSPACE,
the last released version to support WORKSPACE is version 0.2.0.

## Google Services XML

For an example of integrating with Firebase Cloud Messaging (FCM), [see this
example](https://github.com/bazelbuild/examples/tree/master/android/firebase-cloud-messaging).

## Firebase Crashlytics support

To integrate Crashlytics into your Android app, follow the [instructions in the
README](tools/crashlytics/README.md) in the `crashlytics` directory.
