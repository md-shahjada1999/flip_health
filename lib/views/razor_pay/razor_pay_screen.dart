import 'package:flutter/material.dart';

/// Loading shell while Razorpay opens. The controller is registered in [RazorPayBinding]
/// with [Get.put] so `onInit` runs (checkout is not triggered by [Get.lazyPut] alone).
class RazorPayScreen extends StatelessWidget {
  const RazorPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
