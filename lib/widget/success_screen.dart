// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mini_mart/styles/colors.dart';
import 'package:mini_mart/styles/fonts.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "SUCCESS!",
                style: TextStyle(
                  color: black,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: kantumruyPro,
                ),
              ),
              SizedBox(height: 30),
              Image.asset(
                "assets/images/shopping/success_image.png",
                width: 200,
                height: 200,
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: success,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(Icons.check, color: white, size: 20),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: const Text(
                  "Your order will be delivered soon.\nThank you for choosing our app!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: kantumruyPro,
                  ),
                ),
              ),
              SizedBox(height: 50),
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellow[800],
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Text(
                  'TRAK ORDER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: kantumruyPro,
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {},
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: black, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Back to Home',
                    style: const TextStyle(
                      color: black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: kantumruyPro,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
