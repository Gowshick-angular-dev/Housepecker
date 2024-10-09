import 'package:flutter/widgets.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/ui_utils.dart';
import '../home_screen.dart';

class HomeSearchField extends StatelessWidget {
  final Map? banner;
  const HomeSearchField({super.key, this.banner});

  @override
  Widget build(BuildContext context) {
    Widget buildSearchIcon() {
      return Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color(0xff117af9),
            ),
            child: Center(
              child: Image.asset("assets/Home/__Search.png",width: 23,height: 23,),
            ),
          ));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                // if(banner != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: UiUtils.imageType(banner != null ? banner!['home_banner'] : '',
                      fit: BoxFit.cover,
                      color: Constant.adaptThemeColorSvg
                          ? context.color.tertiaryColor
                          : null),
                ),
                // if(banner == null)
                //   Image.asset(
                //     'assets/Home/__Home header .png',
                //     width: double.infinity,
                //     fit: BoxFit.cover,
                //   ),
                SizedBox(height: 25,)
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 0,
            left: 0,
            top: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(banner != null ? banner!['home_banner_title'] : '',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                  ),
                ),
                Text(banner != null ? banner!['home_banner_subtitle'] : '',
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w300,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: sidePadding,),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.pushNamed(context, Routes.filterScreen);
                      // arguments: {"autoFocus": true, "openFilterScreen": false});
                },
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    padding: EdgeInsets.only(left: 20,right: 3,top: 3,bottom: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: Color(0xffdbdbdb)),
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          color: Colors.white),
                      child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            border: InputBorder.none, //OutlineInputBorder()
                            fillColor: Theme.of(context).colorScheme.secondaryColor,
                            hintText: UiUtils.getTranslatedLabel(
                                context, "Search Here.."),
                            hintStyle: TextStyle(
                              color: Color(0xff9c9c9c),
                              fontSize: 13,
                              fontWeight: FontWeight.w500
                            ),
                            suffixIcon: buildSearchIcon(),
                            prefixIconConstraints:
                                const BoxConstraints(minHeight: 5, minWidth: 5),
                          ),
                          enableSuggestions: true,
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                          },
                          onTap: () {
                            //change prefix icon color to primary
                          })),
                ),
              ),

              // const Spacer(),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pushNamed(context, Routes.propertyMapScreen);
              //   },
              //   child: Container(
              //     width: 50.rw(context),
              //     height: 50.rh(context),
              //     decoration: BoxDecoration(
              //       border:
              //           Border.all(width: 1.5, color: context.color.borderColor),
              //       color: context.color.secondaryColor,
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Center(
              //       child: UiUtils.getSvg(
              //         AppIcons.propertyMap,
              //         color: context.color.tertiaryColor,
              //       ),
              //     ),
              //   ),
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
