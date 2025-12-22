import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
Future<bool> alertExitApp() {
  Get.defaultDialog(
    title: "56".tr,
    middleText: "53".tr,
    actions: [
      ElevatedButton(
        onPressed: () {
          exit(0);
        },
        child: Text("54".tr),
      ),
      ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: Text("55".tr),
      ),
    ],
  );
  return Future.value(true);
}
