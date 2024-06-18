import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/member.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/screens/group_detail.dart';
import 'package:we_chat/widgets/message_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatCommunity extends StatefulWidget {
  final Member member;
  const ChatCommunity({super.key, required this.member});

  @override
  State<ChatCommunity> createState() => _ChatCommunityState();
}

class _ChatCommunityState extends State<ChatCommunity> {
  //for storing all messages
  List<Message> _list = [];

  //for handling message text changes
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //----------app Bar--------------------------------

      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GroupDetail(
                              member: widget.member,
                            )));
              },
              icon: Icon(Icons.more_vert))
        ],
      ),

      backgroundColor: Color.fromARGB(255, 221, 233, 240),
      //-----------body----------------------------------

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: APIs.getAllGroupMessages(widget.member),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(child: const SizedBox());
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;

                      _list = data
                              ?.map((e) => Message.fromJson(e.data()))
                              .toList() ??
                          [];

                      // _list.reversed;
                      _list.sort((a, b) => a.sent.compareTo(b.sent));

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            // reverse: true,
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(
                                message: _list[index],
                              );
                            });
                      } else {
                        return Center(
                          child: Container(
                            child: Text(
                              'Say Hi!  👋',
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                        );
                      }
                  }
                },
              ),
            ),
            _chatInput(),
          ],
        ),
      ),
    );
  }

  //---------------------App Bar------------------------------//

  Widget _appBar() {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            //---------- back Button ----------------------------------------------------------------

            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                )),

            //---------- chat user icon ----------------------------------------------------------------

            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .03),
              child: CachedNetworkImage(
                height: mq.height * .055,
                width: mq.width * .13,
                imageUrl: widget.member.cimage,
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
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),

            //---------- user data  column widget -------------------------------------------------------------------------------

            Padding(
              padding: const EdgeInsets.only(left: 20, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.member.cname,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    widget.member.cgoal,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Colors.black87),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //---------------------Chat Input Field---------------------//

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.only(
          top: mq.height * .01,
          bottom: mq.height * .025,
          left: mq.width * .025,
          right: mq.width * .025),
      child: Row(
        children: [
          //------ icons and text input-------------------------------//

          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: "Type Something...",
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  SizedBox(
                    width: mq.width * .02,
                  )
                ],
              ),
            ),
          ),

          //-----------send button ----------------------------//
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sentGroupMessage(widget.member, _textController.text);
                _textController.text = '';
              }
            },
            color: Colors.green,
            shape: const CircleBorder(),
            minWidth: 0,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 26,
              ),
            ),
          )

          //------- text input field --------------------------//
        ],
      ),
    );
  }
}
