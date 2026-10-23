import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model/customer_model.dart';
import 'repository.dart';

final customersProvider = FutureProvider.autoDispose<List<CustomerModel>>((ref) {
  return ref.watch(customersRepositoryProvider).getCustomers();
});