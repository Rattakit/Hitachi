import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hitachi/blocs/lineElement/line_element_bloc.dart';
import 'package:hitachi/helper/background/bg_white.dart';
import 'package:hitachi/helper/button/Button.dart';
import 'package:hitachi/helper/colors/colors.dart';
import 'package:hitachi/helper/input/boxInputField.dart';
import 'package:hitachi/helper/text/label.dart';
import 'package:hitachi/models-Sqlite/windingSheetModel.dart';
import 'package:hitachi/models/SendWds/SendWdsModel_Output.dart';
import 'package:hitachi/route/router_list.dart';
import 'package:hitachi/screens/lineElement/windingStart/windingStart_Control.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:hitachi/services/databaseHelper.dart';
// import 'package:hitachi/models/SendWds/HoldWdsMoel.dart';

class WindingJobStartHoldScreen extends StatefulWidget {
  const WindingJobStartHoldScreen({Key? key}) : super(key: key);

  @override
  State<WindingJobStartHoldScreen> createState() =>
      _WindingJobStartHoldScreenState();
}

class _WindingJobStartHoldScreenState extends State<WindingJobStartHoldScreen> {
  final _formKey = GlobalKey<FormState>();
  // final TextEditingController machineNo = TextEditingController();
  // final TextEditingController operatorName = TextEditingController();
  // final TextEditingController batchNo = TextEditingController();
  // final TextEditingController product = TextEditingController();
  // final TextEditingController filmPackNo = TextEditingController();
  // final TextEditingController paperCodeLot = TextEditingController();
  // final TextEditingController ppFilmLot = TextEditingController();
  // final TextEditingController foilLot = TextEditingController();
  // final TextEditingController batchstartdate = TextEditingController();
  // final TextEditingController batchenddate = TextEditingController();
  // final TextEditingController element = TextEditingController();
  // final TextEditingController status = TextEditingController();
  final TextEditingController password = TextEditingController();
  WindingsDataSource? WindingDataSource;
  // List<WindingSheetModel>? wdsSqliteModel;
  List<WindingSheetModel> wdsList = [];
  List<WindingSheetModel>? wdsSqliteModel;
  DataGridRow? datagridRow;
  bool isClick = false;
  Color _colorSend = COLOR_GREY;
  Color _colorDelete = COLOR_GREY;
  bool isHidewidget = false;
  List<WindingSheetModel> wdsSelectdAll = [];
  int? selectedRowIndex;
  DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  void initState() {
    super.initState();

    _getWindingSheet().then((result) {
      setState(() {
        wdsList = result;
        WindingDataSource = WindingsDataSource(process: wdsList);
      });
    });
  }

