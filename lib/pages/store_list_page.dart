import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restfoodblindbox/bloc/product/product_bloc.dart';
import 'package:restfoodblindbox/bloc/store/store_bloc.dart';
import 'package:restfoodblindbox/bloc/store/store_event.dart';
import 'package:restfoodblindbox/bloc/store/store_state.dart';
import 'package:restfoodblindbox/pages/product_list.dart';
import 'package:restfoodblindbox/widgets/store_card.dart';

class StoreListPage extends StatelessWidget {
  const StoreListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 首次進入頁面時，觸發一次 StoresFetched 事件
    context.read<StoreBloc>().add(StoresFetched());

    return Scaffold(
      appBar: AppBar(title: const Text('選擇店家')),
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          if (state is StoreLoading || state is StoreInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StoreLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.stores.length,
              itemBuilder: (context, index) {
                final store = state.stores[index];
                return StoreCard(
                  store: store,
                  onTap: () {
                    // 導航到商品頁，並傳遞 storeId
                    // 同時，為商品頁建立一個專屬的 ProductBloc
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => ProductBloc(),
                          child: ProductListPage(storeId: store.id),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          if (state is StoreError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}