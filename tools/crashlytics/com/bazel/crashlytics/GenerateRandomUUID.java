package com.bazel.crashlytics;

public class GenerateRandomUUID {

  public static void main(String[] args) {
    System.out.println(java.util.UUID.randomUUID().toString().replace("-", ""));
  }

}
