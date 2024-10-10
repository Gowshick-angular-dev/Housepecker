// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:Housepecker/Ui/screens/widgets/like_button_widget.dart';
import 'package:Housepecker/Ui/screens/widgets/promoted_widget.dart';
import 'package:Housepecker/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:Housepecker/utils/AppIcon.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:Housepecker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../data/model/property_model.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/ui_utils.dart';
import '../../proprties/interested_users_details.dart';
import '../../proprties/property_details.dart';

class PropertyHorizontalCard1 extends StatelessWidget {
  final PropertyModel property;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton1? statusButton1;
  final Function(FavoriteType type)? onLikeChange;
  final bool? useRow;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;
  const PropertyHorizontalCard1(
      {super.key,
        required this.property,
        this.useRow,
        this.addBottom,
        this.additionalHeight,
        this.onLikeChange,
        this.statusButton1,
        this.showDeleteButton,
        this.onDeleteTap,
        this.showLikeButton,
        this.additionalImageWidth});


  String formatAmount(int number) {
    String result = '';
    if(number >= 10000000) {
      result = '${(number/10000000).toStringAsFixed(2)} Cr';
    } else if(number >= 100000) {
      result = '${(number/100000).toStringAsFixed(2)} Laks';
    } else {
      result = '$number';
    }
    return result;
  }
  @override
  Widget build(BuildContext context) {
    String rentPrice = (property.price!
        // .priceFormate(
        //   disabled: Constant.isNumberWithSuffix == false,
        // )
        // .toString()
        // .formatAmount(prefix: true)
    );

    if (property.rentduration != "" && property.rentduration != null) {
      rentPrice =
          ("$rentPrice / ") + (rentDurationMap[property.rentduration] ?? "");
    }


    return BlocProvider(
      create: (context) => AddToFavoriteCubitCubit(),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(context, property.id!, property?.slugId ?? "");
        },
        child: Container(
          padding: EdgeInsets.all(8),
          height: addBottom == null ? 115 : (115 + (additionalHeight ?? 0)),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  width: 1,
                  color: Color(0xffe0e0e0)
              )
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [

                            UiUtils.getImage(
                              property.titleImage ?? "",
                              width:100,fit: BoxFit.cover,height: 100,
                            ),
                            // Text(property.promoted.toString()),
                            // if (showLikeButton ?? true)
                            //   Positioned(
                            //     right: 8,
                            //     top: 8,
                            //     child: Container(
                            //       width: 32,
                            //       height: 32,
                            //       decoration: BoxDecoration(
                            //         color: context.color.secondaryColor,
                            //         shape: BoxShape.circle,
                            //         boxShadow: const [
                            //           BoxShadow(
                            //             color:
                            //             Color.fromARGB(12, 0, 0, 0),
                            //             offset: Offset(0, 2),
                            //             blurRadius: 15,
                            //             spreadRadius: 0,
                            //           )
                            //         ],
                            //       ),
                            //       child: LikeButtonWidget(
                            //         property: property,
                            //         onLikeChanged: onLikeChange,
                            //       ),
                            //     ),
                            //   ),
                            if (property.promoted ?? false)
                              const PositionedDirectional(
                                  start: 5,
                                  top: 5,
                                  child: PromotedCard(
                                      type: PromoteCardType.icon)),
                            // PositionedDirectional(
                            //   bottom: 6,
                            //   start: 6,
                            //   child: Container(
                            //     height: 19,
                            //     clipBehavior: Clip.antiAlias,
                            //     decoration: BoxDecoration(
                            //         color: context.color.secondaryColor
                            //             .withOpacity(0.7),
                            //         borderRadius:
                            //         BorderRadius.circular(4)),
                            //     child: BackdropFilter(
                            //       filter: ImageFilter.blur(
                            //           sigmaX: 2, sigmaY: 3),
                            //       child: Padding(
                            //         padding: const EdgeInsets.symmetric(
                            //             horizontal: 8.0),
                            //         child: Center(
                            //           child: Text(
                            //             property.properyType!
                            //                 .translate(context),
                            //           )
                            //               .color(
                            //             context.color.textColorDark,
                            //           )
                            //               .bold()
                            //               .size(context.font.smaller),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      // if ( statusButton1!= null)
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //         vertical: 3.0, horizontal: 3.0),
                      //     child: Container(
                      //       decoration: BoxDecoration(
                      //           color: statusButton1!.color,
                      //           borderRadius: BorderRadius.circular(4)),
                      //
                      //       child: Center(
                      //           child: Text(statusButton1!.lable)
                      //               .size(context.font.small)
                      //               .bold()
                      //               .color(statusButton1?.textColor ??
                      //               Colors.black)),
                      //     ),
                      //   )
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left:10,right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(height: 6,),
                          Text(
                            property.title!.firstUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 4,),
                          if (property.city != "")
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                  SizedBox(width: 5,),
                                  Expanded(
                                      child: Text(
                                        property.city?.trim() ?? "",  maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Color(0xffa2a2a2),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w400
                                        ),)
                                  )
                                ],
                              ),
                            ),
                          // UiUtils.imageType(
                          //     property.category!.image ?? "",
                          //     width: 18,
                          //     height: 18,
                          //     color: Constant.adaptThemeColorSvg
                          //         ? context.color.tertiaryColor
                          //         : null),
                          // const SizedBox(
                          //   width: 5,
                          // ),
                          // Text(property.category!.category!)
                          //     .setMaxLines(lines: 1)
                          //     .size(
                          //       context.font.small
                          //           .rf(context),
                          //     )
                          //     .bold(
                          //       weight: FontWeight.w400,
                          //     )
                          //     .color(
                          //       context.color.textLightColor,
                          //     ),

                          if (property.properyType
                              .toString()
                              .toLowerCase() ==
                              "rent") ...[
                            Text(
                              rentPrice,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Color(0xff333333),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ] else ...[
                            Text(
                              formatAmount(int.parse(property.price!),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Color(0xff333333),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                          ],

                          SizedBox(height: 4,),
                          Text("Ready To Move",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xffa2a2a2),
                                fontSize: 9,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (useRow == false || useRow == null) ...addBottom ?? [],

                  if (useRow == true) ...{Row(children: addBottom ?? [])}

                  // ...addBottom ?? []
                ],
              ),
              if (showDeleteButton ?? false)
                PositionedDirectional(
                  top: 32 * 2,
                  end: 12,
                  child: InkWell(
                    onTap: () {
                      onDeleteTap?.call();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.color.secondaryColor,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromARGB(33, 0, 0, 0),
                              offset: Offset(0, 2),
                              blurRadius: 15,
                              spreadRadius: 0)
                        ],
                      ),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: SvgPicture.asset(
                            AppIcons.bin,
                            color: context.color.tertiaryColor,
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InterestedUsersDetails(propertyId:property.id ,),
                        ),
                      );
                    },
                    child: Container(
                      height: 28,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Color(0xff117af9))
                      ),child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/assets/Images/eye-icon.png",height: 15,),
                        SizedBox(width: 5,),
                        Text(property.totalInterestedUsers?.toString()??"0",style: TextStyle(fontSize: 12,color:  Color(0xff117af9)),)
                      ],
                    ),
                    ),
                  )),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 28,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: property.status==0?Color(0xfffff1f1):Color(0xffd9efcf),
                        border: Border.all(color:  property.status==0?Colors.red:Colors.green)
                    ),child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text( property.status == 0 ? "InActive" : "Active",style: TextStyle(fontSize: 12,color:property.status == 0 ?Colors.red: Colors.green),)
                    ],
                  ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class StatusButton1 {
  final String lable;
  final Color color;
  final Color? textColor;
  StatusButton1({
    required this.lable,
    required this.color,
    this.textColor,
  });
}
