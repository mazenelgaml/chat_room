import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled1/ui/room/room_screen.dart';
import 'package:untitled1/ui/welcome/welcome_screen.dart';

class RoomListScreen extends StatelessWidget {
  final String chatUser;
  final String chatPassword;

  const RoomListScreen({super.key, required this.chatUser, required this.chatPassword});

  final List<String> rooms = const [
    "Room 1",
    "Room 2",
    "Room 3",
    "Room 4",
    "Room 5"
  ];
  final List<String> tokens = const [
    "007eJxTYFDudC8wdLiyfdqB54eqdybwaPA/36cwa+LD2m/LOO/PPRKmwGCemGycbGKcamhulGySmpaUmGpsnJiSYpGcnGqQnGSU7HLiTnpDICPD5cfajIwMEAjiszEE5efnKhgyMAAAKfciyQ==",
    "007eJxTYAiaIlW0+nsrY/bs5bOsT13N4218FcyevHiOz9zmN/M6/pxVYDBPTDZONjFONTQ3SjZJTUtKTDU2TkxJsUhOTjVITjJKjjtxJ70hkJFh974YRkYGCATx2RiC8vNzFYwYGAAzsCL+",
    "007eJxTYPh5L6JdrNWVa632hutM0gx1DkkqecEWSuwxDjVn1Le76CgwmCcmGyebGKcamhslm6SmJSWmGhsnpqRYJCenGiQnGSWXnriT3hDIyLDsoyszIwMEgvhsDEH5+bkKxgwMAKf9He8=",
    "007eJxTYEguy5U+9en4FbGQiLn8t1s2P4laXvN+V4xN6ZEss/u7j15XYDBPTDZONjFONTQ3SjZJTUtKTDU2TkxJsUhOTjVITjJKnnTiTnpDICND+d79LIwMEAjiszEE5efnKpgwMAAAmFAkWg==",
    "007eJxTYJD/uXmz+qzilUaXfz97fsroqfNd/eOHz4puOMZ1foPE5cMHFBjME5ONk02MUw3NjZJNUtOSElONjRNTUiySk1MNkpOMkleduJPeEMjI8PaCEiMjAwSC+GwMQfn5uQqmDAwAE98lpA=="
  ];
  final List<String> chatroomsId = const [
    "275709438263297",
    "275709468672001",
    "275709483352065",
    "275709499080707",
    "275709515857922"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Select a Room", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: rooms.length,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Get.to(() => AudioCallScreen(
                  channelId: rooms[index],
                  token: tokens[index],
                  chatUser: chatUser,
                  chatPassword: chatPassword,
                  chatroomId: chatroomsId[index],
                ));
              },
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
                    ),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
                      Text(
                        rooms[index],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.defaultDialog(
            title: "Log out",
            titleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            middleText: "Are you sure you want to log out?",
            middleTextStyle: TextStyle(fontSize: 16),
            textCancel: "Cancel",
            textConfirm: "Confirm",
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.to(() => WelcomeScreen());
            },
            buttonColor: Colors.red,
            radius: 10,
          );
        },
        label: Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
        icon: Icon(Icons.logout, color: Colors.white),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
