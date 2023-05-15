import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hitachi/blocs/treatment/treatment_bloc.dart';
import 'package:hitachi/helper/background/bg_white.dart';
import 'package:hitachi/helper/button/Button.dart';
import 'package:hitachi/helper/colors/colors.dart';
import 'package:hitachi/helper/input/rowBoxInputField.dart';
import 'package:hitachi/helper/text/label.dart';
import 'package:hitachi/models/treatmentStartModel/treatmentStartOutputModel.dart';
import 'package:hitachi/services/databaseHelper.dart';

class TreatmentFinishScanScreen extends StatefulWidget {
  const TreatmentFinishScanScreen({super.key});

  @override
  State<TreatmentFinishScanScreen> createState() =>
      _TreatmentFinishScanScreenState();
}

class _TreatmentFinishScanScreenState extends State<TreatmentFinishScanScreen> {
  final TextEditingController _machineNoController = TextEditingController();
  final TextEditingController _operatorNameController = TextEditingController();
  final TextEditingController _batch1Controller = TextEditingController();
  final TextEditingController _batch2Controller = TextEditingController();
  final TextEditingController _batch3Controller = TextEditingController();
  final TextEditingController _batch4Controller = TextEditingController();
  final TextEditingController _batch5Controller = TextEditingController();
  final TextEditingController _batch6Controller = TextEditingController();
  final TextEditingController _batch7Controller = TextEditingController();

  Color? bgChange;

  DatabaseHelper databaseHelper = DatabaseHelper();
  void _btnSend() async {
    if (_machineNoController.text.isNotEmpty &&
        _operatorNameController.text.isNotEmpty &&
        _batch1Controller.text.isNotEmpty) {
      _callApi();
      // _saveDataToSqlite();
    } else {
      EasyLoading.showError("Please Input Info");
    }
  }

  void _callApi() {
    BlocProvider.of<TreatmentBloc>(context).add(
      TreatmentFinishSendEvent(TreatMentStartOutputModel(
          MACHINE_NO: _machineNoController.text.trim(),
          OPERATOR_NAME: int.tryParse(_operatorNameController.text.trim()),
          BATCH_NO_1: _batch1Controller.text.trim(),
          BATCH_NO_2: _batch2Controller.text.trim(),
          BATCH_NO_3: _batch3Controller.text.trim(),
          BATCH_NO_4: _batch4Controller.text.trim(),
          BATCH_NO_5: _batch5Controller.text.trim(),
          BATCH_NO_6: _batch6Controller.text.trim(),
          BATCH_NO_7: _batch7Controller.text.trim(),
          FINISH_DATE: DateTime.now().toString())),
    );
  }

  void _saveDataToSqlite() async {
    try {
      await databaseHelper.insertSqlite('TREATMENT_SHEET', {
        'MachineNo': _machineNoController.text.trim(),
        'OperatorName': _operatorNameController.text.trim(),
        'Batch1': _batch1Controller.text.trim(),
        'Batch2':
            _batch2Controller.text == null ? "" : _batch2Controller.text.trim(),
        'Batch3':
            _batch3Controller.text == null ? "" : _batch3Controller.text.trim(),
        'Batch4':
            _batch4Controller.text == null ? "" : _batch4Controller.text.trim(),
        'Batch5':
            _batch5Controller.text == null ? "" : _batch5Controller.text.trim(),
        'Batch6':
            _batch6Controller.text == null ? "" : _batch6Controller.text.trim(),
        'Batch7':
            _batch7Controller.text == null ? "" : _batch7Controller.text.trim(),
        'StartDate': '',
        'FinDate': DateTime.now().toString(),
        'StartEnd': '',
        'CheckComplete': 'End',
      });
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [  BlocListener<TreatmentBloc, TreatmentState>(
        listener: (context, state) {
          if (state is TreatmentStartSendLoadingState) {
            EasyLoading.show();
          } else if (state is TreatmentStartSendLoadedState) {
            if (state.item.RESULT == true) {
              EasyLoading.showSuccess("SendComplete");

            }else{
              EasyLoading.showError("Check Data");
            }
          } else {
            EasyLoading.dismiss();

            EasyLoading.showError("Please Check Connection Internet");
          }
        },
      )],
      child: BgWhite(
          isHideAppBar: true,
          textTitle: "Treatment Finish",
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RowBoxInputField(
                    labelText: "Machine No. : ",
                    height: 35,
                    maxLength: 3,
                    controller: _machineNoController,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Operator Name : ",
                    height: 35,
                    maxLength: 12,
                    controller: _operatorNameController,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^(?!.*\d{12})[a-zA-Z0-9]+$'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Batch 1 : ",
                    height: 35,
                    controller: _batch1Controller,
                    type: TextInputType.number,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    onChanged: (value) {
                      if (_machineNoController.text.isNotEmpty &&
                          _operatorNameController.text.isNotEmpty &&
                          _batch1Controller.text.isNotEmpty) {
                        setState(() {
                          bgChange = COLOR_RED;
                        });
                      } else {
                        setState(() {
                          bgChange = Colors.grey;
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Batch 2 : ",
                    height: 35,
                    controller: _batch2Controller,
                    type: TextInputType.number,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Batch 3 : ",
                    height: 35,
                    controller: _batch3Controller,
                    type: TextInputType.number,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Batch 4 : ",
                    height: 35,
                    controller: _batch4Controller,
                    type: TextInputType.number,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Batch 5 : ",
                    height: 35,
                    controller: _batch5Controller,
                    type: TextInputType.number,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RowBoxInputField(
                          labelText: "Batch 6 : ",
                          height: 35,
                          controller: _batch6Controller,
                          type: TextInputType.number,
                          textInputFormatter: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: RowBoxInputField(
                          labelText: "Batch 7 : ",
                          height: 35,
                          controller: _batch7Controller,
                          type: TextInputType.number,
                          textInputFormatter: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Button(
                    height: 40,
                    bgColor: bgChange ?? Colors.grey,
                    text: Label(
                      "Send",
                      color: COLOR_WHITE,
                    ),
                    onPress: (){
                      print('send');
                      _btnSend();
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
