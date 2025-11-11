"""Rules to support Google services, e.g. Firebase Cloud Messaging."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:jvm.bzl", "jvm_maven_import_external")

def _google_services_xml_impl(ctx):
    package_name = ctx.attr.package_name
    google_services_json = ctx.file.google_services_json

    output = ctx.actions.declare_file(
        "google_services_xml/%s/%s/res/values/values.xml" % (
            package_name,
            google_services_json.path.replace("/", "_")))

    ctx.actions.run(
        outputs = [output],
        inputs = [google_services_json],
        executable = ctx.executable._generator,
        arguments = [package_name, google_services_json.path, output.path],
        mnemonic = "GenerateGoogleServicesXml",
    )

    return [DefaultInfo(files = depset([output]))]

google_services_xml = rule(
    implementation = _google_services_xml_impl,
    attrs = {
        "package_name": attr.string(
            mandatory = True,
            doc = "The package name (or application ID) of the Android app.",
        ),
        "google_services_json": attr.label(
            mandatory = True,
            allow_single_file = [".json"],
            doc = "The google-services.json file.",
        ),
        "_generator": attr.label(
            default = "@tools_android//third_party/googleservices:GenerateGoogleServicesXml",
            executable = True,
            cfg = "exec",
        ),
    },
    doc = """Creates Android resource XML for Google services.

    The XML is based on a google-services.json file.

    This rule assumes that the Android tools repository is named "tools_android"
    in the top-level project's WORKSPACE file.
    """,
)
