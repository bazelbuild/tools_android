def _jetify_jars_impl(ctx):
    srcs = ctx.attr.srcs
    outfiles = []
    for src in srcs:
        for jar in src.files.to_list():
            jetified_outfile = ctx.actions.declare_file("jetified_" + jar.basename)
            jetify_args = ctx.actions.args()
            jetify_args.add_all(["-l", "error"])
            jetify_args.add_all(["-o", jetified_outfile])
            jetify_args.add_all(["-i", jar])
            ctx.actions.run(
                mnemonic = "Jetify",
                inputs = [jar],
                outputs = [jetified_outfile],
                progress_message = "Jetifying {} to create {}.".format(jar.path, jetified_outfile.path),
                executable = ctx.executable._jetifier,
                arguments = [jetify_args],
                use_default_shell_env = True,
            )
            outfiles.append(jetified_outfile)

    return [DefaultInfo(files = depset(outfiles))]

jetify = rule(
    attrs = {
        "srcs": attr.label_list(allow_files = [".jar", ".aar"]),
        "_jdk": attr.label(
          default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
          providers = [java_common.JavaRuntimeInfo],
        ),
        "_jetifier": attr.label(
            executable = True,
            allow_single_file = True,
            default = Label("//third_party/jetifier:jetifier-standalone/bin/jetifier-standalone"),
            cfg = "host",
        ),
    },
    implementation = _jetify_jars_impl,
)
