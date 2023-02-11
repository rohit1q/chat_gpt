import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chatmessage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key}) ;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages =[];
  ChatGPT? chatGPT;

  StreamSubscription? _subscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatGPT =ChatGPT.instance;
  }

  @override
  void dispose(){
    _subscription?.cancel();
    super.dispose();
  }
  void _sendMessage(){
    ChatMessage _message = ChatMessage(text: _controller.text, sender: "user");
    setState(() {
      _messages.insert(0, _message);
    });
    _controller.clear();
    final request =CompleteReq(
        prompt: _message.text, model: kTranslateModelV3,max_tokens: 200);
    _subscription = chatGPT!
        .builder("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")
    .onCompleteStream(request: request)
    .listen((response){
        Vx.log(response!.choices[0].text);
      ChatMessage botMessage =
           ChatMessage(text: response.choices[0].text, sender: "bot");

      setState(() {
        _messages.insert(0, botMessage);
      });
    });
  }
  Widget _buildTextComposer(){
    return Row(
      children: [
         Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (value) =>_sendMessage(),
              decoration:
                 const InputDecoration.collapsed(hintText: "send a massage"),
            ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () =>_sendMessage(),
        ),
        ],

    ).px16();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("ChatGPT App"))),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
                  reverse: true,
                  padding: Vx.m8,
                  itemCount: _messages.length,
                    itemBuilder: (context,index) {
                  return _messages[index];
                  },
                )),

            Container(
              decoration: BoxDecoration(
                color: context.cardColor,
              ),
              child: _buildTextComposer(),
            )
          ],
        ),
      ),
    );
  }
}
