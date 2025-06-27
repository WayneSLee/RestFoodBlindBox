import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restfoodblindbox/bloc/store/store_event.dart';
import 'package:restfoodblindbox/bloc/store/store_state.dart';
import 'package:restfoodblindbox/services/api_service.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  StoreBloc() : super(StoreInitial()) {
    on<StoresFetched>(_onStoresFetched);
  }

  Future<void> _onStoresFetched(StoresFetched event, Emitter<StoreState> emit) async {
    emit(StoreLoading());
    try {
      final stores = await ApiService.fetchStores();
      emit(StoreLoaded(stores));
    } catch (e) {
      emit(StoreError(e.toString()));
    }
  }
}