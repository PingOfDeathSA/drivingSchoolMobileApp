import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Widget customLoadingAnimation() {
  return LoadingAnimationWidget.staggeredDotsWave(
    color: greenColor,
    size: 30,
  );
}
