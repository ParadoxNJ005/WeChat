import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/widgets/call_invite.dart';
import 'package:we_chat/widgets/message_card.dart';
import '../main.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];

  //for handling message text changes
  final _textController = TextEditingController();
  final callIDTextCtrl = TextEditingController(text: 'call_id');

  bool _showEmoji = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji != _showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          //----------app Bar--------------------------------

          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () async {
                    FlutterPhoneDirectCaller.callNumber(widget.user.phone);
                  },
                  iconSize: 30,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(Icons.video_call),
                  onPressed: () async {
                    ZegoUIKitPrebuiltCallInvitationService().init(
                      appID: 701807495 /*input your AppID*/,
                      appSign:
                          "7cb8c287a24a7738f65b5ea254334b7b20201af64d0f2207bd449d8e64189328" /*input your AppSign*/,
                      userID: APIs.me!.id.trim(),
                      userName: APIs.me!.name.trim(),
                      plugins: [ZegoUIKitSignalingPlugin()],
                    );

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CallInvite(user: widget.user)));
                  },
                  iconSize: 30,
                ),
              ),
            ],
          ),

          backgroundColor: Color.fromARGB(255, 221, 233, 240),
          //-----------body----------------------------------

          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
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

                //emoji picker dialog box

                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        height: 256,
                        checkPlatformCompatibility: true,
                        emojiViewConfig: EmojiViewConfig(
                          emojiSizeMax: 32 *
                              (foundation.defaultTargetPlatform ==
                                      TargetPlatform.iOS
                                  ? 1.30
                                  : 1.0),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //---------------------App Bar------------------------------//

  Widget _appBar() {
    return SafeArea(
      child: InkWell(
          onTap: () {},
          child: StreamBuilder(
              stream: APIs.getUserInfo(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];

                return Row(
                  children: [
                    //back button
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black54)),

                    //user profile picture
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .03),
                      child: CachedNetworkImage(
                        width: mq.height * .05,
                        height: mq.height * .05,
                        fit: BoxFit.cover,
                        imageUrl:
                            list.isNotEmpty ? list[0].image : widget.user.image,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(child: Icon(Icons.person)),
                      ),
                    ),

                    //for adding some space
                    const SizedBox(width: 10),

                    //user name & last seen time
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //user name
                        Text(list.isNotEmpty ? list[0].name : widget.user.name,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500)),

                        //for adding some space
                        const SizedBox(height: 2),

                        //last seen time of user
                        Text(
                            list.isNotEmpty
                                ? list[0].isOnline
                                    ? 'Online'
                                    : Dialogs.getLastActiveTime(
                                        context: context,
                                        lastActive: list[0].lastActive)
                                : Dialogs.getLastActiveTime(
                                    context: context,
                                    lastActive: widget.user.lastActive),
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54)),
                      ],
                    )
                  ],
                );
              })),
    );
  }

  //---------------------Chat Input Field---------------------//

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.only(
          top: mq.height * .01,
          bottom: mq.height * .015,
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
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    onTap: () {
                      if (_showEmoji)
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                    },
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
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 70);
                        if (image != null)
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                      },
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
                APIs.sendMessage(widget.user, _textController.text, Type.text);
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
