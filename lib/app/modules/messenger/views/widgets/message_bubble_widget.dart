import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String name, text;
  final int senderId, uid;
  final dynamic timestamp;
  const MessageBubble(
      {Key? key,
      required this.name,
      required this.text,
      required this.senderId,
      required this.uid,
      required this.timestamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment:
            senderId == uid ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          senderId != uid
              ? Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Container(),
          Material(
            borderRadius: senderId == uid
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            elevation: 5,
            color: senderId == uid
                ? Theme.of(context).primaryColor
                : Colors.blueGrey.shade700,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            DateFormat
                    // .yMMMEd()
                    .MEd()
                .add_jm()
                .format(DateTime.parse(timestamp.toString()).toLocal()),
            // timestamp.toString(),
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          // senderId == uid
          //     ? Text(
          //         'Seen',
          //         style: const TextStyle(fontSize: 10, color: Colors.black54),
          //       )
          //     : Container(),
        ],
      ),
    );
  }
}
