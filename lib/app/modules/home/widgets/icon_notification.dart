import 'package:flutter/material.dart';

Widget iconNotification() {
  return Container(
    width: 30,
    height: 30,
    margin: EdgeInsets.only(right: 16),
    child: Stack(
      children: [
        Center(
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: SizedBox(
            width: 3,
            height: 3,
            child: Icon(
              Icons.circle,
              size: 10,
              color: Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}
