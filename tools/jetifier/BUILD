load(":defs.bzl", "jetify")

jetify(
    name = "jetified_dagger",
    srcs = ["@maven//:v1/https/jcenter.bintray.com/com/google/dagger/dagger-android-support/2.22.1/dagger-android-support-2.22.1.aar"],
)

aar_import(
    name = "jetified_dagger_aar",
    aar = ":jetified_dagger",
)
