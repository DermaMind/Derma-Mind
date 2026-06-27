import 'package:dermamind_app/utils/app_color.dart';
import 'package:flutter/material.dart';

import '../skin_test/reuseble_component/questionHeader.dart';
import '../utils/app_style.dart';
import 'camera_scan.dart';

class ScanFaceScreen extends StatelessWidget {
  static const String routeName = "scanFace";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuestionHeader(
                title: "Scan your face",
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  "Please upload a clear image of the affected area only for accurate analysis.",
                  textAlign: TextAlign.center,
                  style: AppStyle.scanText,
                ),
              ),

              const SizedBox(height: 25),

                 Container(

                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                
                  child: Column(

                    children: [
                      Text(
                        "Snap, Scan, Transform",
                        style: AppStyle.productDetailsText.copyWith(fontSize: 22),
                      ),
                
                      const SizedBox(height: 16),
                
                      _instructionItem(Icons.face, "Relax your face"),
                      const SizedBox(height: 16),
                      _instructionItem(Icons.block, "Do not apply any products"),
                      const SizedBox(height: 16),
                      _instructionItem(Icons.wb_sunny, "Sit in good lighting"),
                      const SizedBox(height: 16),
                      _instructionItem(Icons.timer, "Stay still for a few seconds"),
                    ],
                  ),
                ),

              SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      CameraScreen.routeName,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.selectedColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Get Started",style: AppStyle.priceDetailsText.copyWith(color: Colors.white,fontSize: 20),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _instructionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Text(text,style: AppStyle.regular.copyWith(fontSize: 18),),
        ],
      ),
    );
  }
}