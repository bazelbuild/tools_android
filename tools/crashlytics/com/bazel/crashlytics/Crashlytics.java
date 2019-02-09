package com.bazel.crashlytics;

import java.io.BufferedWriter;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.IOException;

/**
 * A simple executable to echo content into a file.
 *
 * Instead of using `echo` in a genrule, we can use this wrapper to simplify
 * multiplatform support. Windows and Linux has different syntax for `echo`
 * calls.
 */
public class Crashlytics {

  public static void main(String[] args) throws Exception {
    String propertiesFileContent = args[0];
    String outFile = args[1];

    try (BufferedWriter w = Files.newBufferedWriter(Paths.get(outFile))) {
      w.write(propertiesFileContent);
    }

  }

}
