import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../utils/ui_utils.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: "Contact us"
      ),
      body: Column(
       children: [
         Container(
           padding: EdgeInsets.only(left: 20,right: 20,top: 25,bottom: 23),
           decoration: BoxDecoration(
               color: Color(0xfff6faff),
               borderRadius: BorderRadius.only(
                 bottomRight: Radius.circular(25),
                 bottomLeft:  Radius.circular(25),
               ),
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Text("How Can We Help You?",
                  style: TextStyle(
                    color: Color(0xff333333),
                    fontSize: 18
                  ),
                ),
                SizedBox(height: 17,),
                Text("It Look likes you have problems with our systems we are here to help you, so, please get in touch with us",
                  style: TextStyle(
                      color: Color(0xff787879),
                      fontSize: 11
                  ),
                ),
             ],
           ),
         ),
         SizedBox(height: 20,),
         Container(
           margin: EdgeInsets.only(left: 20,right: 20),
           padding: EdgeInsets.only(left: 18,right: 18,top: 25,bottom: 23),
           decoration: BoxDecoration(
             color: Color(0xfff9f9f9),
             borderRadius: BorderRadius.circular(20)
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               InkWell(
                 onTap: () => launchUrlString("tel://21213123123"),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Row(
                       children: [
                        Image.asset("assets/AddPostforms/_-105.png",width: 19,height: 19,),
                         SizedBox(width: 8,),
                         Text("Call",
                           style: TextStyle(
                               color: Color(0xff333333),
                               fontSize: 13,
                               fontWeight: FontWeight.w500
                           ),
                         ),
                       ],
                     ),
                     Image.asset("assets/AddPostforms/_-107.png",width: 13,height: 13,),
                   ],
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top: 15,bottom: 15),
                 child: Divider(color: Color(0xffdbdbdb),thickness: 1,),
               ),
               InkWell(
                 onTap: () => launchUrlString("mailto:example@gmail.com"),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Row(
                       children: [
                         Image.asset("assets/AddPostforms/_-106.png",width: 19,height: 19,),
                         SizedBox(width: 8,),
                         Text("Email",
                           style: TextStyle(
                               color: Color(0xff333333),
                               fontSize: 13,
                               fontWeight: FontWeight.w500
                           ),
                         ),
                       ],
                     ),
                     Image.asset("assets/AddPostforms/_-107.png",width: 13,height: 13,),
                   ],
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
