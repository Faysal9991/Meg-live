import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AgentForHostView extends StatefulWidget {
  AgentForHostView({Key? key}) : super(key: key);

  @override
  State<AgentForHostView> createState() => _AgentForHostViewState();
}

class _AgentForHostViewState extends State<AgentForHostView> {
  late AuthController _authController;

  late BusinessController _businessController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _businessController = Get.put(BusinessController());
    _authController = Get.find();
  }

  @override
  void dispose() {
    super.dispose();
    _businessController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('My Agent')),
        body: Obx(() {
          if (!_authController.profile.value.is_host!) {
            Get.back();
          }
          return FutureBuilder(
            future: _businessController.fetchAgentForHost(),
            builder: (context, snapshot) {
              // Checking if future is resolved
              if (snapshot.connectionState == ConnectionState.done) {
                // If we got an error
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error occurred',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );

                  // if we got our data
                } else if (snapshot.hasData) {
                  // Extracting data from snapshot object
                  final data = snapshot.data as dynamic;
                  if (data == null) {
                    return const Center(
                      child: Text(
                        'Error occurred',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 32),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: CachedNetworkImage(
                          imageUrl: data['logo'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Name: ${data['agent_name']}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('User ID: ${data['user_id']}'),
                          const SizedBox(width: 32),
                        ],
                      ),
                    ],
                  );
                }
              }
              // Displaying LoadingSpinner to indicate waiting state
              return const Center(
                child: SpinKitWaveSpinner(
                  trackColor: Colors.grey,
                  waveColor: Colors.redAccent,
                  color: Colors.white,
                  size: 50.0,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
