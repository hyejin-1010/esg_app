import 'package:esg_app/constant/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AddImageBox extends StatefulWidget {
  const AddImageBox({super.key, required this.onImageSelected});

  final Function(XFile) onImageSelected;

  @override
  State<AddImageBox> createState() => _AddImageBoxState();
}

class _AddImageBoxState extends State<AddImageBox> {
  final ImagePicker _picker = ImagePicker();

  void _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) widget.onImageSelected(pickedFile);
    } catch (e) {
      debugPrint('[ERROR] pick image error : $e');
    }
  }

  void _onClickAddImageButton() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: const Text('카메라 촬영'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: const Text('갤러리'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onClickAddImageButton(),
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: whiteColor,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
