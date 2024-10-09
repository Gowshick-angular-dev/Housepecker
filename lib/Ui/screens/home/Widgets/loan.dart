import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Housepecker/Ui/Theme/theme.dart';

import '../../../../utils/ui_utils.dart';

class Loan extends StatefulWidget {
  const Loan({super.key});

  @override
  State<Loan> createState() => _LoanState();
}

class _LoanState extends State<Loan> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
          Container(
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
                        context, "Search by Project.."),
                    hintStyle: TextStyle(
                        color: Color(0xff9c9c9c),
                        fontSize: 13,
                        fontWeight: FontWeight.w500
                    ),
                    suffixIcon: Padding(
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
                        )),
                    prefixIconConstraints:
                    const BoxConstraints(minHeight: 5, minWidth: 5),
                  ),
                  enableSuggestions: true,
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                  },
                  onTap: () {
                    //change prefix icon color to primary
                  })
          ),
        ],
      ),
    );
  }
}
