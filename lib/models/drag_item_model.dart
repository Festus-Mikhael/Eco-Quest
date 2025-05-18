import 'package:cloud_firestore/cloud_firestore.dart';

// Model DragItem merepresentasikan item yang akan digunakan dalam game drag-and-drop
class DragItem {
  final String label;     // Label teks dari item
  final String category;  // Kategori item

  // Konstruktor untuk membuat instance DragItem dengan parameter wajib
  DragItem({required this.label, required this.category});

  // Factory constructor untuk membuat instance DragItem dari dokumen Firestore
  factory DragItem.fromDoc(DocumentSnapshot doc) {
    // Mengambil data dari dokumen dan meng-cast-nya ke Map
    final data = doc.data() as Map<String, dynamic>;

    // Membuat dan mengembalikan DragItem berdasarkan data Firestore
    return DragItem(
      label: data['label'],         // Mengambil field 'label' dari Firestore
      category: data['category'],   // Mengambil field 'category' dari Firestore
    );
  }
}
