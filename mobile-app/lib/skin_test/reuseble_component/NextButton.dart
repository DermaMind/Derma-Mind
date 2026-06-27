import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';

class NextButton   extends StatelessWidget {
  final bool enabled;
  final String title;
  final VoidCallback onPressed;
  const  NextButton({super.key,this.enabled=false,required this.onPressed,required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled?onPressed:null,//to be clickable
      child: Container(
        width:double.infinity ,
        height:60 ,
        decoration: BoxDecoration(
          color: enabled? AppColor.selectedColor:Colors.blue.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            title,
            style: AppStyle.regular.copyWith(color: AppColor.white2Color),
          ),
        ),
      ),
    );
  }
}

