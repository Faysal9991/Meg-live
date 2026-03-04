import 'package:doyel_live/app/modules/messenger/views/widgets/chat_list_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/messenger_controller.dart';

class MessengerView extends GetView<MessengerController> {
  const MessengerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 38,
          margin: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                color: Theme.of(context).primaryColor,
                child: const Center(
                  child: Text(
                    'Messages',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          child: ChatListWidget(),
        )
      ],
    );
  }
}
