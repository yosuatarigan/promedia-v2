import 'package:flutter/material.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Image.asset('assets/3.png', width: size.width * 0.6),
          ),
          Image.asset('assets/2.png', width: size.width * 0.8),
          Align(
            alignment: Alignment.centerLeft,
            child: Image.asset('assets/4.png', width: size.width * 0.8),
          ),
        ],
      ),
    );
  }
}