  Future<List<WindingSheetModel>> _getWindingSheet() async {
    try {
      List<Map<String, dynamic>> rows =
          await databaseHelper.queryAllRows('WINDING_SHEET');
      List<WindingSheetModel> result = rows
          .where((row) => row['Status'] == 'P')
          .map((row) => WindingSheetModel.fromMap(
              row.map((key, value) => MapEntry(key, value.toString()))))
          .toList();

      return result;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BgWhite(
      isHideAppBar: true,
      textTitle: "Winding job Start(Hold)",
      body: MultiBlocListener(
        listeners: [
          BlocListener<LineElementBloc, LineElementState>(
            listener: (context, state) {
              if (state is PostSendWindingStartLoadingState) {
                EasyLoading.show();
              } else if (state is PostSendWindingStartLoadedState) {
                EasyLoading.dismiss();
                if (state.item.RESULT == true) {
                  Navigator.pop(context);
                  deletedInfo();

                  EasyLoading.showSuccess("Send complete",
                      duration: Duration(seconds: 3));
                } else {
                  EasyLoading.showError("${state.item.MESSAGE}");
                }
              } else {
                EasyLoading.dismiss();
                EasyLoading.showError("Please Check Connection Internet");
              }
            },
          )
        ],
        child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                WindingDataSource != null
                    ? Expanded(
                        child: Container(
                          child: SfDataGrid(
                            source: WindingDataSource!,
                            // columnWidthMode: ColumnWidthMode.fill,
                            showCheckboxColumn: true,
                            selectionMode: SelectionMode.multiple,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            gridLinesVisibility: GridLinesVisibility.both,
                            allowPullToRefresh: true,
                            // selectionManager:SelectionManagerBase(),
                            onSelectionChanged:
                                (selectedRows, deselectedRows) async {
                              if (selectedRows.isNotEmpty) {
                                setState(() {
                                  selectedRowIndex = selectedRows.isNotEmpty
                                      ? WindingDataSource!.effectiveRows
                                          .indexOf(selectedRows.first)
                                      : null;
                                  datagridRow = WindingDataSource!.effectiveRows
                                      .elementAt(selectedRowIndex!);
                                  wdsSqliteModel = datagridRow!
                                      .getCells()
                                      .map(
                                        (e) => WindingSheetModel(
                                          MACHINE_NO: e.value.toString(),
                                          OPERATOR_NAME: e.value.toString(),
                                          BATCH_NO: e.value.toString(),
                                          PRODUCT: e.value.toString(),
                                          PACK_NO: e.value.toString(),
                                          PAPER_CORE: e.value.toString(),
                                          PP_CORE: e.value.toString(),
                                          FOIL_CORE: e.value.toString(),
                                          BATCH_START_DATE: e.value.toString(),
                                          BATCH_END_DATE: e.value.toString(),
                                          ELEMENT: e.value.toString(),
                                          STATUS: e.value.toString(),
                                          START_END: e.value.toString(),
                                          CHECK_COMPLETE: e.value.toString(),
                                        ),
                                      )
                                      .toList();
                                  print(wdsList[selectedRowIndex!].ID);
                                  _colorSend = COLOR_SUCESS;
                                  _colorDelete = COLOR_RED;
                                  // if (selectedRowIndex == 0) {
                                  //   wdsSelectdAll
                                  //       .add(wdsSqliteModel![selectedRowIndex!]);
                                  // }
                                  // print(selectedRows.length);
                                });
                              } else {
                                setState(() {
                                  wdsSelectdAll.clear();
                                });
                                // print(selectedRowIndex);
                                // ไม่มีการเลือกแถว
                                print('No Rows Selected');
                                // ดำเนินการเพิ่มเติมที่คุณต้องการทำ
                              }
                            },
                            onCellTap: (details) async {
                              // if (details.rowColumnIndex.rowIndex != 0) {
                              //   setState(() {
                              //     selectedRowIndex =
                              //         details.rowColumnIndex.rowIndex - 1;
                              //     datagridRow = WindingDataSource!.effectiveRows
                              //         .elementAt(selectedRowIndex!);
                              //     wdsSqliteModel = datagridRow!
                              //         .getCells()
                              //         .map(
                              //           (e) => WindingSheetModel(
                              //             MACHINE_NO: e.value.toString(),
                              //             OPERATOR_NAME: e.value.toString(),
                              //             BATCH_NO: e.value.toString(),
                              //             PRODUCT: e.value.toString(),
                              //             PACK_NO: e.value.toString(),
                              //             PAPER_CORE: e.value.toString(),
                              //             PP_CORE: e.value.toString(),
                              //             FOIL_CORE: e.value.toString(),
                              //             BATCH_START_DATE: e.value.toString(),
                              //             BATCH_END_DATE: e.value.toString(),
                              //             ELEMENT: e.value.toString(),
                              //             STATUS: e.value.toString(),
                              //             START_END: e.value.toString(),
                              //             CHECK_COMPLETE: e.value.toString(),
                              //           ),
                              //         )
                              //         .toList();
                              //     _colorSend = COLOR_SUCESS;
                              //     _colorDelete = COLOR_RED;
                              //   });
                              // }
                            },
                            columns: <GridColumn>[
                              GridColumn(
                                  columnName: 'machineno',
                                  label: Container(
                                    color: COLOR_BLUE_DARK,
                                    child: Center(
                                        child: Label(
                                      'Machine No.',
                                      fontSize: 14,
                                      color: COLOR_WHITE,
                                    )),
                                    // color: COLOR_BLUE_DARK,
                                  )),
                              GridColumn(
                                columnName: 'operatorName',
                                label: Container(
                                  color: COLOR_BLUE_DARK,
                                  child: Center(
                                      child: Label(
                                    'Operator Name',
                                    textAlign: TextAlign.center,
                                    fontSize: 14,
                                    color: COLOR_WHITE,
                                  )),
                                ),
                              ),
                              GridColumn(
                                  columnName: 'batchno',
                                  label: Container(
                                    color: COLOR_BLUE_DARK,
                                    child: Center(
                                        child: Label(
                                      'Batch No.',
                                      fontSize: 14,
                                      color: COLOR_WHITE,
                                    )),
                                  ),
                                  width: 100),
                              GridColumn(
                                  columnName: 'product',
                                  label: Container(
                                    color: COLOR_BLUE_DARK,
                                    child: Center(
                                        child: Label(
                                      'Product',
                                      fontSize: 14,
                                      color: COLOR_WHITE,
                                    )),
                                  ),
                                  width: 100),
                              GridColumn(
                                  columnName: 'filmpackno',
                                  label: Container(
                                    color: COLOR_BLUE_DARK,
                                    child: Center(
                                        child: Label(
                                      'Film pack No.',
                                      fontSize: 14,
                                      color: COLOR_WHITE,
                                    )),
                                  )),
                              GridColumn(
                                  columnName: 'papercodelot',
                                  label: Container(
                                    color: COLOR_BLUE_DARK,
                                    child: Center(
                                        child: Label(
                                      'Paper core lot',
                                      textAlign: TextAlign.center,
                                      fontSize: 14,
                                      color: COLOR_WHITE,
                                    )),
                                  )),
                              GridColumn(
                                  columnName: 'PPfilmlot',
                                  label: Container(
                                    color: COLOR_BLUE_DARK,
                                    child: Center(
                                        child: Label(
                                      'PP film lot',
                                      fontSize: 14,
                                      color: COLOR_WHITE,
                                    )),
                                  )),
                              GridColumn(
                                  columnName: 'foillot',
                                  label: Container(
                                    color: COLOR_BLUE_DARK,
                                    child: Center(
                                        child: Label(
                                      'Foil Lot',
                                      fontSize: 14,
                                      color: COLOR_WHITE,
                                    )),
                                  )),
                              GridColumn(
                                  columnName: 'batchstart',
                                  label: Container(
                                    color: COLOR_BLUE_DARK,
                                    child: Center(
                                        child: Label(
                                      'StartDate',
                                      fontSize: 14,
                                      color: COLOR_WHITE,
                                    )),
                                  )),
                              GridColumn(
                                  columnName: 'status',
                                  label: Container(
                                    color: COLOR_BLUE_DARK,
                                    child: Center(
                                        child: Label(
                                      'Status',
                                      fontSize: 14,
                                      color: COLOR_WHITE,
                                    )),
                                  )),
                            ],
                          ),
                        ),
                      )
                    : CircularProgressIndicator(),
                wdsSqliteModel != null
                    ? Expanded(
                        child: Container(
                          child: ListView(
                            children: [
                              DataTable(
                                  horizontalMargin: 20,
                                  headingRowHeight: 30,
                                  dataRowHeight: 30,
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => COLOR_BLUE_DARK),
                                  border: TableBorder.all(
                                    width: 1.0,
                                    color: COLOR_BLACK,
                                  ),
                                  columns: [
                                    DataColumn(
                                      numeric: true,
                                      label: Label(
                                        "",
                                        color: COLOR_BLUE_DARK,
                                      ),
                                    ),
                                    DataColumn(label: Label(""))
                                  ],
                                  rows: [
                                    DataRow(cells: [
                                      DataCell(
                                          Center(child: Label("Machine No."))),
                                      DataCell(Label(
                                          '${wdsList[selectedRowIndex!].MACHINE_NO} '))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(
                                          Center(child: Label("OperatorName"))),
                                      DataCell(Label(
                                          "${wdsList[selectedRowIndex!].OPERATOR_NAME}"))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(
                                          Center(child: Label("Batch No."))),
                                      DataCell(Label(
                                          "${wdsList[selectedRowIndex!].BATCH_NO}"))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Center(child: Label("Product"))),
                                      DataCell(Label(
                                          "${wdsList[selectedRowIndex!].PRODUCT}"))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(
                                          Center(child: Label("Film pack No"))),
                                      DataCell(Label(
                                          "${wdsList[selectedRowIndex!].PACK_NO}"))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Center(
                                          child: Label("Paper Core Lot"))),
                                      DataCell(Label(
                                          "${wdsList[selectedRowIndex!].PAPER_CORE}"))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(
                                          Center(child: Label("PP film Lot"))),
                                      DataCell(Label(
                                          "${wdsList[selectedRowIndex!].PP_CORE}"))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(
                                          Center(child: Label("Foil Lot"))),
                                      DataCell(Label(
                                          "${wdsList[selectedRowIndex!].FOIL_CORE}"))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(
                                          Center(child: Label("StartDate"))),
                                      DataCell(Label(
                                          "${wdsList[selectedRowIndex!].BATCH_START_DATE}"))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Center(child: Label("Status"))),
                                      DataCell(Label(
                                          "${wdsList[selectedRowIndex!].STATUS}"))
                                    ]),
                                  ])
                            ],
                          ),
                        ),
                      )
                    : CircularProgressIndicator(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: Button(
                      onPress: () {
                        if (wdsList != null) {
                          _AlertDialog();
                        } else {
                          _LoadingData();
                        }
                      },
                      text: Label(
                        "Delete",
                        color: COLOR_WHITE,
                      ),
                      bgColor: _colorDelete,
                    )),
                    Expanded(child: Container()),
                    Expanded(
                        child: Button(
                      text: Label("Send", color: COLOR_WHITE),
                      bgColor: _colorSend,
                      onPress: () {
                        if (wdsList != null) {
                          _sendDataServer();
                        } else {
                          EasyLoading.showInfo("Please Select Data");
                        }
                      },
                    )),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            )),
      ),
    );
  }

  void _AlertDialog() async {
    // EasyLoading.showError("Error[03]", duration: Duration(seconds: 5));//if password
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        // title: const Text('AlertDialog Title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Label(
                  "Do you want Delete \n BatchNo ${wdsList[selectedRowIndex!].BATCH_NO}"),
            ),
          ],
        ),

        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deletedInfo();
              Navigator.pop(context);
              Navigator.pop(context);
              EasyLoading.showSuccess("Delete Success");
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void deletedInfo() async {
    await databaseHelper.deletedRowSqlite(
        tableName: 'WINDING_SHEET',
        columnName: 'ID',
        columnValue: wdsList[selectedRowIndex!].ID);
  }

  void _sendDataServer() async {
    BlocProvider.of<LineElementBloc>(context).add(
      PostSendWindingStartEvent(
        SendWindingStartModelOutput(
            MACHINE_NO: wdsList[selectedRowIndex!].MACHINE_NO,
            OPERATOR_NAME: int.tryParse(
                wdsList[selectedRowIndex!].OPERATOR_NAME.toString()),
            PRODUCT: int.tryParse(
              wdsList[selectedRowIndex!].PRODUCT.toString(),
            ),
            FILM_PACK_NO: int.tryParse(
              wdsList[selectedRowIndex!].PACK_NO.toString(),
            ),
            PAPER_CODE_LOT: wdsList[selectedRowIndex!].PAPER_CORE,
            PP_FILM_LOT: wdsList[selectedRowIndex!].PP_CORE,
            FOIL_LOT: wdsList[selectedRowIndex!].FOIL_CORE),
      ),
    );
  }

  void _LoadingData() {
    EasyLoading.showInfo("Please Select Data", duration: Duration(seconds: 2));
  }
}

