import 'package:flutter/material.dart';

class GlobalMethods{
  static Future<void> errorDialog({required String errorMessage,required BuildContext context}) async {
    await showDialog(
      context: context,
      builder: (context) =>  AlertDialog(
        content:  Text(errorMessage),
        title: const Row(
          children: [
            Icon(Icons.dangerous,color: Colors.red,),
            SizedBox(width: 8,
            ),Text('An Error Occurred')
          ],
        ),
        actions: [
          TextButton(onPressed: (){
            if(Navigator.canPop(context)){
              Navigator.of(context).pop();
            }

          }, child: const Text('ok'))
        ],
      ),
    );
  }
}