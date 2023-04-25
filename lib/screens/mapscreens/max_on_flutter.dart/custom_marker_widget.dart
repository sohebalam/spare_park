import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

// class CustomMarkerWidget extends StatelessWidget {
//   final double price;
//   const CustomMarkerWidget({super.key, required this.price});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 75,
//       width: 75,
//       child: Stack(
//         alignment: Alignment.topCenter,
//         children: [
//           SizedBox(),
//           const Align(
//             alignment: Alignment.topCenter,
//             child: Icon(
//               Icons.arrow_drop_down,
//               color: Colors.black,
//               size: 70,
//             ),
//           ),
//           Container(
//             margin: const EdgeInsets.only(bottom: 15.0),
//             padding: const EdgeInsets.all(5.0),
//             color: Colors.black,
//             child: Text(
//               '\$$price',
//               style: const TextStyle(color: Colors.white),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
class CustomMarkerWidget extends StatelessWidget {
  final double price;
  const CustomMarkerWidget({Key? key, required this.price}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 75,
        width: 75,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(),
            const Align(
              alignment: Alignment.topCenter,
              child: Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
                size: 70,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              padding: const EdgeInsets.all(5.0),
              color: Colors.black,
              child: Text(
                '\$$price',
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
