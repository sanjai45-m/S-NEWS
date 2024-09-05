import 'package:flutter/material.dart';

class WidgetConstant{

  Widget category(
      {required List<String> categories, required Function(String) fn}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of buttons per row
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
        childAspectRatio:
        3, // Adjust the aspect ratio to make buttons more rectangular
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        String text = categories[index];
        return ElevatedButton(
          onPressed: () {
            fn(text); // Pass the category to the filterSources method
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
                vertical: 10, horizontal: 10), // Adjust padding as needed
          ),
          child: Text(text),
        );
      },
    );
  }

}