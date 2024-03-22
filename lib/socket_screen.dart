import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketScreen extends StatefulWidget {
  const SocketScreen({super.key});

  @override
  State<SocketScreen> createState() => _SocketScreenState();
}

class _SocketScreenState extends State<SocketScreen> {
  // MARK: - Variables.

  late Socket socket;

  TextEditingController messageController = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connectToSocket();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  void connectToSocket() {
    socket = io(
      "http://127.0.0.1:63828",
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );
    socket.connect();
    socket.onConnect((data) => debugPrint("Connected to socket"));
    socket.onDisconnect((data) => debugPrint("Disconnect"));
    socket.on("groupChat", (data) {
      setState(() => messages.add(data[0]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Screen")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Enter a message",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => sendMessage(message: messageController),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void sendMessage({required TextEditingController message}) {
    if (message.text.isNotEmpty) {
      socket.emit("groupChat", message.text);
      message.clear();
    }
  }
}
