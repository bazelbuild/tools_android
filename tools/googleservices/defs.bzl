"""Macros to support Google services, e.g. Firebase Cloud Messaging."""

def google_services_xml(package_name, google_services_json):
  """Creates Android resource XML for Google services.

  The XML is based on a google-services.json file.

  Args:
    package_name: The package name (or application ID) of the Android app.
    google_services_json: The google-services.json file.

  Returns:
    A list of the generated resource files which can be used with
    android_binary.resource_files or android_library.resource_files.
  """
  # Adding the package name and google-services.json file to the outs and name
  # of the rule is necessary in case there are multiple calls to
  # google_services_xml() with different package names or different json files.
  outs = ["google_services_xml/%s/%s/res/values/values.xml" %
      (package_name, google_services_json.replace("/", "_"))]
  name = "gen_google_services_xml_%s_%s" % (
      package_name.replace(".", "_"),
      google_services_json.replace(".", "_").replace("/", "_"))
  if not native.existing_rule(name):
    native.genrule(
      name = name,
      srcs = [google_services_json],
      outs = outs,
      tools = ["@rules_android//tools/googleservices:GenerateFirebaseXml"],
      cmd = "$(location @rules_android//tools/googleservices:GenerateFirebaseXml) %s $< $@" % package_name,
    )
  return outs


def google_services_workspace_dependencies():
  native.maven_jar(
    name = "com_google_code_gson_2_8_2",
    artifact = "com.google.code.gson:gson:2.8.2",
  )
