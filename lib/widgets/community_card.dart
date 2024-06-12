import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/member.dart';

class CommunityCard extends StatefulWidget {
  final Member member;
  const CommunityCard({super.key, required this.member});

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  final ChatUser user = APIs.me;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Card(
            margin:
                EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
            elevation: 0.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //-----------------------------------------------------------Admin Image and details---------------------------------------------------//
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      height: mq.height * .085,
                      width: mq.width * .14,
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
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "Admin",
                    maxLines: 1,
                  ),
                  trailing: user.id != ""
                      ? ElevatedButton.icon(
                          onPressed: () async {},
                          icon: Icon(
                            Icons.people_alt,
                            size: 24,
                          ),
                          label: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              'Edit',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              iconColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              minimumSize: Size(100, 50)),
                        )
                      : ElevatedButton.icon(
                          onPressed: () async {},
                          icon: Icon(
                            Icons.group_add_rounded,
                          ),
                          label: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              'Join',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              iconColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              minimumSize: Size(100, 50)),
                        ),
                ),
                //---------------------------------------------------------community image----------------------------------------------------------//
                SizedBox(
                  height: 10,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    height: mq.height * .17,
                    width: double.infinity,
                    imageUrl: widget.member.cimage,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),

                ListTile(
                  title: Text(
                    widget.member.cname,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    widget.member.cgoal,
                    maxLines: 1,
                  ),
                ),

                SizedBox(
                  height: 10,
                ),
              ],
            )));
  }
}
