def _jetify_impl(ctx):
    srcs = ctx.attr.srcs
    outfiles = []
    for src in srcs:
        for artifact in src.files.to_list():
            jetified_outfile = ctx.actions.declare_file("jetified_" + artifact.basename)
            jetify_args = ctx.actions.args()
            jetify_args.add_all(["-l", "error"])
            jetify_args.add_all(["-o", jetified_outfile])
            jetify_args.add_all(["-i", artifact])
            ctx.actions.run(
                mnemonic = "Jetify",
                inputs = [artifact],
                outputs = [jetified_outfile],
                progress_message = "Jetifying {} to create {}.".format(artifact.path, jetified_outfile.path),
                executable = ctx.executable._jetifier,
                arguments = [jetify_args],
                use_default_shell_env = True,
            )
            outfiles.append(jetified_outfile)

    return [DefaultInfo(files = depset(outfiles))]

jetify = rule(
    attrs = {
        "srcs": attr.label_list(allow_files = [".jar", ".aar"]),
        "_jetifier": attr.label(
            executable = True,
            allow_single_file = True,
            default = Label("//third_party/jetifier:jetifier-standalone/bin/jetifier-standalone"),
            cfg = "host",
        ),
    },
    implementation = _jetify_impl,
)
