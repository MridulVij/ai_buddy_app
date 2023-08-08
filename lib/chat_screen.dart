import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ads.dart';

class ChatGPTScreen extends StatefulWidget {
  const ChatGPTScreen({super.key});

  @override
  _ChatGPTScreenState createState() => _ChatGPTScreenState();
}

class _ChatGPTScreenState extends State<ChatGPTScreen> {
  @override
  void initState() {
    super.initState();
    readText();
    _textEditingController.addListener(_updateButtonVisibility);
    ads.createInterstitialAd();
  }

  final List<Message> _messages = [];
  Ads ads = Ads();
  String? error;
  String? apiKey;
  bool _showClearButton = false;
  final TextEditingController _textEditingController = TextEditingController();
  TextEditingController apikeycontroller = TextEditingController();
  bool isLoading = false;

  void onSendMessage() async {
    Message message = Message(text: _textEditingController.text, isMe: true);
    _textEditingController.clear();
    setState(() {
      _messages.insert(0, message);
      isLoading = true;
    });
    String response = await sendMessageToChatGpt(message.text);
    Message chatGpt = Message(text: response, isMe: false);
    setState(() {
      _messages.insert(0, chatGpt);
      isLoading = false;
      // showing ads
      ads.showInterstitialAd();
    });
  }

  Future<String> sendMessageToChatGpt(String message) async {
    try {
      Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");

      Map<String, dynamic> body = {
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": message}
        ],
        "max_tokens": 500,
      };

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: json.encode(body),
      );

      print(response.body);

      Map<String, dynamic> parsedReponse = json.decode(response.body);

      String reply = parsedReponse['choices'][0]['message']['content'];

      return reply;
    } catch (e) {
      setState(() {
        error = e.toString();
      });
      return "Hi,\nBefore Starting Conversation! \nI Need Secret Key, Press 'Settings' Button and Enter your own key!\nThen i Confirm that you are really a Human Being!\nThank You,\nAI BUDDY";
    }
  }

  //
  void saveFile(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("api", text);
  }

  void readText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedvalue = prefs.getString("api");
    if (savedvalue != null) {
      apiKey = savedvalue;
    }
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_updateButtonVisibility);
    _textEditingController.dispose();
    super.dispose();
  }

  void _updateButtonVisibility() {
    setState(() {
      _showClearButton = _textEditingController.text.isNotEmpty;
    });
  }

  void _toggleMessage() {
    if (_showClearButton) {
      // _textEditingController.clear();

      onSendMessage();
    } else {
      // Implement your logic to send the message
      _textEditingController.clear();
      // Add your logic here to send the message.
      // For example, you can send the message using a network call, saving it to a database, etc.
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    const snackBar = SnackBar(
      content: Text('Copied to clipboard'),
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  //

  Widget _buildMessage(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.isMe ? 'You' : 'Buddy',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.deepPurple[50]),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: SelectableText(
                  message.text,
                  onTap: () => _copyToClipboard(context, message.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI BUDDY!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Key Settings'),
                  content: TextField(
                    controller: apikeycontroller,
                    decoration: const InputDecoration(
                        hintText: 'Paste your Secret Key',
                        border: OutlineInputBorder()),
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Colors.deepPurple[100])),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.deepPurple)),
                          onPressed: () async {
                            saveFile(apikeycontroller.text);
                            readText();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        const String videoId = 'fGATLXRoJD8';
                        Uri uri = Uri.parse(
                            'https://www.youtube.com/watch?v=$videoId');
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            height: 20,
                            width: 20,
                            image: AssetImage('assets/images/yt.png'),
                          ),
                          Text(
                            ' How to get Secret Key?',
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        Uri uri = Uri.parse(
                            'https://platform.openai.com/docs/quickstart/build-your-application');
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            height: 20,
                            width: 20,
                            image: AssetImage('assets/images/openai.png'),
                          ),
                          Text(
                            ' Create Account! Get Secret Key!',
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.deepPurple,
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          // isLoading == true ? LinearProgressIndicator() : Container(),
          const Divider(height: 1.0),
          isLoading == true ? const LinearProgressIndicator() : Container(),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: _textEditingController,
                      onChanged: (text) {
                        _updateButtonVisibility();
                      },
                      cursorColor: Colors.deepPurple,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Lets Chat, Enter Message!',
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            backgroundColor: _showClearButton
                                ? Colors.deepPurple
                                : Colors.grey[200],
                            radius: 25,
                            child: IconButton(
                              icon: _showClearButton
                                  ? const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    )
                                  : const Icon(
                                      Icons.send,
                                      color: Colors.grey,
                                    ),
                              onPressed: _toggleMessage,
                            ),
                          ),
                        ),
                      ),
                    ),
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

class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}
