package com.bazel.crashlytics;

import java.io.BufferedWriter;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.IOException;

public class Crashlytics {

  public static void main(String[] args) throws Exception {
    String propertiesFileContent = args[0];
    String outFile = args[1];

    try (BufferedWriter w = Files.newBufferedWriter(Paths.get(outFile))) {
      w.write(propertiesFileContent);
    }

  }

}
