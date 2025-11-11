load("//tools/googleservices:defs.bzl", "google_services_xml")
load("@rules_android//android:rules.bzl", "android_library")

_CRASHLYTICS_PROP_TEMPLATE = """build_id={build_id}
package_name={package_name}"""

_CRASHLYTICS_RES_TEMPLATE = """<?xml version="1.0" encoding="utf-8" standalone="no"?>
<resources xmlns:tools="http://schemas.android.com/tools">
    <string tools:ignore="UnusedResources,TypographyDashes" name="com.google.firebase.crashlytics.mapping_file_id" translatable="false">{build_id}</string>
</resources>"""

_CRASHLYTICS_KEEP_CONTENT = """<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@string/com_google_firebase_crashlytics_mapping_file_id" />"""

_CRASHLYTICS_MANIFEST_TEMPLATE = """<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="{package_name}">
</manifest>
"""

def _crashlytics_android_impl(ctx):
  package_name = ctx.attr.package_name
  # Expand make variables in build_id
  build_id = ctx.expand_make_variables("build_id", ctx.attr.build_id, {})

  properties_file = ctx.outputs.properties
  res_values_file = ctx.outputs.res_values
  res_keep_file = ctx.outputs.res_keep
  manifest_file = ctx.outputs.manifest

  # Generate crashlytics-build.properties
  properties_content = _CRASHLYTICS_PROP_TEMPLATE.format(
      build_id = build_id,
      package_name = package_name,
  )
  ctx.actions.write(
      output = properties_file,
      content = properties_content,
      is_executable = False,
  )

  # Generate build ID resource XML
  res_values_content = _CRASHLYTICS_RES_TEMPLATE.format(build_id = build_id)
  ctx.actions.write(
      output = res_values_file,
      content = res_values_content,
      is_executable = False,
  )

  # Generate keep XML
  ctx.actions.write(
      output = res_keep_file,
      content = _CRASHLYTICS_KEEP_CONTENT,
      is_executable = False,
  )

  # Generate manifest
  manifest_content = _CRASHLYTICS_MANIFEST_TEMPLATE.format(package_name = package_name)
  ctx.actions.write(
      output = manifest_file,
      content = manifest_content,
      is_executable = False,
  )

  # Collect all resource files
  all_resource_files = [res_values_file, res_keep_file] + ctx.files.resource_files

  return [
      DefaultInfo(files = depset([
          properties_file,
          manifest_file,
      ] + all_resource_files)),
      OutputGroupInfo(
          assets = depset([properties_file]),
          manifest = depset([manifest_file]),
          resources = depset(all_resource_files),
      ),
  ]

crashlytics_android = rule(
    implementation = _crashlytics_android_impl,
    attrs = {
        "package_name": attr.string(
            mandatory = True,
            doc = "The package name (or application ID) of the Android app.",
        ),
        "build_id": attr.string(
            mandatory = True,
            doc = "The build ID for Crashlytics. Supports make variable expansion like $(crashlyticsBuildID).",
        ),
        "resource_files": attr.label_list(
            allow_files = True,
            doc = "Additional resource files to include.",
        ),
        "_generator": attr.label(
            default = "@tools_android//tools/crashlytics",
            executable = True,
            cfg = "exec",
        ),
    },
    outputs = {
        "properties": "%{name}_crashlytics/assets/crashlytics-build.properties",
        "res_values": "%{name}_crashlytics/res/values/com_crashlytics_build_id.xml",
        "res_keep": "%{name}_crashlytics/res/raw/%{name}_crashlytics_keep.xml",
        "manifest": "%{name}_crashlytics/CrashlyticsManifest.xml",
    },
    doc = """Generates Crashlytics configuration files.

    Generates the unique identifier for Fabric backend to identify builds.
    See: https://docs.fabric.io/android/crashlytics/build-tools.html
    """,
)

def crashlytics_android_library(name, package_name, build_id, google_services_json, **kwargs):
    """Creates an Android library with Crashlytics and Google Services configuration.

    Args:
        name: Name of the android_library target.
        package_name: The package name (or application ID) of the Android app.
                     Supports select() statements.
        build_id: The build ID for Crashlytics.
        google_services_json: The google-services.json file.
        **kwargs: Additional arguments to pass to android_library.
    """
    gsx_name = name + "_google_services_xml"
    gen_name = name + "_gen"

    google_services_xml(
        name = gsx_name,
        package_name = package_name,
        google_services_json = google_services_json,
    )

    crashlytics_android(
        name = gen_name,
        package_name = package_name,
        build_id = build_id,
        resource_files = [":%s" % gsx_name],
    )

    android_library(
        name = name,
        assets = [":%s_crashlytics/assets/crashlytics-build.properties" % gen_name],
        assets_dir = "%s_crashlytics/assets" % gen_name,
        custom_package = package_name,
        manifest = ":%s_crashlytics/CrashlyticsManifest.xml" % gen_name,
        resource_files = [
            ":%s_crashlytics/res/values/com_crashlytics_build_id.xml" % gen_name,
            ":%s_crashlytics/res/raw/%s_crashlytics_keep.xml" % (gen_name, gen_name),
            ":%s" % gsx_name,
        ],
        **kwargs
    )
