import 'package:Housepecker/Ui/screens/projects/reportProjectScreen.dart';
import 'package:Housepecker/Ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:Housepecker/data/cubits/Report/property_report_cubit.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:Housepecker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/guestChecker.dart';
import '../../../data/cubits/Report/fetch_property_report_reason_list.dart';
import '../../../data/model/ReportProperty/reason_model.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';

class ReportProjectButton extends StatefulWidget {
  final int propertyId;
  final Function() onSuccess;
  const ReportProjectButton(
      {Key? key, required this.propertyId, required this.onSuccess})
      : super(key: key);

  @override
  State<ReportProjectButton> createState() => _ReportProjectButtonState();
}

class _ReportProjectButtonState extends State<ReportProjectButton> {
  bool shouldReport = true;
  List<ReportReason>? reasons = [];
  int? selectedId;
  TextEditingController _reportmessageController = TextEditingController();

  void _onTapYes(int propertyId) {
    _bottomSheet(propertyId);
  }

  @override
  void initState() {
    reasons =
        context.read<FetchPropertyReportReasonsListCubit>().getList() ?? [];

    if (reasons?.isEmpty ?? true) {
      selectedId = -10;
    } else {
      selectedId = reasons!.first.id;
    }

    super.initState();
  }

  _onTapNo() {
    shouldReport = false;
    setState(() {});
  }

  void _bottomSheet(int propertyId) {
    // PropertyReportCubit cubit = BlocProvider.of<PropertyReportCubit>(context);
    UiUtils.showBlurredDialoge(context,
        dialoge: EmptyDialogBox(
            child: AlertDialog(
              backgroundColor: context.color.secondaryColor,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: StatefulBuilder(
                  builder: (context, setState) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Report project").size(context.font.larger),
                        SizedBox(
                          height: 15,
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: reasons?.length ?? 0,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                          itemBuilder: (context, index) {
                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                if (selectedId == reasons![index].id) {
                                  // selectedId = -10;
                                } else {
                                  selectedId = reasons![index].id;
                                }
                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.color.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: selectedId == reasons?[index].id
                                          ? context.color.tertiaryColor
                                          : context.color.borderColor,
                                      width: 1.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Text(reasons?[index].reason.firstUpperCase() ?? "")
                                      .color(selectedId == reasons?[index].id
                                      ? context.color.tertiaryColor
                                      : context.color.textColorDark),
                                ),
                              ),
                            );

                            return RadioListTile(
                              value: reasons![index].id,
                              groupValue: selectedId,
                              fillColor:
                              MaterialStatePropertyAll(context.color.tertiaryColor),
                              onChanged: (dynamic value) {
                                if (selectedId == value) {
                                  selectedId = -10;
                                } else {
                                  selectedId = value;
                                }
                                setState(() {});
                              },
                              title: Text(reasons![index].reason.firstUpperCase()),
                            );
                          },
                        ),
                        if (selectedId != null && selectedId!.isNegative)
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 0,
                                left: 0,
                                right: 0),
                            child: TextField(
                              maxLines: null,
                              controller: _reportmessageController,
                              cursorColor: context.color.tertiaryColor,
                              decoration: InputDecoration(
                                  hintText: "writeReasonHere".translate(context),
                                  focusColor: context.color.tertiaryColor,
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: context.color.tertiaryColor))),
                            ),
                          ),
                        SizedBox(
                          height: 14,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MaterialButton(
                                height: 40,
                                minWidth: 104.rw(context),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color: context.color.borderColor,
                                      width: 1.5,
                                    )),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("cancelLbl".translate(context))
                                    .color(context.color.tertiaryColor),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              MaterialButton(
                                height: 40,
                                minWidth: 104.rw(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    30,
                                  ),
                                ),
                                color: context.color.tertiaryColor,
                                onPressed: () async {
                                    var response = await Api.post(url: Api.getProject, parameter: {
                                      "project_id": widget.propertyId,
                                      "other_message": _reportmessageController.text,
                                      "reason_id": selectedId
                                    });
                                    // if(!response['error']) {
                                    //   setState(() {
                                    //     agentProjectsList = response['data'];
                                    //   });
                                    // }
                                },
                                child: Text("report".translate(context))
                                    .color(context.color.buttonColor),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                ),
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
