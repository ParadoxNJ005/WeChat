import 'package:flutter/material.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallInvite extends StatefulWidget {
  final ChatUser user;
  const CallInvite({super.key, required this.user});

  @override
  State<CallInvite> createState() => _CallInviteState();
}

class _CallInviteState extends State<CallInvite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ZegoSendCallInvitationButton(
          isVideoCall: true,
          resourceID: "zegouikit_call",
          invitees: [
            ZegoUIKitUser(
              id: widget.user.id,
              name: widget.user.name,
            ),
          ],
        ),
      ),
    );
  }
}
