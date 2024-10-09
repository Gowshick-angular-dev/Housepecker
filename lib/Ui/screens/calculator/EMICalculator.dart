import "package:flutter/material.dart";
import "package:Housepecker/utils/responsiveSize.dart";
import "dart:math";

import "../../../utils/ui_utils.dart";
import "../widgets/custom_text_form_field.dart";


class EmiCalculator extends StatefulWidget {
  @override
  EmiCalculatorState createState() => EmiCalculatorState();
}

class EmiCalculatorState extends State<EmiCalculator> {

  List _tenureTypes = [ 'Months', 'Years' ];
  String _tenureType = "Years";
  String _emiResult = "";
  double totalInterest = 0.0;
  double totalPayable = 0.0;

  final TextEditingController _principalAmount = TextEditingController();
  final TextEditingController _interestRate = TextEditingController();
  final TextEditingController _tenure = TextEditingController();

  bool _switchValue = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: UiUtils.buildAppBar(context,
            title: UiUtils.getTranslatedLabel(
              context,
              "EMI Calculator",
            ),
            showBackButton: true),

        body: Center(
            child: Container(
              padding: EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: buildTextField(
                              context,
                              keyboard: TextInputType.number,
                              title: "Principal Amount",
                              controller: _principalAmount,
                              validator: null,
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Container(
                          width: MediaQuery.sizeOf(context).width / 3.5,
                          child: buildTextField(
                            context,
                            keyboard: TextInputType.number,
                            title: "Interest Rate",
                            controller: _interestRate,
                            validator: null,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: buildTextField(
                              context,
                              keyboard: TextInputType.number,
                              title: "Tenure",
                              controller: _tenure,
                              validator: null,
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Container(
                          width: MediaQuery.sizeOf(context).width / 3.5,
                          child: Column(
                            children: [
                              Text(
                                _tenureType,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal
                                )
                              ),
                              Switch.adaptive(
                                value: _switchValue,
                                onChanged: (bool value) {
                                  print(value);
                                  if( value ) {
                                    _tenureType = _tenureTypes[1];
                                  } else {
                                    _tenureType = _tenureTypes[0];
                                  }
                                  setState(() {
                                    _switchValue = value;
                                  });
                                }
                              )
                            ]
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 25,),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: UiUtils.buildButton(
                        fontSize: 13,
                        context,
                        onPressed: calculateEMI,
                        height: 48.rh(context),
                        buttonTitle: UiUtils.getTranslatedLabel(
                          context, "Calculate",),
                      ),
                    ),
                    emiResultsWidget(_emiResult),
                  ],
                )
            )
        )
    );
  }

  void calculateEMI() {
    double monthlyInterestRate = (int.parse(_interestRate.text) / 100) / 12;
    int numberOfInstallments = (_tenureType == "Years" ? (int.parse(_tenure.text) * 12) : int.parse(_tenure.text));

    _emiResult = (int.parse(_principalAmount.text) * monthlyInterestRate *
        pow(1 + monthlyInterestRate, numberOfInstallments) /
        (pow(1 + monthlyInterestRate, numberOfInstallments) - 1)).toStringAsFixed(0);
    totalInterest = ((int.parse(_principalAmount.text) * monthlyInterestRate * pow(1 + monthlyInterestRate, numberOfInstallments) /
        (pow(1 + monthlyInterestRate, numberOfInstallments) - 1)) * numberOfInstallments) - (int.parse(_principalAmount.text));
    totalPayable = numberOfInstallments * (int.parse(_principalAmount.text) * monthlyInterestRate *
        pow(1 + monthlyInterestRate, numberOfInstallments) / (pow(1 + monthlyInterestRate, numberOfInstallments) - 1));
    setState(() {});
  }

  Widget buildTextField(BuildContext context,
      {required String title,
        required TextEditingController controller,
        CustomTextFieldValidator? validator,
        TextInputType? keyboard,
        bool? readOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        Text(UiUtils.getTranslatedLabel(context, title)),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomTextFormField(
          keyboard: keyboard,
          controller: controller,
          isReadOnly: readOnly,
          validator: validator,
          // formaters: [FilteringTextInputFormatter.deny(RegExp(","))],
          fillColor: Color(0xfff5f5f5),
        ),
      ],
    );
  }


  Widget emiResultsWidget(emiResult) {
    bool canShow = false;
    String _emiResult = emiResult;

    if( _emiResult.length > 0 ) {
      canShow = true;
    }
    return
      Container(
          margin: EdgeInsets.only(top: 40.0),
          child: canShow ? Column(
              children: [
                Text("Your Monthly EMI is",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold
                    )
                ),
                Container(
                    child: Text('₹${_emiResult}',
                        style: TextStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.bold
                        ))
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Intrest'),
                    Text('₹${totalInterest.toStringAsFixed(0)}'),
                  ],
                ),
                SizedBox(
                  height: 5.rh(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Payable'),
                    Text('₹${totalPayable.toStringAsFixed(0)}'),
                  ],
                ),
              ]
          ) : Container()
      );
  }
}