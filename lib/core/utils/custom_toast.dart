
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/utils/common_text.dart';

class ToastCustom{

  static showToast({required String msg}){
    Fluttertoast.showToast( msg:msg,textColor: Colors.white);
  }

  static showToastWithLength({required String msg,Toast? toastLength}){
    Fluttertoast.showToast( msg:msg,toastLength: toastLength ?? Toast.LENGTH_LONG);
  }

  static showToastWithGravity({required String msg,ToastGravity? gravity}){
    Fluttertoast.showToast( msg:msg,gravity: gravity ?? ToastGravity.TOP);
  }

static showSnackBar({
  required String? subtitle,
  bool? isSuccess,
  bool? removeFast,
  Duration? duration,
}) {
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
  }else {
    Get.rawSnackbar(
    borderRadius: 12,
    animationDuration: const Duration(milliseconds: 700),
    reverseAnimationCurve: Curves.easeOut,
    forwardAnimationCurve: Curves.linearToEaseOut,
    duration: removeFast ?? false ? const Duration(seconds: 1) : duration ?? const Duration(milliseconds: 3000),
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.only(right: 6, left: 6, top: 0, bottom: 0),
    backgroundColor: Colors.transparent,
    messageText: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: (isSuccess ?? false) ?
            Colors.grey.shade500.withValues(alpha:0.4) :
            Colors.red.shade800.withValues(alpha:0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isSuccess ?? false
                    ? CupertinoIcons.checkmark_alt_circle_fill
                    : CupertinoIcons.exclamationmark_circle_fill,
                color: isSuccess ?? false ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: CommonText(
                  subtitle ?? "",
                  fontSize: 14,
                  color: Colors.white,
                  style: const TextStyle(fontFamily: 'InterMedium'),
                ),
              ),
              GestureDetector(
                onTap: () => Get.closeCurrentSnackbar(),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}



}