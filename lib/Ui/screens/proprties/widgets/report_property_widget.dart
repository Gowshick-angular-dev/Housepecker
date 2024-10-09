import 'package:Housepecker/Ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:Housepecker/data/cubits/Report/property_report_cubit.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../utils/AppIcon.dart';
import '../../../../utils/guestChecker.dart';
import '../../Report/report_property_screen.dart';

class ReportPropertyButton extends StatefulWidget {
  final int propertyId;
  final Function() onSuccess;
  const ReportPropertyButton(
      {Key? key, required this.propertyId, required this.onSuccess})
      : super(key: key);

  @override
  State<ReportPropertyButton> createState() => _ReportPropertyButtonState();
}

class _ReportPropertyButtonState extends State<ReportPropertyButton> {
  bool shouldReport = true;
  void _onTapYes(int propertyId) {
    _bottomSheet(propertyId);
  }

  _onTapNo() {
    shouldReport = false;
    setState(() {});
  }

  void _bottomSheet(int propertyId) {
    PropertyReportCubit cubit = BlocProvider.of<PropertyReportCubit>(context);
    UiUtils.showBlurredDialoge(context,
        dialoge: EmptyDialogBox(
            child: AlertDialog(
          backgroundColor: context.color.secondaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: BlocProvider.value(
            value: cubit,
            child: ReportPropertyScreen(propertyId: propertyId),
          ),
        ))).then((value) {
      widget.onSuccess.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (shouldReport == false) {
      return SizedBox.shrink();
    }
    return Container(
      height: 135,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isDark
                  ? Color(0xffe5f0fe)
                  : Color(0xffe5f0fe),
              width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Do You Find Any Problem With This Property?".translate(context))
                      .setMaxLines(lines: 2)
                      .bold(weight: FontWeight.w500)
                      .size(13),
                  const Spacer(),
                  Row(
                    children: [
                      MaterialButton(
                          onPressed: () {
                            GuestChecker.check(onNotGuest: () {
                              _onTapYes.call(widget.propertyId);
                            });
                          },
                          elevation: 0,
                          textColor: context.color.tertiaryColor,
                          color: Color(0xfff3f9ff),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isDark
                                      ? Color(0xff8ec0fc)
                                      : Color(0xff8ec0fc)),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text("yes".translate(context),style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500
                          ))),
                      const SizedBox(
                        width: 10,
                      ),
                      MaterialButton(
                          onPressed: _onTapNo,
                          elevation: 0,
                          textColor: context.color.tertiaryColor,
                          color: Color(0xfff3f9ff),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isDark
                                      ? Color(0xfff3f9ff)
                                      : Color(0xfff3f9ff)),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text("Not Really".translate(context),style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500
                          ),))
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10,),
            Image.asset("assets/NewPropertydetailscreen/report.png",width: 70,height: 60,fit: BoxFit.cover,)
            // SvgPicture.asset(
            //   Theme.of(context).brightness == Brightness.dark
            //       ? AppIcons.reportDark
            //       : AppIcons.report,
            // )
          ],
        ),
      ),
    );
  }
}
