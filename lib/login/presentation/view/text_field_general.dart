part of "login_page.dart"; 

class TextFieldGeneral extends StatelessWidget {

  final String labelText;
  final String? hintText;
  final Function onChanged;
  final TextInputType? keyboardType;
  final IconData icon;
  final bool obscureText;

  const TextFieldGeneral({super.key, 
    required this.labelText, 
    this.hintText, 
    required this.onChanged, 
    this.keyboardType,
    required this.icon,
    this.obscureText = false
    });
  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 30,
      ),
      decoration: BoxDecoration(
        color: Color(0xfff2f2f2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          // BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5),
        ],
      ),
      child: TextField(
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: labelText,
          hintText: hintText,
          border: InputBorder.none,
        ),
        onChanged: (value) {},
      ),
    );
  }
}