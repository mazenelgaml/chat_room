import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import '../rooms_list/rooms_list_screen.dart';

class AudioCallScreen extends StatefulWidget {
  final String channelId;
  final String token;
  final String chatUser;
  final String chatPassword;
  final String chatroomId;

  const AudioCallScreen({super.key, required this.chatUser, required this.chatPassword, required this.chatroomId, required this.channelId, required this.token});

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> with TickerProviderStateMixin{
  final String appId = dotenv.env['AGORA_APP_ID'] ?? "";
  late ChatClient _chatClient;
  bool isJoined = false;
  RtcEngine? _engine;
  Set<String> _messages = {};
  List <String> _users = [];
  final TextEditingController _messageController = TextEditingController();
  late SVGAAnimationController _svgaController;
  final SVGAParser _svgaParser = SVGAParser();
  String? _svgaFilePath;
  bool _isMuted = false;
  bool _isSoundClosed = false;
  bool _isSVGAPlaying = false;
  Timer? _timer;
  bool _isDisposed = false;
  int coins=10;


  @override
  void initState() {
    super.initState();
    coins=10;
    _svgaFilePath = "";
    _isSVGAPlaying=false;
    _svgaController = SVGAAnimationController(vsync: this);
    // Listener for SVGA animation completion
    _svgaController.addListener(() {
      if (_svgaController.isCompleted) {
        setState(() {
          _isSVGAPlaying = false;
        });
      }
    });
    // Request microphone permission and initialize Agora and chat if granted
    _requestPermissions().then((granted) async {
      if (granted) {
        initAgora();
        initAgoraChat();
        _getChatRoomMembers();
      }
    });
    // Periodically update chat room members list
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _getChatRoomMembers();

    });
    // Listen for new chat room members
    ChatClient.getInstance.chatRoomManager.addEventHandler(
      "chatRoomListener",
      ChatRoomEventHandler(
        onMemberJoinedFromChatRoom: (roomId, newMember) {
          print("🆕 عضو جديد دخل الغرفة: $newMember");
          if (mounted) {
            setState(() {
              _users.add(newMember);
            });
          }
        },
      ),
    );
  }
  @override

  // Toggle microphone mute state
  void _toggleMute() {
    if (_engine != null) {
      _isMuted = !_isMuted;
      _engine!.muteLocalAudioStream(_isMuted);
      setState(() {}); // تحديث الـ UI
    }
  }
  // Toggle sound playback
  void _toggleSound() {
    if (_engine != null) {
      _isSoundClosed = !_isSoundClosed;
      _engine!.adjustPlaybackSignalVolume(_isSoundClosed ? 0 : 100);
      setState(() {}); // تحديث الـ UI
    }
  }
  // Request microphone permission
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.microphone].request();
    return statuses[Permission.microphone] == PermissionStatus.granted;
  }
  // Initialize Agora for audio communication
  Future<void> initAgora() async {
    if (appId.isEmpty) {
      print("❌ AGORA_APP_ID غير موجود!");
      return;
    }

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: appId));
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableAudio();

    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() => isJoined = true);
        print("🎤 تم الانضمام إلى القناة الصوتية بنجاح");
      },
      onError: (ErrorCodeType error, String message) {
        print("⚠️ خطأ في الانضمام للقناة: $message (Code: $error)");
      },
    ));

    await _engine!.joinChannel(
      token: widget.token,
      channelId: widget.channelId,
      uid: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
      options: const ChannelMediaOptions(),
    );
  }
  // Initialize Agora Chat
  Future<void> initAgoraChat() async {
    await ChatClient.getInstance.init(ChatOptions(appKey: "411314433#1515795", autoLogin: false));
    _chatClient = ChatClient.getInstance;

    try {
      await _chatClient.login(widget.chatUser, widget.chatPassword);
      print("✅ تم تسجيل الدخول بنجاح");

      await _joinChatRoom();
      _startFetchingMessages(); // جلب الرسائل السابقة عند الدخول فقط
      // استخدام Future.delayed بالشكل الصحيح
      Future.delayed(Duration.zero, () {
        _chatClient = ChatClient.getInstance; // تهيئة الـ ChatClient
        _getChatRoomMembers(); // جلب الأعضاء بعد التهيئة
      });
      // ✅ الاستماع للرسائل الجديدة مباشرةً
      _chatClient.chatManager.addMessageEvent("chat_listener", ChatMessageEvent(
        onSuccess: (msgId, message) {
          _processIncomingMessage(message); // تمرير الرسالة بشكل صحيح
        },
        onProgress: (msgId, progress) {
          print("📡 جاري إرسال رسالة...");
        },
        onError: (msgId, message, error) { // أضفنا message هنا
          print("❌ خطأ في إرسال الرسالة: ${error.description}");
        },
      ));


    } catch (e) {
      print("❌ فشل في تسجيل الدخول: ${e.toString()}");
    }
  }
  // Join a chat room
  Future<void> _joinChatRoom() async {
    try {
      await _chatClient.chatRoomManager.joinChatRoom(widget.chatroomId);
      print("✅ تم الانضمام إلى غرفة الدردشة");
    } catch (e) {
      print("❌ فشل في الانضمام: ${e.toString()}");
    }
  }
  // Send a chat message
  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    try {
      final msg = ChatMessage.createTxtSendMessage(targetId: widget.chatroomId, content: message);
      msg.chatType = ChatType.ChatRoom;
      await _chatClient.chatManager.sendMessage(msg);
      _messageController.clear();
    } catch (e) {
      print("⚠️ خطأ في إرسال الرسالة: $e");
    }
  }

  // Fetch chat room members
  void _getChatRoomMembers() async {
    try {
      ChatCursorResult<String> result =
      await _chatClient.chatRoomManager.fetchChatRoomMembers(widget.chatroomId);

      List<String> members = result.data;

      if (mounted) {
        setState(() {
          _users = members;
        });
      }

      print("👥 أعضاء الغرفة: $_users");
    } catch (e) {
      print("❌ فشل في جلب الأعضاء: ${e.toString()}");
    }
  }

  // Function to download and send an SVGA file
  Future<void> sendSVGAFile(String fileUrl) async {
    try {
      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/animation.svga";

      print("📥 جاري تحميل ملف SVGA...");
      await dio.download(fileUrl, filePath);

      final file = File(filePath);
      if (await file.exists()) {
        print("✅ تم تحميل الملف: $filePath");

        final msg = ChatMessage.createFileSendMessage(
          targetId: widget.chatroomId,
          filePath: filePath,
          displayName: "animation.svga",
        );
        msg.chatType = ChatType.ChatRoom;

        await _chatClient.chatManager.sendMessage(msg);
        _isSVGAPlaying=true;
        print("✅ تم إرسال ملف SVGA عبر Agora!");
      } else {
        print("❌ فشل تحميل الملف.");
      }
    } catch (e) {
      print("⚠️ خطأ أثناء تحميل أو إرسال ملف SVGA: $e");
    }
  }

  // Function to start fetching messages every 5 seconds
  void _startFetchingMessages() async {
    await _fetchNewMessages();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchNewMessages();
    });
  }

  // Function to fetch new messages from the chatroom
  Future<void> _fetchNewMessages() async {
    try {
      ChatCursorResult<ChatMessage> result = await _chatClient.chatManager.fetchHistoryMessages(
        conversationId: widget.chatroomId,
        type: ChatConversationType.ChatRoom,
        pageSize: 1,
      );

      List<ChatMessage> newMessages = result.data;
      setState(() {
        for (var msg in newMessages) {
          _processIncomingMessage(msg);
        }
      });
    } catch (e) {
      print("⚠️ خطأ في جلب الرسائل الجديدة: $e");
    }
  }

  // Function to process an incoming chat message
  void _processIncomingMessage(ChatMessage msg) async {
    if (msg.body is ChatTextMessageBody) {
      String formattedMessage = "${msg.from}: ${(msg.body as ChatTextMessageBody).content}";
      // Handle text messages
      if (!_messages.contains(formattedMessage)) {
        if (mounted) {
          setState(() {
            _messages.add(formattedMessage);
          });
        }
        print(" رسالة جديدة: $formattedMessage");
      }// Handle file messages
    } else if (msg.body is ChatFileMessageBody) {
      ChatFileMessageBody fileBody = msg.body as ChatFileMessageBody;
      if (fileBody.displayName!.endsWith(".svga")) {
        print(" تم استقبال ملف SVGA: ${fileBody.remotePath}");

        final dir = await getApplicationDocumentsDirectory();
        final localFilePath = "${dir.path}/${fileBody.displayName}";

        final dio = Dio();
        await dio.download(fileBody.remotePath!, localFilePath);

        if (mounted) {
          setState(() {
            if (_svgaFilePath == localFilePath) return;
            _svgaFilePath = localFilePath;
            _isSVGAPlaying = false;
          });
        }

        print(" تم حفظ ملف SVGA محليًا: $localFilePath");

        final file = File(localFilePath);
        final bytes = await file.readAsBytes();
        final videoItem = await _svgaParser.decodeFromBuffer(bytes);

        if (mounted) {
          _svgaController.videoItem = videoItem;

          _svgaController.forward();
          // Stop animation after 10 seconds
          Future.delayed(Duration(seconds: (10).toInt()), () {
              _isSVGAPlaying=false;
              _svgaController.stop();
              _svgaFilePath = "";

          });


        }

      }
    }
  }



  @override
  // Function to clean up resources when the widget is disposed
  void dispose() {
    if (mounted) {
      if (_svgaController.isAnimating) {
        _svgaController.stop();
      }
      if (!_isDisposed) {
        _svgaController.dispose();
        _isDisposed = true;
      }
      _messageController.dispose();
      _engine?.leaveChannel();
      ChatClient.getInstance.chatRoomManager.removeEventHandler("chatRoomListener");
      _chatClient.chatRoomManager.leaveChatRoom(widget.chatroomId);

      _chatClient.logout();
      _chatClient.chatManager.removeMessageEvent("chat_listener");
      _timer?.cancel();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.channelId,
          style: GoogleFonts.cairo(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xff7E57C2),
        centerTitle: true,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Row(

              children: [
                Icon(Icons.monetization_on,color: Colors.amber,size: 20,),
                Text("$coins",style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),)
              ],
            ),
          )
        ],
      ),

      body: Column(
        children: [

          SizedBox(
            height: 100,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: _users.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Color(0xff7E57C2),
                        child: Text(
                          _users[index].substring(0, 1).toUpperCase(),
                          style: GoogleFonts.cairo(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(_users[index], style: GoogleFonts.cairo(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              },
            ),
          ),


          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: ListView.builder(
                key: PageStorageKey('messages_list'),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade300, Color(0xff7E57C2)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _messages.elementAt(index),
                        style: GoogleFonts.cairo(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),


          if (_isSVGAPlaying)
            Expanded(child: SVGAImage(_svgaController)),

          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.green,
                  onTap: _toggleMute,
                ),
                _buildControlButton(
                  icon: _isSoundClosed ? Icons.volume_off : Icons.volume_up,
                  color: _isSoundClosed ? Colors.grey : Colors.blue,
                  onTap: _toggleSound,
                ),
                _buildControlButton(
                  icon: Icons.favorite,
                  color: Color(0xff7E57C2),
                  onTap: () {
                    if(coins > 0){
                      sendSVGAFile("https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/heartbeat.svga");
                      coins-=10;
                    }
                    else{
                      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text('you should recharge send it again')));
                    }
                  },
                ),
                _buildControlButton(
                  icon: Icons.call_end,
                  color: Colors.redAccent,
                  onTap: () async {
                    _svgaFilePath = "";
                    _isSVGAPlaying=false;
                    _svgaController.stop();
                    _svgaController.dispose();
                    _chatClient.logout();


                    Get.to(() => RoomListScreen(
                      chatUser: widget.chatUser,
                      chatPassword: widget.chatPassword,
                    ));
                  },
                ),
              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Enter your message here...✍️ ",
                        hintStyle: GoogleFonts.cairo(color: Colors.grey.shade600),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade300, Color(0xff7E57C2)],
                    ),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 28),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}


Widget _buildControlButton({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, offset: Offset(2, 2)),
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(-2, -2)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    ),
  );
}
