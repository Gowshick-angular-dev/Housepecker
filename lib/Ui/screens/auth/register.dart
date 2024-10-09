import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../app/routes.dart';
import '../../../utils/Network/apiCallTrigger.dart';
import '../../../utils/guestChecker.dart';
import '../../../utils/hive_utils.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  String dropdownvalue4 = 'Agent/Agency';
  var items4 =  ['Agent/Agency','Agent','Agency'];
  bool? check1 = false;


  loadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Dialog(
          elevation: 0.0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Wrap(
            children: [
              Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SpinKitRing(
                      color: Color(0xff117af9),
                      size: 40.0,
                      lineWidth: 1.2,
                    ),
                    SizedBox(height: 25.0),
                    Text(
                      'Please Wait..',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );



    Timer(
        Duration(seconds: 3),
            () =>  Navigator.pushReplacementNamed(
              context,
              Routes.main,
              arguments: {
                "from": "login",
                "isSkipped": true,
              },
            ));
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xfff6faff),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.none,
                        child: MaterialButton(
                          padding :EdgeInsets.only(left: 10,right: 10,top: 0,bottom: 0),
                          color: Color(0xffe6f1ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            // side: BorderSide(
                            //     color: context.color.borderColor, width: 1.5),
                          ),
                          elevation: 0,
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.main,
                              arguments: {
                                "from": "login",
                                "isSkipped": true,
                              },
                            );
                          },
                          child: const Text("Skip",style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff117af9)
                          ),),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),

                Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: Color(0xff333333),
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: 8,),
                      Text("I'am",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontFamily: 'Manrope',
                          color: Color(0xff333333),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 8),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: Color(0xfff5f5f5)
                            ),
                            color: Color(0xfff5f5f5),
                            borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                borderRadius: BorderRadius.circular(8),
                                elevation: 1,
                                dropdownColor:Colors.white,
                                value: dropdownvalue4,
                                style: TextStyle(
                                  color: Color(0xff848484),
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.none,
                                ),
                                icon: Icon(Icons.keyboard_arrow_down,color:Colors.black,size: 23,),
                                items:items4.map((String items) {
                                  return DropdownMenuItem(
                                      value: items,
                                      child: Text(items)
                                  );
                                }
                                ).toList(),
                                onChanged: (String? newValue){
                                  setState(() {
                                    dropdownvalue4 = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8,),

                      SizedBox(height: 8,),
                      Text('Full Name',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontFamily: 'Manrope',
                          color: Color(0xff333333),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: Color(0xfff5f5f5)
                            ),
                              color: Color(0xfff5f5f5),
                            borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15.0,left: 15),
                            child: TextFormField(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                              decoration: const InputDecoration(
                                  hintText: 'Enter Full Name',

                                  suffixStyle: TextStyle(
                                    color: Color(0xff848484),
                                    fontSize: 13,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),

                                  hintStyle: TextStyle(
                                    color: Color(0xff848484),
                                    fontSize: 13,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent, // Remove the border
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                      ))
                              ),

                              validator: (value) {
                                return null;
                              },

                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8,),



                      Text('Phone Number',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontFamily: 'Manrope',
                          color: Color(0xff333333),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: Color(0xfff5f5f5)
                            ),
                              color: Color(0xfff5f5f5),
                            borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15.0,left: 15),
                            child: TextFormField(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                              decoration: const InputDecoration(
                                  hintText: 'Enter Phone Number',

                                  suffixStyle: TextStyle(
                                    color: Color(0xff848484),
                                    fontSize: 13,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),

                                  hintStyle: TextStyle(
                                    color: Color(0xff848484),
                                    fontSize: 13,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent, // Remove the border
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                      ))
                              ),

                              validator: (value) {
                                return null;
                              },

                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8,),

                      Text('Email Address',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontFamily: 'Manrope',
                          color: Color(0xff333333),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: Color(0xfff5f5f5)
                            ),
                              color: Color(0xfff5f5f5),
                            borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15.0,left: 15),
                            child: TextFormField(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                              decoration: const InputDecoration(
                                  hintText: 'Enter Email Address',

                                  suffixStyle: TextStyle(
                                    color: Color(0xff848484),
                                    fontSize: 13,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),

                                  hintStyle: TextStyle(
                                    color: Color(0xff848484),
                                    fontSize: 13,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent, // Remove the border
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                      ))
                              ),

                              validator: (value) {
                                return null;
                              },

                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8,),


                      Text('Company Name',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontFamily: 'Manrope',
                          color: Color(0xff333333),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: Color(0xfff5f5f5)
                            ),
                            color: Color(0xfff5f5f5),
                            borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15.0,left: 15),
                            child: TextFormField(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                              decoration: const InputDecoration(
                                  hintText: 'Enter Company Name',

                                  suffixStyle: TextStyle(
                                    color: Color(0xff848484),
                                    fontSize: 13,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),

                                  hintStyle: TextStyle(
                                    color: Color(0xff848484),
                                    fontSize: 13,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent, // Remove the border
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                      ))
                              ),

                              validator: (value) {
                                return null;
                              },

                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8,),

                      Padding(
                        padding: const EdgeInsets.only(left: 3,right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 20,
                              child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                  side: MaterialStateBorderSide.resolveWith(
                                        (states) => BorderSide(width: 1.0, color: Color(0xff117af9)),
                                  ),
                                  value: check1, //unchecked
                                  onChanged: (bool? value){
                                    setState(() {
                                      check1 = value;
                                    });
                                  }
                              ),
                            ),
                            SizedBox(width: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("I Agree with the",
                                  style: TextStyle(
                                      color: Color(0xff7d7d7d),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                Text(" Terms & Conditions",
                                  style: TextStyle(
                                      color: Color(0xff117af9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500
                                  ),),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8,),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal:  2.0),
                        child: InkWell(
                          onTap: () => loadingDialog(),
                          // onTap: () {
                          //   Navigator.push(
                          //     context,
                          //     PageTransition(
                          //       type: PageTransitionType.rightToLeft,
                          //       child: Register(),
                          //     ),
                          //   );
                          // },
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            width: double.infinity,
                            height: 50.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Color(0xff117af9),
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Manrope',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Have an Account Already?',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontFamily: 'Manrope',
                                color: Color(0xff7d7d7d),
                                fontSize: 12,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: Text(' Login',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontFamily: 'Manrope',
                                color: Color(0xff117af9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

}
