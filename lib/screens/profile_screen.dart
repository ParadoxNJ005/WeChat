import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser? user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String about = '';
  String? _image;
  String pickedImage = '';

  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('we chat'),
          actions: [],
        ),

        //floating button to add new user
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Container(
            child: FloatingActionButton.extended(
              backgroundColor: Color.fromARGB(255, 244, 118, 118),
              onPressed: () async {
                await APIs.updateActiveStatus(false);

                //sign out from app
                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //for moving to home screen
                    Navigator.pop(context);

                    APIs.auth = FirebaseAuth.instance;

                    //replacing home screen with login screen
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  });
                });
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ), // Use named parameter `icon`
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ), // Use named parameter `label`
            ),
          ),
        ),

        body: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: mq.width,
                      height: mq.height * .03,
                    ),
                    Stack(
                      children: [
                        //user image area--------------------------------
                        _image != null
                            ? Positioned(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(mq.height * 0.25),
                                  child: Image.file(
                                    File(_image!),
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Positioned(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(mq.height * 0.25),
                                  child: CachedNetworkImage(
                                    height: mq.height * .25,
                                    width: mq.width * .55,
                                    imageUrl: widget.user != null
                                        ? widget.user!.image
                                        : "",
                                    imageBuilder: (context, imageProvider) =>
                                        ClipOval(
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
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),

                        //add button area-----------------------------------------------------
                        Positioned(
                          child: InkWell(
                            onTap: () async {
                              _showBottomSheet();
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 170, left: 160),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white,
                                          spreadRadius: 5,
                                          blurRadius: 1,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit,
                                    size: 30,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    //add email area------------------------------------------------------------
                    SizedBox(height: mq.height * 0.03),
                    Text(
                      widget.user!.email,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 20),
                    ),

                    //form field area------------------------------------------------------------
                    SizedBox(height: mq.height * 0.05),
                    TextFormField(
                      initialValue: widget.user!.name,
                      validator: (value) => value != null && value.isNotEmpty
                          ? null
                          : 'Required Field',
                      onSaved: (value) {
                        setState(() {
                          name = value!;
                        });
                      },
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Mokshe Jain',
                          label: Text('Name')),
                    ),

                    SizedBox(height: mq.height * 0.02),
                    TextFormField(
                      initialValue: widget.user!.about,
                      validator: (value) => value != null && value.isNotEmpty
                          ? null
                          : 'Required Field',
                      onSaved: (value) {
                        setState(() {
                          about = value!;
                        });
                      },
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Busy',
                          label: Text('about')),
                    ),

                    //update button area----------------------------------------------------------
                    SizedBox(height: mq.height * 0.05),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          await APIs.updateUser(name, about);

                          Dialogs.showSnackbar(
                              context, 'Profile Updated Successfully');
                        }
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 24,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Update',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          iconColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size(200, 50)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              const Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/add_image.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? file = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (file != null) {
                          setState(() {
                            _image = file.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
