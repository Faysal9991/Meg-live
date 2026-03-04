import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ReceiverMessageCard extends StatefulWidget {
  const ReceiverMessageCard(this.fileName, this.msgType, this.msg, this.time,
      {Key? key})
      : super(key: key);
  final String msg;
  final String time;
  final String msgType;
  final String fileName;

  @override
  State<ReceiverMessageCard> createState() => _ReceiverMessageCardState();
}

class _ReceiverMessageCardState extends State<ReceiverMessageCard> {
  Widget messageBuilder(context) {
    Widget body = Container();
    if (widget.msgType == "image") {
      body = SizedBox(
        width: 250,
        height: 250,
        child: InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Center(
                    child: InteractiveViewer(
                      panEnabled: false,
                      boundaryMargin: const EdgeInsets.all(50),
                      minScale: 0.5,
                      maxScale: 2,
                      // child: FadeInImage.assetNetwork(
                      //   placeholder: 'images/default/fading_lines.gif',
                      //   image: widget.msg,
                      // ),
                      child: CachedNetworkImage(
                        imageUrl: widget.msg,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Image.asset(
                          'images/default/fading_lines.gif',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                });
          },
          // child: FadeInImage.assetNetwork(
          //   placeholder: 'images/default/fading_lines.gif',
          //   image: widget.msg,
          //   fit: BoxFit.cover,
          // ),
          child: CachedNetworkImage(
            imageUrl: widget.msg,
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
              'images/default/fading_lines.gif',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    } else if (widget.msgType == "text") {
      body = SelectableText(
        widget.msg,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      );
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Card(
          color: Colors.blueGrey.shade700,
          elevation: 5,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: messageBuilder(context)),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text(widget.time,
                  style: const TextStyle(fontSize: 12, color: Colors.white)),
            )
          ]),
        ));
  }
}
