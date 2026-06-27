

import 'package:dermamind_app/HomeScreen/wiidget/profile_Screen.dart';
import 'package:dermamind_app/Scan_Screen/scan_face_screen.dart';
import 'package:dermamind_app/doctors/doctors_screen.dart';
import 'package:dermamind_app/favorites/favorites_screen.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';

import '../HomeScreen.dart';

class mainLayout   extends StatefulWidget {

  static const String routeName = "mainLayout";

  @override
  State<mainLayout> createState() => _mainLayoutState();
}

class _mainLayoutState extends State<mainLayout> {
  static const double navIconSize = 28;
  int selectedIndex = 0;

  final List<Widget> tabs = [
    HomeScreen(),
    const DoctorsScreen(),
    const Center(child: Text("Camera")),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
          onTap: (index) {
            if (index == 2) {
              Navigator.pushNamed(context, ScanFaceScreen.routeName);
              return;
            }
            setState(() {
              selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 6,
          selectedItemColor: AppColor.blue2Color,
          unselectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items:[
            BottomNavigationBarItem(
              icon:Image.asset(selectedIndex==0?AssetsManager.homeFilled:AssetsManager.homeIconOutLinear,
                width: navIconSize,
                height: navIconSize,

                color: selectedIndex==0?AppColor.blue2Color:Colors.black38,) ,
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex==1?Icons.location_on:Icons.location_on_outlined,
    color: selectedIndex==1?AppColor.blue2Color:Colors.black38,size: navIconSize,),
             
              label: "map",
            ),


    BottomNavigationBarItem(
    icon: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: AppColor.blue2Color,
    shape: BoxShape.circle,
    ),
    child:  const Icon(
    Icons.camera_alt,
    color: Colors.white,
    size: navIconSize,
    ),
    ),
    label: "Camera",
    ),
            BottomNavigationBarItem(
              icon:Image.asset(selectedIndex==3?AssetsManager.loveFill:AssetsManager.loveOutlinear
                , width: navIconSize,
                height: navIconSize,
                color: selectedIndex==3?AppColor.blue2Color:Colors.black38,) ,
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex==4?Icons.person:Icons.person_outline,
                color: selectedIndex==4?AppColor.blue2Color:Colors.black38,size: navIconSize,),

              label: "person",
            ),


          ]


      ),



    );


  }
  
}
