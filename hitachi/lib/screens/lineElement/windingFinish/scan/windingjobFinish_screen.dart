// ignore_for_file: unrelated_type_equality_checks

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hitachi/blocs/lineElement/line_element_bloc.dart';
import 'package:hitachi/helper/background/bg_white.dart';
import 'package:hitachi/helper/button/Button.dart';
import 'package:hitachi/helper/colors/colors.dart';
import 'package:hitachi/helper/input/boxInputField.dart';
import 'package:hitachi/helper/text/label.dart';
import 'package:hitachi/models/SendWdFinish/sendWdsFinish_Input_Model.dart';
import 'package:hitachi/models/SendWdFinish/sendWdsFinish_output_Model.dart';
import 'package:hitachi/models/reportRouteSheet/reportRouteSheetModel.dart';
import 'package:hitachi/route/router_list.dart';
import 'package:hitachi/services/databaseHelper.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class WindingJobFinishScreen extends StatefulWidget {
  const WindingJobFinishScreen({super.key});

  @override
  State<WindingJobFinishScreen> createState() => _WindingJobFinishScreenState();
}

class _WindingJobFinishScreenState extends State<WindingJobFinishScreen> {
  final TextEditingController operatorNameController = TextEditingController();
  final TextEditingController batchNoController = TextEditingController();
  final TextEditingController elementQtyController = TextEditingController();

//FOCUS
  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();

  ///
  Color bgColor = Colors.grey;
  DatabaseHelper databaseHelper = DatabaseHelper();
  SendWdsFinishInputModel? items;
  SendWdsFinishOutputModel? _outputModel;

  ReportRouteSheetModel? itemsReport;
  String? target = "invaild";
  void _btnSend_Click() async {
    if (batchNoController.text.trim().isNotEmpty &&
        operatorNameController.text.trim().isNotEmpty &&
        elementQtyController.text.trim().isNotEmpty) {
      _callApi();
    } else {
      EasyLoading.showError("Data incomplete", duration: Duration(seconds: 2));
    }
  }

  void _deleteSave() async {
    await databaseHelper.deleteSave(
        tableName: 'WINDING_SHEET',
        where: 'BatchNo',
        keyWhere: batchNoController.text.trim());
  }

  Future<void> _callApi() async {
    BlocProvider.of<LineElementBloc>(context).add(
      PostSendWindingFinishEvent(
        SendWdsFinishOutputModel(
            OPERATOR_NAME: int.tryParse(operatorNameController.text.trim()),
            BATCH_NO: batchNoController.text.trim(),
            ELEMNT_QTY: int.tryParse(elementQtyController.text.trim()),
            FINISH_DATE: DateFormat('yyyy-MM-dd HH:mm:ss')
                .format(DateTime.now())
                .toString()),
      ),
    );
  }

  Future<void> _insertSqlite() async {
    var sql = await databaseHelper.queryDataSelect(
        select1: 'BatchNo',
        select2: 'MachineNo',
        formTable: 'WINDING_SHEET',
        where: 'BatchNo',
        stringValue: batchNoController.text.trim(), // If error check here
        keyAnd: 'MachineNo',
        value: 'WD',
        keyAnd2: 'checkComplete',
        value2: 'E');

    if (sql.length <= 0) {
      var sqlInsertWINDING_SHEET =
          await databaseHelper.insertSqlite('WINDING_SHEET', {
        'MachineNo': 'WD',
        'BatchNo': batchNoController.text.trim(),
        'Element': batchNoController.text.trim(),
        'BatchEndDate':
            DateFormat('yyyy MM dd HH:mm:ss').format(DateTime.now()),
        'start_end': DateFormat('yyyy MM dd HH:mm:ss').format(DateTime.now()),
        'checkComplete': 'E',
      });
    }
  }

  Future<bool?> _queryPackno(
      {int? batchNo, int? element, String? batchEnddate}) async {
    bool ischeck = false;
    Database db = await databaseHelper.database;
    try {} catch (e) {
      print("Error Catch ${e}");
      EasyLoading.show(status: "CAN not SAVE.", dismissOnTap: true);
      return false;
    }
  }

  void checkformtxtBatchNo() {
    queryTarget();
  }

  void queryTarget({String? checkRow}) async {
    print("object");
    try {
      var sql = await databaseHelper.queryWeight(
          table: 'WINDING_WEIGHT_SHEET',
          selected: 'Target',
          stringValue: batchNoController.text.trim());

      if (sql.length > 0) {
        setState(() {
          target = sql[0]['Target'].toString();
        });
        print(target);
      } else {
        target = "0";
        checkRow = "N/A";
      }
    } on Exception {
      target = null;
      throw Exception();
    }
  }

