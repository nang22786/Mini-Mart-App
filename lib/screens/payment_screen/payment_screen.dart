// // lib/screens/payment/payment_screen.dart

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:khqr_sdk/khqr_sdk.dart';
// import 'package:mini_mart/bloc/order/order_bloc.dart';
// import 'package:mini_mart/bloc/order/order_event.dart';
// import 'package:mini_mart/bloc/order/order_state.dart';
// import 'package:mini_mart/helper/notification_helper.dart';
// import 'package:mini_mart/screens/order_screen/order_details_screen.dart';
// import 'package:mini_mart/screens/screen_controller/screen_controller.dart';
// import 'package:mini_mart/styles/fonts.dart';

// class PaymentScreen extends StatefulWidget {
//   final double amount;
//   final int orderId;
//   const PaymentScreen({super.key, required this.amount, required this.orderId});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   String? khqrContent;
//   String? errorMessage;
//   File? _selectedImage;
//   bool _isUploading = false;
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     generateIndividual();
//   }

//   /// Generate KHQR Code
//   Future<void> generateIndividual() async {
//     try {
//       final info = IndividualInfo(
//         bakongAccountId: 'samnang_yorn@wing',
//         merchantName: 'SAMNANG YORN',
//         accountInformation: '+855963260924',
//         currency: KhqrCurrency.usd,
//         amount: widget.amount,
//       );
//       final res = KhqrSdk.generateIndividual(info);
//       setState(() {
//         khqrContent = res.data?.qr;
//       });
//     } on PlatformException catch (e) {
//       setState(() {
//         errorMessage = e.message;
//       });
//     }
//   }

//   /// Pick image from gallery or camera
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final pickedFile = await _picker.pickImage(
//         source: source,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error picking image: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   /// Show image source selection
//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Select Payment Screenshot',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: kantumruyPro,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt, color: Color(0xFF6C5CE7)),
//                 title: const Text(
//                   'Take Photo',
//                   style: TextStyle(fontFamily: kantumruyPro),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.photo_library,
//                   color: Color(0xFF6C5CE7),
//                 ),
//                 title: const Text(
//                   'Choose from Gallery',
//                   style: TextStyle(fontFamily: kantumruyPro),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Upload invoice to API
//   Future<void> _uploadInvoice() async {
//     if (_selectedImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a payment screenshot first'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     // Trigger BLoC event to upload
//     context.read<OrderBloc>().add(
//       UploadPaymentScreenshotEvent(
//         orderId: widget.orderId,
//         screenshot: _selectedImage!,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<OrderBloc, OrderState>(
//       listener: (context, state) {
//         if (state is OrderLoading) {
//           setState(() => _isUploading = true);
//         } else if (state is PaymentUploadSuccess) {
//           setState(() => _isUploading = false);

//           // ✅ SEND NOTIFICATION ON SUCCESSFUL PAYMENT UPLOAD
//           NotificationHelper.sendPaymentConfirmedNotification(
//             orderId: widget.orderId,
//           );

//           // Show success dialog
//           showDialog(
//             context: context,
//             barrierDismissible: false,
//             builder: (context) => AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               title: Column(
//                 children: [
//                   Icon(
//                     state.verified ? Icons.check_circle : Icons.info,
//                     color: state.verified ? Colors.green : Colors.orange,
//                     size: 60,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     state.verified ? 'Payment Verified!' : 'Payment Uploaded',
//                     style: const TextStyle(
//                       fontFamily: kantumruyPro,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               content: Text(
//                 state.message,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontFamily: kantumruyPro),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context); // Close dialog
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             OrderDetailsScreen(orderId: widget.orderId),
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     'View Orders',
//                     style: TextStyle(
//                       color: Color(0xFF6C5CE7),
//                       fontFamily: kantumruyPro,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else if (state is PaymentUploadFailure) {
//           setState(() => _isUploading = false);

//           // ✅ SEND FAILURE NOTIFICATION
//           NotificationHelper.sendPaymentFailedNotification(
//             orderId: widget.orderId,
//             reason: state.error,
//           );

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.error), backgroundColor: Colors.red),
//           );
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           surfaceTintColor: Colors.transparent,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () => Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const ScreenController()),
//             ),
//           ),
//           title: Text(
//             'Payment - Order #${widget.orderId}',
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//               fontFamily: kantumruyPro,
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             children: [
//               // Payment Instructions
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blue.shade200),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.blue),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'Scan QR code to pay, then upload payment screenshot',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.blue,
//                           fontFamily: kantumruyPro,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // KHQR or Error
//               if (errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Text(
//                     errorMessage!,
//                     style: const TextStyle(color: Colors.red),
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//               else if (khqrContent == null)
//                 const Padding(
//                   padding: EdgeInsets.all(40),
//                   child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
//                 )
//               else
//                 Column(
//                   children: [
//                     // KHQR Card
//                     KhqrCardWidget(
//                       width: 280.0,
//                       receiverName: 'SAMNANG YORN',
//                       amount: widget.amount,
//                       keepIntegerDecimal: false,
//                       currency: KhqrCurrency.usd,
//                       qr: khqrContent!,
//                     ),

//                     const SizedBox(height: 32),

//                     // Upload Section Title
//                     const Text(
//                       'Upload Payment Screenshot',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: kantumruyPro,
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     // Image Preview or Placeholder
//                     GestureDetector(
//                       onTap: _showImageSourceDialog,
//                       child: Container(
//                         height: 200,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(
//                             color: _selectedImage != null
//                                 ? const Color(0xFF6C5CE7)
//                                 : Colors.grey.shade400,
//                             width: 2,
//                           ),
//                         ),
//                         child: _selectedImage != null
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(13),
//                                 child: Stack(
//                                   children: [
//                                     Image.file(
//                                       _selectedImage!,
//                                       fit: BoxFit.cover,
//                                       width: double.infinity,
//                                       height: double.infinity,
//                                     ),
//                                     Positioned(
//                                       top: 8,
//                                       right: 8,
//                                       child: CircleAvatar(
//                                         backgroundColor: Colors.black54,
//                                         child: IconButton(
//                                           icon: const Icon(
//                                             Icons.edit,
//                                             color: Colors.white,
//                                             size: 20,
//                                           ),
//                                           onPressed: _showImageSourceDialog,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.cloud_upload_outlined,
//                                     size: 60,
//                                     color: Colors.grey.shade400,
//                                   ),
//                                   const SizedBox(height: 12),
//                                   const Text(
//                                     'Tap to upload payment screenshot',
//                                     style: TextStyle(
//                                       color: Colors.grey,
//                                       fontFamily: kantumruyPro,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // Upload Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: _isUploading ? null : _uploadInvoice,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF6C5CE7),
//                           disabledBackgroundColor: Colors.grey[300],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: _isUploading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text(
//                                 'Submit Payment',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: kantumruyPro,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
