import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:langvify/models/conversion_model.dart';
import 'package:langvify/services/store_conversions_storage.dart';

class StoreConversionsFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //methode to store the conversion data in the firestore
  Future<void> storeConversionData({
    required conversionData,
    required convertedDate,
    required imageFile,
  }) async {
    try {
      //if there is no user id then create a new user as a anonymous user from firebase auth
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      final userId = _auth.currentUser!.uid;

      //store the image in the storage and get the download url
      final imageUrl = await StoreConversionsStorage().uploadImage(
        postImage: imageFile,
        userId: userId,
      );

      //create a reference to the collection in the firestore
      CollectionReference conversions = _firestore.collection('conversions');

      final ConversionModel newConversion = ConversionModel(
        userId: userId,
        conversionData: conversionData,
        convertedDate: convertedDate,
        imageUrl: imageUrl,
      );

      //store the data in the firestore
      await conversions.add(newConversion.toMap());
    } catch (e) {
      print(e);
    }
  }

  // Method to get all conversion documents for the current user
  Stream<List<ConversionModel>> getUserConversions() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user is currently signed in.');
      }

      return _firestore
          .collection('conversions')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ConversionModel.fromMap(doc.data());
        }).toList();
      });
    } catch (e) {
      print(e);
      return Stream.value([]);
    }
  }
}
