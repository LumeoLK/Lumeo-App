// import 'package:flutter/material.dart';
// import 'package:demo/pages/home_page.dart';

// class ReserveSuccessPage extends StatelessWidget {
//   const ReserveSuccessPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             //top space
//             const SizedBox(height: 20),
            
//             //center content with the image
//             Column(
//                 children: [ 
//                     Image.asset(
//                         "assets/images/bags.png",
//                         height: 220,
//                     ),
                
//                     const SizedBox(height: 40),

//                     //text
//                     const Text(
//                         "Success!",
//                         style: TextStyle(
//                             color: Color.white,
//                             fontSize: 34,
//                             fontweight: FontWeight.bold,

//                         ),
//                     ),

//                     const SizedBox(height: 20),

//                     //subtext
//                     const Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 40),
//                         child: Text(
//                             "Your reservation is confirmed!",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 color: Color.white,
//                                 fontSize: 16,
//                                 height: 1.5

//                             ),
//                         ),
//                     ),
//                 ],          
//             ),
//             //bottom button
//             Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                         onPressed: () {
//                             Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
//                         },
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFE09D3B),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                             ),
//                         ),
//                         child: const Text(
//                             "CONTINUE SHOPPING",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                             ),
//                         ),
//                     ),
//                 ),
//             ),

//           ],
//         ),
//       ),
//     );
//   }
// }