class WindingsDataSource extends DataGridSource {
  WindingsDataSource({List<WindingSheetModel>? process}) {
    if (process != null) {
      for (var _item in process) {
        _employees.add(
          DataGridRow(
            cells: [
              DataGridCell<String>(
                  columnName: 'machineno', value: _item.MACHINE_NO),
              DataGridCell<String>(
                  columnName: 'operatorName', value: _item.OPERATOR_NAME),
              DataGridCell<String>(
                  columnName: 'batchno', value: _item.BATCH_NO),
              DataGridCell<String>(columnName: 'product', value: _item.PRODUCT),
              DataGridCell<String>(
                  columnName: 'filmpackno', value: _item.PACK_NO),
              DataGridCell<String>(
                  columnName: 'papercodelot', value: _item.PAPER_CORE),
              DataGridCell<String>(
                  columnName: 'PPfilmlot', value: _item.PP_CORE),
              DataGridCell<String>(
                  columnName: 'foillot', value: _item.FOIL_CORE),
              DataGridCell<String>(
                  columnName: 'batchstart', value: _item.BATCH_START_DATE),
              DataGridCell<String>(columnName: 'status', value: _item.STATUS),
            ],
          ),
        );
      }
    } else {
      EasyLoading.showError("Can not Call API");
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
