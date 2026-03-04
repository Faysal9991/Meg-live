import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/business_controller.dart';

class BusinessView extends GetView<BusinessController> {
  const BusinessView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BusinessView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'BusinessView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
