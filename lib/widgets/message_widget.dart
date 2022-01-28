import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final bool isReceivedMessage;
  final String messageText;
  final bool hasImages;
  final List? imagesUrls;
  MessageWidget(
      {Key? key,
      required this.isReceivedMessage,
      required this.messageText,
      required this.hasImages,
      this.imagesUrls})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: isReceivedMessage
          ? EdgeInsets.only(right: size.width * .3, bottom: size.height * .01)
          : EdgeInsets.only(left: size.width * .3, bottom: size.height * .01),
      padding: EdgeInsets.symmetric(
          horizontal: size.width * .03, vertical: size.height * .01),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isReceivedMessage
              ? Colors.grey[200]
              : Theme.of(context).primaryColor),
      child: Align(
        alignment:
            !isReceivedMessage ? Alignment.centerLeft : Alignment.centerRight,
        child: hasImages
            ? Column(
                children: [
                  Text(messageText),
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: imagesUrls!.map((e) => Image.network(e)).toList(),
                  )
                ],
              )
            : Text(messageText),
      ),
    );
  }
}
