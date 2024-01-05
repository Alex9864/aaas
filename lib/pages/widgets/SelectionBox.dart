import 'package:flutter/material.dart';

class SelectionBox extends StatelessWidget {
  final String image;
  final String text;
  final bool isSelected;
  final ValueChanged<String> onSelect;

  SelectionBox(this.image, this.text, this.isSelected, this.onSelect);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(text),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: isSelected ? 170 : 150,
        height: isSelected ? 170 : 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          color: isSelected ? Color.fromRGBO(43, 186, 216, 1) : Colors.white,
          border: Border.all(width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              image,
              height: 80,
              width: 120,
            ),
            SizedBox(height: 20,),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}