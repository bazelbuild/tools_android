# 📣 [Unmaintained] tools_android

> [!WARNING]
> Due to an absence of any maintainers, this repository is archived and currently unmaintained.
>
> **We discourage any new dependencies on the contents of this repository.**
> See [rules_android](https://github.com/bazelbuild/rules_android) for an alternative.
>
> If you, or your organization, are interested in revitalizing this project by taking over its maintenance, we welcome your initiative.
> To discuss the process of un-archiving and assuming ownership of this repository, please reach out to us via email at `bazel-contrib@googlegroups.com` or join the conversation on our Slack workspace in the `#rules` channel.
> You can sign up for Slack access at [https://slack.bazel.build](https://slack.bazel.build).

This repository hosts tools for use with building Android apps with Bazel.

## Setup

To use this with Bazel, add the following snippet to your WORKSPACE file:

```python
TOOLS_ANDROID_VERSION = "0.1" # or the latest version

http_archive(
    name = "tools_android",
    strip_prefix = "tools_android-%s" % TOOLS_ANDROID_VERSION,
    url = "https://github.com/bazelbuild/tools_android/archive/%s.tar.gz" % TOOLS_ANDROID_VERSION,
)

load("@tools_android//tools/googleservices:defs.bzl", "google_services_workspace_dependencies")

google_services_workspace_dependencies()
```

## Google Services XML

For an example of integrating with Firebase Cloud Messaging (FCM), [see this
example](https://github.com/bazelbuild/examples/tree/master/android/firebase-cloud-messaging).

## Firebase Crashlytics support

To integrate Crashlytics into your Android app, follow the [instructions in the
README](tools/crashlytics/README.md) in the `crashlytics` directory.