  @override
  void initState() {
    f1.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BgWhite(
      isHideAppBar: true,
      textTitle: "Winding job finish",
      body: MultiBlocListener(
        listeners: [
          BlocListener<LineElementBloc, LineElementState>(
            listener: (context, state) {
              if (state is PostSendWindingFinishLoadingState) {
                EasyLoading.show(status: "Loading...");
              } else if (state is PostSendWindingFinishLoadedState) {
                EasyLoading.dismiss();
                setState(() {
                  items = state.item;
                });
                if (items!.RESULT == true) {
                  _deleteSave();
                  operatorNameController.clear();
                  batchNoController.clear();
                  elementQtyController.clear();
                  f1.requestFocus();
                  EasyLoading.showSuccess("${items!.MESSAGE}");
                } else if (items!.RESULT == false) {
                  if (batchNoController.text.trim().isNotEmpty &&
                      operatorNameController.text.trim().isNotEmpty &&
                      elementQtyController.text.trim().isNotEmpty) {
                    _errorDialog(
                        text: Label("${items!.MESSAGE}"),
                        onpressOk: () {
                          _insertSqlite();
                          Navigator.pop(context);
                        });
                  } else {
                    EasyLoading.showError("Please Input Info");
                  }
                } else {
                  if (batchNoController.text.trim().isNotEmpty &&
                      operatorNameController.text.trim().isNotEmpty &&
                      elementQtyController.text.trim().isNotEmpty) {
                    _insertSqlite();
                    EasyLoading.showError(
                        "Please Check Connection Internet & Save Complete");
                  }
                }
              } else if (state is PostSendWindingFinishErrorState) {
                EasyLoading.showError("Can not send",
                    duration: Duration(seconds: 3));
              }
              if (state is CheckWindingFinishLoadingState) {
                EasyLoading.show(status: "Loading...");
              } else if (state is CheckWindingFinishLoadedState) {
                EasyLoading.dismiss();
                if (state.item.RESULT == true) {
                  f3.requestFocus();
                } else {
                  _errorDialog(
                      text: Label("${state.item.MESSAGE}"),
                      onpressOk: () {
                        Navigator.pop(context);
                        f3.requestFocus();
                      });
                }
              } else if (state is CheckWindingFinishErrorState) {
                EasyLoading.showError(
                    "Please Check Connection & Save Complete");
              }
            },
          )
        ],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BoxInputField(
                  focusNode: f1,
                  onEditingComplete: () => f2.requestFocus(),
                  labelText: "Operator Name :",
                  controller: operatorNameController,
                  type: TextInputType.number,
                  textInputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
                BoxInputField(
                  focusNode: f2,
                  onEditingComplete: () {
                    if (batchNoController.text.length == 12) {
                      BlocProvider.of<LineElementBloc>(context).add(
                        CheckWindingFinishEvent(batchNoController.text.trim()),
                      );
                    }
                  },
                  labelText: "Batch No :",
                  maxLength: 12,
                  controller: batchNoController,
                  onChanged: (value) {
                    setState(() {
                      checkformtxtBatchNo();
                      batchNoController.text.trim();
                    });
                  },
                ),
                BoxInputField(
                  focusNode: f3,
                  onEditingComplete: () => _btnSend_Click(),
                  labelText: "Element QTY :",
                  controller: elementQtyController,
                  type: TextInputType.number,
                  textInputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  onChanged: (p0) {
                    if (p0.length > 0) {
                      setState(() {
                        bgColor = COLOR_RED;
                      });
                    } else {
                      setState(() {
                        bgColor = COLOR_BLUE_DARK;
                      });
                    }
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Label(
                          "Batch No. : ${batchNoController.text.trim()}",
                          color: COLOR_RED,
                        ),
                        Label(
                          "Target : ${target}",
                          color: COLOR_RED,
                        )
                      ],
                    ),
                  ],
                ),
                Container(
                  child: Button(
                    bgColor: bgColor,
                    text: Label(
                      "Send",
                      color: COLOR_WHITE,
                    ),
                    onPress: () => {_btnSend_Click()},
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _errorDialog(
      {Label? text, Function? onpressOk, Function? onpressCancel}) async {
    // EasyLoading.showError("Error[03]", duration: Duration(seconds: 5));//if password
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        // title: const Text('AlertDialog Title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: text,
            ),
          ],
        ),

        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => onpressOk?.call(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  // void _testSendSqlite() async {
  //   try {
  //     await databaseHelper.insertSqlite('WINDING_SHEET', {
  //       'BatchNo': batchNoController.text.trim(),
  //       'Element': elementQtyController.text.trim(),
  //       'BatchEndDate': batchNoController.text.trim(),
  //       'start_end': 'E',
  //       'checkComplete': '0',
  //       'value': 'WD'
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
