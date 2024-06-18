import 'dart:ffi';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/member.dart';
import 'package:we_chat/models/message.dart';

class GroupDetail extends StatefulWidget {
  final Member member;
  const GroupDetail({super.key, required this.member});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  @override
  void initState() {
    super.initState();
    _fetchAdminDetails();
  }

  Future<void> _fetchAdminDetails() async {
    String theAdminId = widget.member.adminid;
    await APIs.getAdminDetails(theAdminId);
    setState(() {});
  }

  late List<ChatUser> _list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        title: Text(
          'Community Info',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
        ),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              thickness: 2,
              color: Colors.grey,
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Admin",
                style: TextStyle(fontSize: 20),
              ),
            ),
            ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    height: mq.height * .085,
                    width: mq.width * .14,
                    imageUrl: APIs.Admin!.image,
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
                title: Text(APIs.Admin!.name),
                subtitle: Text(
                  APIs.Admin!.about,
                  maxLines: 1,
                ),
                trailing: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade400,
                    shape: BoxShape.circle,
                  ),
                )),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Members",
                style: TextStyle(fontSize: 20),
              ),
            ),
            StreamBuilder(
                stream: APIs.getGroupMembers(widget.member),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.length == 0) {
                          return Center(
                            child: Container(
                              child: Text("No Data Found",
                                  style: TextStyle(fontSize: 35)),
                            ),
                          );
                        } else {
                          return ListView.builder(
                              itemCount: _list.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return listTile(_list[index]);
                              });
                        }
                      } else {
                        return Center(
                          child: Text("No Data Found",
                              style: TextStyle(fontSize: 35)),
                        );
                      }
                    default:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                })
          ],
        ),
      ),
    );
  }

  Widget? listTile(ChatUser user) {
    return user.id != APIs.Admin!.id
        ? ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.03),
              child: CachedNetworkImage(
                height: mq.height * 0.085,
                width: mq.width * 0.14,
                imageUrl: user.image,
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
            title: Text(user.name),
            subtitle: Text(
              user.about,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade400,
                shape: BoxShape.circle,
              ),
            ),
          )
        : Container();
  }
}
