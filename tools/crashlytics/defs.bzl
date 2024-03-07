def crashlytics_android_library(name, package_name, build_id, resource_files):
  _CRASHLYTICS_PROP_TEMPLATE = \
  """build_id={build_id}
package_name={package_name}"""
  crashlytics_properties_file = "_%s_crashlytics/crashlytics-build.properties" % name
  crashlytics_properties_file_content = _CRASHLYTICS_PROP_TEMPLATE.format(
      build_id = build_id,
      package_name = package_name,
  )

  native.genrule(
      name = "%s_crashlytics_setup_properties" % name,
      outs = [crashlytics_properties_file],
      tools = ["@tools_android//tools/crashlytics"],
      cmd = "$(location @tools_android//tools/crashlytics) \"%s\" $@" % crashlytics_properties_file_content,
  )

  # Generate the unique identifier for Fabric backend to identify builds.
  # https://docs.fabric.io/android/crashlytics/build-tools.html#optimize-builds-when-you-re-not-proguarding-or-using-beta-by-crashlytics
  _CRASHLYTICS_RES_TEMPLATE = \
  """<?xml version=\\"1.0\\" encoding=\\"utf-8\\" standalone=\\"no\\"?>
<resources xmlns:tools=\\"http://schemas.android.com/tools\\">
    <string tools:ignore=\\"UnusedResources,TypographyDashes\\" name=\\"com.crashlytics.android.build_id\\" translatable=\\"false\\">{build_id}</string>
</resources>"""
  crashlytics_res_values_file = "_%s_crashlytics/res/values/com_crashlytics_build_id.xml" % name
  crashlytics_res_values_file_content = _CRASHLYTICS_RES_TEMPLATE.format(build_id = build_id)

  native.genrule(
      name = "%s_crashlytics_setup_res" % name,
      outs = [crashlytics_res_values_file],
      tools = ["@tools_android//tools/crashlytics"],
      cmd = "$(location @tools_android//tools/crashlytics) \"%s\" $@" % crashlytics_res_values_file_content,
  )

  _CRASHLYTICS_MANIFEST_TEMPLATE = \
"""<?xml version=\\"1.0\\" encoding=\\"utf-8\\"?>
<manifest xmlns:android=\\"http://schemas.android.com/apk/res/android\\"
          package=\\"{package_name}\\">
</manifest>
"""
  crashlytics_manifest_file = "_%s_crashlytics/CrashlyticsManifest.xml" % name
  crashlytics_manifest_file_content = _CRASHLYTICS_MANIFEST_TEMPLATE.format(package_name = package_name)

  native.genrule(
      name = "%s_crashlytics_setup_manifest" % name,
      outs = [crashlytics_manifest_file],
      tools = ["@tools_android//tools/crashlytics"],
      cmd = "$(location @tools_android//tools/crashlytics) \"%s\" $@" % crashlytics_manifest_file_content,
  )

  native.android_library(
      name = name,
      assets = [crashlytics_properties_file],
      assets_dir = "_%s_crashlytics" % name,
      custom_package = package_name,
      manifest = crashlytics_manifest_file,
      resource_files = [crashlytics_res_values_file] + resource_files,
  )
