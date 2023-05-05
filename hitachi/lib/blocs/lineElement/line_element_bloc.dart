import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:hitachi/api.dart';
import 'package:hitachi/models/SendWds/SendWdsModel_Output.dart';
import 'package:hitachi/models/SendWds/sendWdsModel_input.dart';
import 'package:hitachi/models/sendWdsReturnWeight/sendWdsReturnWeight_Input_Model.dart';
import 'package:hitachi/models/sendWdsReturnWeight/sendWdsReturnWeight_Output_Model.dart';

part 'line_element_event.dart';
part 'line_element_state.dart';

class LineElementBloc extends Bloc<LineElementEvent, LineElementState> {
  LineElementBloc() : super(LineElementInitial()) {
    on<LineElementEvent>((event, emit) {
      // TODO: implement event handler
    });
    //HOLD
    on<PostSendWindingStartEvent>(
      (event, emit) async {
        try {
          emit(PostSendWindingStartLoadingState());
          final mlist = await fetchSendWindingHold(event.items);
          emit(PostSendWindingStartLoadedState(mlist));
        } catch (e) {
          emit(PostSendWindingStartErrorState(e.toString()));
        }
      },
    );
    //SCAN
    on<PostSendWindingStartReturnWeightEvent>(
      (event, emit) async {
        try {
          emit(PostSendWindingStartReturnWeightLoadingState());
          final mlist = await fetchSendWindingReturnWeightScan(event.items);
          emit(PostSendWindingStartReturnWeightLoadedState(mlist));
        } catch (e) {
          emit(PostSendWindingStartReturnWeightErrorState(e.toString()));
        }
      },
    );
  }
//Scan
  Future<sendWdsReturnWeightInputModel> fetchSendWindingReturnWeightScan(
      sendWdsReturnWeightOutputModel item) async {
    try {
      Response responese = await Dio().post(
          ApiConfig.LE_SEND_WINDING_START_WEIGHT,
          options: Options(headers: ApiConfig.HEADER()),
          data: jsonEncode(item));
      print(responese.data);
      sendWdsReturnWeightInputModel post =
          sendWdsReturnWeightInputModel.fromJson(responese.data);
      return post;
    } catch (e, s) {
      print("Exception occured: $e StackTrace: $s");
      return sendWdsReturnWeightInputModel();
    }
  }

  //Hold
  Future<SendWindingStartModelInput> fetchSendWindingHold(
      SendWindingStartModelOutput itemOutput) async {
    try {
      Response responese = await Dio().post(ApiConfig.LE_SEND_WINDING_START,
          options: Options(headers: ApiConfig.HEADER()),
          data: jsonEncode(itemOutput));
      print(responese.data);
      SendWindingStartModelInput post =
          SendWindingStartModelInput.fromJson(responese.data);

      return post;
    } catch (e, s) {
      // throw StateError();
      print("Exception occured: $e StackTrace: $s");
      return SendWindingStartModelInput();
    }
  }
}
