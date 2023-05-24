// ignore_for_file: unrelated_type_equality_checks

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hitachi/blocs/lineElement/line_element_bloc.dart';
import 'package:hitachi/helper/background/bg_white.dart';
import 'package:hitachi/helper/button/Button.dart';
import 'package:hitachi/helper/colors/colors.dart';
import 'package:hitachi/helper/input/boxInputField.dart';
import 'package:hitachi/helper/input/rowBoxInputField.dart';
import 'package:hitachi/helper/text/label.dart';
import 'package:hitachi/models-Sqlite/processModel.dart';
import 'package:hitachi/models/processStart/processInputModel.dart';
import 'package:hitachi/models/processStart/processOutputModel.dart';
import 'package:hitachi/services/databaseHelper.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProcessStartScanScreen extends StatefulWidget {
  const ProcessStartScanScreen({super.key});

  @override
  State<ProcessStartScanScreen> createState() => _ProcessStartScanScreenState();
}

class _ProcessStartScanScreenState extends State<ProcessStartScanScreen> {
  final TextEditingController MachineController = TextEditingController();
  final TextEditingController operatorNameController = TextEditingController();
  final TextEditingController operatorName1Controller = TextEditingController();
  final TextEditingController operatorName2Controller = TextEditingController();
  final TextEditingController operatorName3Controller = TextEditingController();
  final TextEditingController batchNoController = TextEditingController();
  DatabaseHelper databaseHelper = DatabaseHelper();

  ProcessInputModel? items;
  ProcessStartDataSource? matTracDs;
  List<ProcessModel>? processList;
  bool _enabledMachineNo = true;
  bool _enabledOperator = false;
  bool _enabledCheckMachine = false;
  bool _checkSendSqlite = false;
  String Focustxt = "";
  String valuetxtinput = "";
  Color? bgChange;
  DateTime startDate = DateTime.now();
  String StartEndValue = 'S';

  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();
  final f4 = FocusNode();
  final f5 = FocusNode();
  final f6 = FocusNode();

