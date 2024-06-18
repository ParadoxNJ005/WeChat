import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      height: mq.height * .085,
                      width: mq.width * .14,
                      imageUrl: widget.user.image,
                      imageBuilder: (context, imageProvider) => ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: imageProvider,
                            ),
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  title: Text(widget.user.name),
                  subtitle: Text(
                      _message != null
                          ? _message!.type == Type.text
                              ? _message!.msg
                              : "image"
                          : widget.user.about,
                      maxLines: 1),
                  trailing: _message == null
                      ? null
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                shape: BoxShape.circle,
                              ),
                            )
                          : Text(
                              Dialogs.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: TextStyle(color: Colors.black54),
                            ));
            },
          )),
    );
  }
}
