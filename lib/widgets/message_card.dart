import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  String userName = "...";
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    String name = await APIs.getusermessage(widget.message.fromId);
    if (!_isDisposed) {
      setState(() {
        userName = name;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  // sender or another user's message
  Widget _blueMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(mq.width * .04),
          margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04, vertical: mq.height * .01),
          decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.lightBlue),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: Colors.teal),
              ),
              SizedBox(
                height: 5,
              ),
              Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    child: widget.message.type == Type.text
                        ? Text(
                            widget.message.msg,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black87),
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(mq.height * .03),
                            child: CachedNetworkImage(
                              width: mq.height * .15,
                              height: mq.height * .15,
                              imageUrl: widget.message.msg,
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image,
                                size: 70,
                              ),
                            ),
                          ),
                  )),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            Dialogs.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            const SizedBox(
              width: 2,
            ),
            Text(
              Dialogs.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(mq.width * .04),
          margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04, vertical: mq.height * .01),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 184, 242, 214),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: Colors.teal),
              ),
              SizedBox(
                height: 5,
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  child: widget.message.type == Type.text
                      ? Text(
                          widget.message.msg,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black87),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: CachedNetworkImage(
                            width: mq.height * .15,
                            height: mq.height * .15,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            imageUrl: widget.message.msg,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image,
                              size: 70,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