  Future<bool> _getProcessStart() async {
    try {
      var sql_processSheet = await databaseHelper.queryDataSelectProcess(
        select1: 'Machine'.trim(),
        select2: 'OperatorName'.trim(),
        select3: 'OperatorName1'.trim(),
        select4: 'OperatorName2'.trim(),
        select5: 'OperatorName3'.trim(),
        select6: 'BatchNo'.trim(),
        formTable: 'PROCESS_SHEET'.trim(),
        where: 'Machine'.trim(),
        stringValue: MachineController.text.trim(),
      );
      print(sql_processSheet.length);

      // if (sql_processSheet[0]['Machine'] != MachineController.text.trim()) {
      print(MachineController.text.trim());
      print(sql_processSheet.length);
      if (sql_processSheet.isEmpty) {
        print("if");
        // setState(() {
        _checkSendSqlite = true;
        print("_checkSendSqlite = true;");
        _saveSendSqlite();
        // });
      } else {
        // setState(() {
        _checkSendSqlite = false;
        print("_checkSendSqlite = false;");
        _updateSendSqlite();
        // });
        print("else");
      }
      return true;
    } catch (e) {
      print("Catch : ${e}");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    f1.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LineElementBloc, LineElementState>(
          listener: (context, state) {
            if (state is ProcessStartLoadingState) {
              EasyLoading.show();
              print("loading");
            }
            if (state is ProcessStartLoadedState) {
              print("Loaded");
              EasyLoading.show(status: "Loaded");
              if (state.item.RESULT == true) {
                EasyLoading.showSuccess("SendComplete");
                _clearAllData();
                bgChange = Colors.grey;
                f1.requestFocus();
              } else if (state.item.RESULT == false) {
                // EasyLoading.showError("Can not send & save Data");
                items = state.item;
                _errorDialog(
                    text: Label("${state.item.MESSAGE}"),
                    onpressOk: () {
                      Navigator.pop(context);
                      _getProcessStart();
                    });
              } else {
                // EasyLoading.showError("Can not Call API");
                _errorDialog(
                    text: Label("${state.item.MESSAGE}"),
                    onpressOk: () {
                      Navigator.pop(context);
                      _getProcessStart();
                    });
              }
            }
            if (state is ProcessStartErrorState) {
              print("ERROR");
              // EasyLoading.dismiss();
              // _errorDialog();
              _getProcessStart();
              _enabledMachineNo = true;
              EasyLoading.showError("Please Check Connection Internet");
            }
          },
        )
      ],
      child: BgWhite(
          isHideAppBar: true,
          textTitle: "Process Start",
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  RowBoxInputField(
                    labelText: "Machine No :",
                    maxLength: 3,
                    controller: MachineController,
                    height: 35,
                    focusNode: f1,
                    enabled: _enabledMachineNo,
                    onEditingComplete: () {
                      if (MachineController.text.length > 2) {
                        // FocusScope.of(context).autofocus(f2);
                        // operatorNameController
                        setState(() {
                          print(MachineController.text);
                          // _enabledCheckMachine = true;
                          _enabledMachineNo = false;
                          valuetxtinput = MachineController.text.trim();
                        });
                        f2.requestFocus();
                      } else {
                        setState(() {
                          _enabledCheckMachine = false;
                          valuetxtinput = "Machine No. INVALID";
                        });
                      }
                    },
                    // onEditingComplete: () => f2.requestFocus(),
                    onChanged: (value) {
                      if (value == 'SD' && value.length == 2 ||
                          value == 'sd' && value.length == 2) {
                        setState(() {
                          _enabledOperator = true;
                          // _enabled = !_enabled;
                        });
                      } else if (value.length == 1) {
                        setState(() {
                          _enabledOperator = false;
                        });
                      }
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Operator Name :",
                    height: 35,
                    controller: operatorNameController,
                    maxLength: 12,
                    focusNode: f2,
                    // enabled: _enabledCheckMachine,
                    onEditingComplete: () {
                      if (operatorNameController.text.isNotEmpty) {
                        setState(() {
                          if (_enabledOperator == true) {
                            f3.requestFocus();
                          } else {
                            f6.requestFocus();
                          }
                        });
                      } else {
                        setState(() {
                          valuetxtinput = "User INVALID";
                        });
                      }
                    },
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    onChanged: (value) {
                      if (MachineController.text.isNotEmpty &&
                          batchNoController.text.isNotEmpty) {
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
                  SizedBox(
                    height: 5,
                  ),
                  DottedLine(),
                  SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Operator Name :",
                    height: 35,
                    maxLength: 12,
                    controller: operatorName1Controller,
                    focusNode: f3,
                    enabled: _enabledOperator,
                    onEditingComplete: () => f4.requestFocus(),
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Operator Name :",
                    height: 35,
                    maxLength: 12,
                    controller: operatorName2Controller,
                    focusNode: f4,
                    enabled: _enabledOperator,
                    onEditingComplete: () => f5.requestFocus(),
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Operator Name :",
                    height: 35,
                    maxLength: 12,
                    controller: operatorName3Controller,
                    focusNode: f5,
                    enabled: _enabledOperator,
                    onEditingComplete: () => f6.requestFocus(),
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  DottedLine(),
                  SizedBox(
                    height: 5,
                  ),
                  RowBoxInputField(
                    labelText: "Batch No :",
                    maxLength: 12,
                    height: 35,
                    onEditingComplete: () {
                      if (batchNoController.text.length == 12) {
                        _btnSend();
                      }
                    },
                    controller: batchNoController,
                    type: TextInputType.number,
                    focusNode: f6,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    onChanged: (value) {
                      if (MachineController.text.isNotEmpty &&
                          operatorNameController.text.isNotEmpty) {
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
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Visibility(
                        visible: true,
                        child: Container(
                            child: Label(
                          "Machine No: ${valuetxtinput}",
                          color: COLOR_RED,
                        )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Button(
                      height: 40,
                      bgColor: bgChange ?? Colors.grey,
                      text: Label(
                        "Send",
                        color: COLOR_WHITE,
                      ),
                      onPress: () => _btnSend(),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void _saveSendSqlite() async {
    try {
      if (operatorNameController.text.isNotEmpty) {
        await databaseHelper.insertSqlite('PROCESS_SHEET', {
          'Machine': MachineController.text.trim(),
          'OperatorName': operatorNameController.text.trim(),
          'OperatorName1': operatorName1Controller.text == null
              ? ""
              : operatorName1Controller.text.trim(),
          'OperatorName2': operatorName2Controller.text == null
              ? ""
              : operatorName2Controller.text.trim(),
          'OperatorName3': operatorName3Controller.text == null
              ? ""
              : operatorName3Controller.text.trim(),
          'BatchNo': batchNoController.text.trim(),
          'StartDate': startDate.toString(),
          'StartEnd': StartEndValue.toString(),
        });
        print("saveSendSqlite");
        setState(() {
          _clearAllData();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _updateSendSqlite() async {
    try {
      if (operatorNameController.text.isNotEmpty) {
        await databaseHelper.updateProcessStart(
            table: 'PROCESS_SHEET',
            key1: 'OperatorName',
            yieldKey1: int.tryParse(operatorNameController.text.trim()),
            key2: 'OperatorName1',
            yieldKey2: int.tryParse(operatorName1Controller.text.trim() ?? ""),
            key3: 'OperatorName2',
            yieldKey3: int.tryParse(operatorName2Controller.text.trim() ?? ""),
            key4: 'OperatorName3',
            yieldKey4: int.tryParse(operatorName3Controller.text.trim() ?? ""),
            key5: 'BatchNo',
            yieldKey5: batchNoController.text.trim(),
            key6: 'StartDate',
            yieldKey6: startDate.toString(),
            whereKey: 'Machine',
            value: MachineController.text.trim());
        print("updateSendSqlite");
      }
    } catch (e) {
      print(e);
    }
  }

  void _btnSend() async {
    if (MachineController.text.isNotEmpty &&
        operatorNameController.text.isNotEmpty &&
        batchNoController.text.isNotEmpty) {
      _callAPI();
      // _checkSendSqlite();
      // _saveDataToSqlite();
    } else {
      EasyLoading.showInfo("กรุณาใส่ข้อมูลให้ครบ");
    }
  }

  void _callAPI() {
    BlocProvider.of<LineElementBloc>(context).add(
      ProcessStartEvent(ProcessOutputModel(
        MACHINE: MachineController.text.trim(),
        OPERATORNAME: int.tryParse(operatorNameController.text.trim()),
        OPERATORNAME1: int.tryParse(operatorName1Controller.text.trim()),
        OPERATORNAME2: int.tryParse(operatorName2Controller.text.trim()),
        OPERATORNAME3: int.tryParse(operatorName3Controller.text.trim()),
        BATCHNO: batchNoController.text.trim(),
        STARTDATE: startDate.toString(),
        STARTEND: 'S',
      )),
    );
  }

  void _clearAllData() async {
    try {
      MachineController.text = "";
      operatorNameController.text = "";
      operatorName1Controller.text = "";
      operatorName2Controller.text = "";
      operatorName3Controller.text = "";
      batchNoController.text = "";
    } catch (e) {
      print(e);
    }
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
}

class ProcessStartDataSource extends DataGridSource {
  ProcessStartDataSource({List<ProcessModel>? process}) {
    if (process != null) {
      for (var _item in process) {
        _employees.add(
          DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'Machine', value: _item.MACHINE),
              DataGridCell<String>(
                  columnName: 'Operatorname', value: _item.OPERATOR_NAME),
              DataGridCell<String>(
                  columnName: 'Operatorname1', value: _item.OPERATOR_NAME1),
              DataGridCell<String>(
                  columnName: 'Operatorname2', value: _item.OPERATOR_NAME2),
              DataGridCell<String>(
                  columnName: 'Operatorname3', value: _item.OPERATOR_NAME3),
              DataGridCell<int>(
                  columnName: 'BatchNO',
                  value: int.tryParse(_item.BATCH_NO.toString())),
            ],
          ),
        );
      }
    } else {
      EasyLoading.showError("Can not request Data");
    }
  }

  List<DataGridRow> _employees = [];

  @override
  List<DataGridRow> get rows => _employees;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>(
        (dataGridCell) {
          return Container(
            alignment: (dataGridCell.columnName == 'id' ||
                    dataGridCell.columnName == 'qty')
                ? Alignment.center
                : Alignment.center,
            child: Text(dataGridCell.value.toString()),
          );
        },
      ).toList(),
    );
  }
}
