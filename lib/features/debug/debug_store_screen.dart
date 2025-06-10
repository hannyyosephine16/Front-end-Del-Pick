// // lib/features/debug/debug_store_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/data/repositories/store_repository.dart';
// import 'package:del_pick/data/models/store/store_model.dart';
//
// class DebugStoreScreen extends StatefulWidget {
//   const DebugStoreScreen({super.key});
//
//   @override
//   State<DebugStoreScreen> createState() => _DebugStoreScreenState();
// }
//
// class _DebugStoreScreenState extends State<DebugStoreScreen> {
//   bool isLoading = false;
//   String? errorMessage;
//   List<StoreModel> stores = [];
//
//   Future<void> testStoreAPI() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//       stores = [];
//     });
//
//     try {
//       print('🔍 Testing Store API...');
//
//       final storeRepository = Get.find<StoreRepository>();
//       final result = await storeRepository.getAllStores();
//
//       print('📊 API Result: ${result.isSuccess}');
//       print('📝 Message: ${result.message}');
//
//       if (result.isSuccess && result.data != null) {
//         print('✅ Success! Found ${result.data!.length} stores');
//
//         // Print each store details
//         for (var store in result.data!) {
//           print('🏪 Store: ${store.name} (ID: ${store.id})');
//           print('   Status: ${store.status}');
//           print('   Address: ${store.address}');
//           print('   Rating: ${store.rating}');
//           print('   Distance: ${store.distance}');
//         }
//
//         setState(() {
//           stores = result.data!;
//         });
//       } else {
//         print('❌ Failed: ${result.message}');
//         setState(() {
//           errorMessage = result.message ?? 'Unknown error';
//         });
//       }
//     } catch (e) {
//       print('💥 Exception: $e');
//       setState(() {
//         errorMessage = 'Exception: $e';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Debug Store API'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: testStoreAPI,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Test button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : testStoreAPI,
//                 child: Text(isLoading ? 'Testing...' : 'Test Store API'),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Loading indicator
//             if (isLoading)
//               const Center(
//                 child: Column(
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 8),
//                     Text('Loading stores...'),
//                   ],
//                 ),
//               ),
//
//             // Error message
//             if (errorMessage != null)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade50,
//                   border: Border.all(color: Colors.red),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Error:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                       ),
//                     ),
//                     Text(
//                       errorMessage!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ],
//                 ),
//               ),
//
//             // Success result
//             if (stores.isNotEmpty) ...[
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   border: Border.all(color: Colors.green),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Success! Found ${stores.length} stores:',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     ...stores.map((store) => Padding(
//                           padding: const EdgeInsets.only(bottom: 4),
//                           child: Text(
//                             '• ${store.name} (${store.status})',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         )),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Store list
//               const Text(
//                 'Store Details:',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: stores.length,
//                   itemBuilder: (context, index) {
//                     final store = stores[index];
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       child: ListTile(
//                         title: Text(store.name),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('ID: ${store.id}'),
//                             Text('Status: ${store.status}'),
//                             Text('Address: ${store.address}'),
//                             if (store.rating != null)
//                               Text('Rating: ${store.rating}'),
//                             if (store.distance != null)
//                               Text('Distance: ${store.distance} km'),
//                           ],
//                         ),
//                         trailing: Icon(
//                           store.isActive ? Icons.check_circle : Icons.error,
//                           color: store.isActive ? Colors.green : Colors.red,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
