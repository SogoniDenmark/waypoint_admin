import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart' show DateFormat;

import 'package:photo_view/photo_view.dart';

class BlankListScreen extends StatefulWidget {
  final String inventoryId;
  final Map<String, dynamic> inventoryData;

  const BlankListScreen({
    super.key,
    required this.inventoryId,
    required this.inventoryData,
  });

  @override
  State<BlankListScreen> createState() => _BlankListScreenState();
}

class _BlankListScreenState extends State<BlankListScreen> {
  late String inventoryName;
  late String plantName;
  late String plantType;
  late String plantPart;
  late String scientificName;
  late String family;
  late String size;
  late String shape;
  late String color;
  late String texture;
  late String growthHabit;
  late String lifespan;
  late String nativeRegion;
  late String climate;
  late String soilPreference;
  late String sunlightRequirements;
  late String waterRequirements;
  late String propagationMethod;
  late String medicinalProperties;
  late String culinaryUses;
  late String industrialUses;
  late String nutritionalValue;
  late String pollinators;
  late String companionPlanting;
  late String pestResistance;
  late String edibility;
  late String growthRate;
  late String floweringSeason;
  late String harvestTime;
  late String otherDetails;
  late int quantity;

  // List to store item-specific details, including image URLs, status, and description
  List<Map<String, dynamic>> itemDetailsList = [];

  @override
  void initState() {
    super.initState();
    // Initialize the state with the passed inventory data
    inventoryName = widget.inventoryData['inventoryName'];
    plantName = widget.inventoryData['plantName'];
    plantType = widget.inventoryData['plantType'];
    plantPart = widget.inventoryData['plantPart'];
    scientificName = widget.inventoryData['scientificName'];
    family = widget.inventoryData['family'];
    size = widget.inventoryData['size'];
    shape = widget.inventoryData['shape'];
    color = widget.inventoryData['color'];
    texture = widget.inventoryData['texture'];
    growthHabit = widget.inventoryData['growthHabit'];
    lifespan = widget.inventoryData['lifespan'];
    nativeRegion = widget.inventoryData['nativeRegion'];
    climate = widget.inventoryData['climate'];
    soilPreference = widget.inventoryData['soilPreference'];
    sunlightRequirements = widget.inventoryData['sunlightRequirements'];
    waterRequirements = widget.inventoryData['waterRequirements'];
    propagationMethod = widget.inventoryData['propagationMethod'];
    medicinalProperties = widget.inventoryData['medicinalProperties'];
    culinaryUses = widget.inventoryData['culinaryUses'];
    industrialUses = widget.inventoryData['industrialUses'];
    nutritionalValue = widget.inventoryData['nutritionalValue'];
    pollinators = widget.inventoryData['pollinators'];
    companionPlanting = widget.inventoryData['companionPlanting'];
    pestResistance = widget.inventoryData['pestResistance'];
    edibility = widget.inventoryData['edibility'];
    growthRate = widget.inventoryData['growthRate'];
    floweringSeason = widget.inventoryData['floweringSeason'];
    harvestTime = widget.inventoryData['harvestTime'];
    otherDetails = widget.inventoryData['otherDetails'];
    quantity = widget.inventoryData['quantity'];

    // Initialize itemDetailsList with default values
    for (int i = 0; i < quantity; i++) {
      itemDetailsList.add({
        'originalIndex': i,
        'status': 'healthy',
        'description': '',
        'imageUrl1': '',
        'imageUrl2': '',
        'imageUrl3': '',
        'imageUrl4': '',
        'decomposed': false,
        'decompositionReason': '',
        'decompositionPurpose': '',
        'lastModified': DateTime.now().toIso8601String(),
      });
    }

    // Fetch the latest item details from Firestore
    _fetchItemDetails();
  }

  // Function to fetch item details from Firestore
  Future<void> _fetchItemDetails() async {
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('inventories')
        .doc(widget.inventoryId)
        .get();

    if (doc.exists) {
      final List<dynamic> items = doc['items'] ?? [];

      // Update the itemDetailsList with data from Firestore
      setState(() {
        for (int i = 0; i < quantity; i++) {
          final itemData = items.firstWhere(
                (item) => item['originalIndex'] == i,
            orElse: () =>
            {
              'originalIndex': i,
              'status': 'healthy',
              'description': '',
              'imageUrl1': '', // Initialize with empty string
              'imageUrl2': '', // Initialize with empty string
              'imageUrl3': '', // Initialize with empty string
              'imageUrl4': '', // Initialize with empty string
              'lastModified': DateTime.now().toIso8601String(),
            },
          );

          itemDetailsList[i] = {
            'originalIndex': itemData['originalIndex'],
            'status': itemData['status'],
            'description': itemData['description'],
            'imageUrl1': itemData['imageUrl1'] ?? '',
            'imageUrl2': itemData['imageUrl2'] ?? '',
            'imageUrl3': itemData['imageUrl3'] ?? '',
            'imageUrl4': itemData['imageUrl4'] ?? '',
            'decomposed': itemData['decomposed'] ?? false,
            'decompositionReason': itemData['decompositionReason'] ?? '',
            'decompositionPurpose': itemData['decompositionPurpose'] ?? '',
            'lastModified': itemData['lastModified'],
          };
        }
      });
    }
  }

  // Function to update the entire items array in Firestore
  Future<void> _updateFirestoreItems() async {
    await FirebaseFirestore.instance
        .collection('inventories')
        .doc(widget.inventoryId)
        .update({
      'items': itemDetailsList
          .map((item) =>
      {
        'originalIndex': item['originalIndex'],
        'status': item['status'],
        'description': item['description'],
        'imageUrl1': item['imageUrl1'],
        'imageUrl2': item['imageUrl2'],
        'imageUrl3': item['imageUrl3'],
        'imageUrl4': item['imageUrl4'],
        'decomposed': item['decomposed'] ?? false,
        'decompositionReason': item['decompositionReason'] ?? '',
        'decompositionPurpose': item['decompositionPurpose'] ?? '',
        'lastModified': item['lastModified'],
      })
          .toList(),
    });
  }

  void _showEditInventoryDialog() {
    final TextEditingController inventoryNameController =
    TextEditingController(text: inventoryName);
    final TextEditingController plantNameController =
    TextEditingController(text: plantName);
    final TextEditingController plantTypeController =
    TextEditingController(text: plantType);
    final TextEditingController plantPartController =
    TextEditingController(text: plantPart);
    final TextEditingController scientificNameController =
    TextEditingController(text: scientificName);
    final TextEditingController familyController =
    TextEditingController(text: family);
    final TextEditingController sizeController =
    TextEditingController(text: size);
    final TextEditingController shapeController =
    TextEditingController(text: shape);
    final TextEditingController colorController =
    TextEditingController(text: color);
    final TextEditingController textureController =
    TextEditingController(text: texture);
    final TextEditingController growthHabitController =
    TextEditingController(text: growthHabit);
    final TextEditingController lifespanController =
    TextEditingController(text: lifespan);
    final TextEditingController nativeRegionController =
    TextEditingController(text: nativeRegion);
    final TextEditingController climateController =
    TextEditingController(text: climate);
    final TextEditingController soilPreferenceController =
    TextEditingController(text: soilPreference);
    final TextEditingController sunlightRequirementsController =
    TextEditingController(text: sunlightRequirements);
    final TextEditingController waterRequirementsController =
    TextEditingController(text: waterRequirements);
    final TextEditingController propagationMethodController =
    TextEditingController(text: propagationMethod);
    final TextEditingController medicinalPropertiesController =
    TextEditingController(text: medicinalProperties);
    final TextEditingController culinaryUsesController =
    TextEditingController(text: culinaryUses);
    final TextEditingController industrialUsesController =
    TextEditingController(text: industrialUses);
    final TextEditingController nutritionalValueController =
    TextEditingController(text: nutritionalValue);
    final TextEditingController pollinatorsController =
    TextEditingController(text: pollinators);
    final TextEditingController companionPlantingController =
    TextEditingController(text: companionPlanting);
    final TextEditingController pestResistanceController =
    TextEditingController(text: pestResistance);
    final TextEditingController edibilityController =
    TextEditingController(text: edibility);
    final TextEditingController growthRateController =
    TextEditingController(text: growthRate);
    final TextEditingController floweringSeasonController =
    TextEditingController(text: floweringSeason);
    final TextEditingController harvestTimeController =
    TextEditingController(text: harvestTime);
    final TextEditingController otherDetailsController =
    TextEditingController(text: otherDetails);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Inventory"),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: inventoryNameController,
                    decoration: const InputDecoration(
                        hintText: "Inventory Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: plantNameController,
                    decoration: const InputDecoration(hintText: "Plant Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: plantTypeController,
                    decoration: const InputDecoration(hintText: "Plant Type"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: plantPartController,
                    decoration: const InputDecoration(hintText: "Plant Part"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: scientificNameController,
                    decoration: const InputDecoration(
                        hintText: "Scientific Name"),
                  ),
                  TextField(
                    controller: familyController,
                    decoration: const InputDecoration(hintText: "Family"),
                  ),
                  TextField(
                    controller: sizeController,
                    decoration: const InputDecoration(hintText: "Size"),
                  ),
                  TextField(
                    controller: shapeController,
                    decoration: const InputDecoration(hintText: "Shape"),
                  ),
                  TextField(
                    controller: colorController,
                    decoration: const InputDecoration(hintText: "Color"),
                  ),
                  TextField(
                    controller: textureController,
                    decoration: const InputDecoration(hintText: "Texture"),
                  ),
                  TextField(
                    controller: growthHabitController,
                    decoration: const InputDecoration(hintText: "Growth Habit"),
                  ),
                  TextField(
                    controller: lifespanController,
                    decoration: const InputDecoration(hintText: "Lifespan"),
                  ),
                  TextField(
                    controller: nativeRegionController,
                    decoration: const InputDecoration(
                        hintText: "Native Region"),
                  ),
                  TextField(
                    controller: climateController,
                    decoration: const InputDecoration(hintText: "Climate"),
                  ),
                  TextField(
                    controller: soilPreferenceController,
                    decoration: const InputDecoration(
                        hintText: "Soil Preference"),
                  ),
                  TextField(
                    controller: sunlightRequirementsController,
                    decoration: const InputDecoration(
                        hintText: "Sunlight Requirements"),
                  ),
                  TextField(
                    controller: waterRequirementsController,
                    decoration: const InputDecoration(
                        hintText: "Water Requirements"),
                  ),
                  TextField(
                    controller: propagationMethodController,
                    decoration: const InputDecoration(
                        hintText: "Propagation Method"),
                  ),
                  TextField(
                    controller: medicinalPropertiesController,
                    decoration: const InputDecoration(
                        hintText: "Medicinal Properties"),
                  ),
                  TextField(
                    controller: culinaryUsesController,
                    decoration: const InputDecoration(
                        hintText: "Culinary Uses"),
                  ),
                  TextField(
                    controller: industrialUsesController,
                    decoration: const InputDecoration(
                        hintText: "Industrial Uses"),
                  ),
                  TextField(
                    controller: nutritionalValueController,
                    decoration: const InputDecoration(
                        hintText: "Nutritional Value"),
                  ),
                  TextField(
                    controller: pollinatorsController,
                    decoration: const InputDecoration(hintText: "Pollinators"),
                  ),
                  TextField(
                    controller: companionPlantingController,
                    decoration: const InputDecoration(
                        hintText: "Companion Planting"),
                  ),
                  TextField(
                    controller: pestResistanceController,
                    decoration: const InputDecoration(
                        hintText: "Pest Resistance"),
                  ),
                  TextField(
                    controller: edibilityController,
                    decoration: const InputDecoration(hintText: "Edibility"),
                  ),
                  TextField(
                    controller: growthRateController,
                    decoration: const InputDecoration(hintText: "Growth Rate"),
                  ),
                  TextField(
                    controller: floweringSeasonController,
                    decoration: const InputDecoration(
                        hintText: "Flowering Season"),
                  ),
                  TextField(
                    controller: harvestTimeController,
                    decoration: const InputDecoration(hintText: "Harvest Time"),
                  ),
                  TextField(
                    controller: otherDetailsController,
                    decoration: const InputDecoration(
                        hintText: "Other Details"),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Update the inventory data in Firestore
                await FirebaseFirestore.instance
                    .collection('inventories')
                    .doc(widget.inventoryId)
                    .update({
                  'inventoryName': inventoryNameController.text.trim(),
                  'plantName': plantNameController.text.trim(),
                  'plantType': plantTypeController.text.trim(),
                  'plantPart': plantPartController.text.trim(),
                  'scientificName': scientificNameController.text.trim(),
                  'family': familyController.text.trim(),
                  'size': sizeController.text.trim(),
                  'shape': shapeController.text.trim(),
                  'color': colorController.text.trim(),
                  'texture': textureController.text.trim(),
                  'growthHabit': growthHabitController.text.trim(),
                  'lifespan': lifespanController.text.trim(),
                  'nativeRegion': nativeRegionController.text.trim(),
                  'climate': climateController.text.trim(),
                  'soilPreference': soilPreferenceController.text.trim(),
                  'sunlightRequirements': sunlightRequirementsController.text
                      .trim(),
                  'waterRequirements': waterRequirementsController.text.trim(),
                  'propagationMethod': propagationMethodController.text.trim(),
                  'medicinalProperties': medicinalPropertiesController.text
                      .trim(),
                  'culinaryUses': culinaryUsesController.text.trim(),
                  'industrialUses': industrialUsesController.text.trim(),
                  'nutritionalValue': nutritionalValueController.text.trim(),
                  'pollinators': pollinatorsController.text.trim(),
                  'companionPlanting': companionPlantingController.text.trim(),
                  'pestResistance': pestResistanceController.text.trim(),
                  'edibility': edibilityController.text.trim(),
                  'growthRate': growthRateController.text.trim(),
                  'floweringSeason': floweringSeasonController.text.trim(),
                  'harvestTime': harvestTimeController.text.trim(),
                  'otherDetails': otherDetailsController.text.trim(),
                });

                // Update the local state
                setState(() {
                  inventoryName = inventoryNameController.text.trim();
                  plantName = plantNameController.text.trim();
                  plantType = plantTypeController.text.trim();
                  plantPart = plantPartController.text.trim();
                  scientificName = scientificNameController.text.trim();
                  family = familyController.text.trim();
                  size = sizeController.text.trim();
                  shape = shapeController.text.trim();
                  color = colorController.text.trim();
                  texture = textureController.text.trim();
                  growthHabit = growthHabitController.text.trim();
                  lifespan = lifespanController.text.trim();
                  nativeRegion = nativeRegionController.text.trim();
                  climate = climateController.text.trim();
                  soilPreference = soilPreferenceController.text.trim();
                  sunlightRequirements =
                      sunlightRequirementsController.text.trim();
                  waterRequirements = waterRequirementsController.text.trim();
                  propagationMethod = propagationMethodController.text.trim();
                  medicinalProperties =
                      medicinalPropertiesController.text.trim();
                  culinaryUses = culinaryUsesController.text.trim();
                  industrialUses = industrialUsesController.text.trim();
                  nutritionalValue = nutritionalValueController.text.trim();
                  pollinators = pollinatorsController.text.trim();
                  companionPlanting = companionPlantingController.text.trim();
                  pestResistance = pestResistanceController.text.trim();
                  edibility = edibilityController.text.trim();
                  growthRate = growthRateController.text.trim();
                  floweringSeason = floweringSeasonController.text.trim();
                  harvestTime = harvestTimeController.text.trim();
                  otherDetails = otherDetailsController.text.trim();
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Inventory updated successfully")),
                );
              },
              child: const Text("Update"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _deleteInventory() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text(
              "Are you sure you want to delete this inventory?"),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('inventories')
                    .doc(widget.inventoryId)
                    .delete();

                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Inventory deleted successfully")),
                );
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(int index) {
    final TextEditingController descriptionController =
    TextEditingController(text: itemDetailsList[index]['description']);
    String selectedStatus = itemDetailsList[index]['status'];
    bool isLoading = false; // Track loading state
    List<File?> pickedImages = [null, null,null,null]; // Store up to 4 picked images temporarily

    // List of status options
    final List<String> statusOptions = ['healthy', 'unhealthy'];

    // Function to pick an image (from gallery or camera)
    Future<void> _pickImage(ImageSource source, int imageIndex, StateSetter setStateDialog) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setStateDialog(() {
          pickedImages[imageIndex] = File(image.path); // Store the picked image temporarily
        });
      }
    }

    // Function to show a dialog for choosing the image source
    Future<void> _showImageSourceDialog(int imageIndex, StateSetter setStateDialog) async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Select Image Source"),
            content: const Text("Choose where to pick the image from:"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _pickImage(ImageSource.gallery, imageIndex, setStateDialog); // Pick from gallery
                },
                child: const Text("Gallery"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _pickImage(ImageSource.camera, imageIndex, setStateDialog); // Pick from camera
                },
                child: const Text("Camera"),
              ),
            ],
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text("Edit Item ${itemDetailsList[index]['originalIndex'] + 1}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    // Two boxes for uploading images
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // First image box
                        GestureDetector(
                          onTap: isLoading
                              ? null // Disable tap while loading
                              : () async {
                            await _showImageSourceDialog(0, setStateDialog); // Show dialog to choose image source
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3), // Add shadow for modern look
                                ),
                              ],
                              color: Colors.grey[200], // Light grey background
                            ),
                            child: pickedImages[0] != null // Show picked image if available
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                pickedImages[0]!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : itemDetailsList[index]['imageUrl1'].isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                itemDetailsList[index]['imageUrl1'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        // Second image box
                        GestureDetector(
                          onTap: isLoading
                              ? null // Disable tap while loading
                              : () async {
                            await _showImageSourceDialog(1, setStateDialog); // Show dialog to choose image source
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3), // Add shadow for modern look
                                ),
                              ],
                              color: Colors.grey[200], // Light grey background
                            ),
                            child: pickedImages[1] != null // Show picked image if available
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                pickedImages[1]!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : itemDetailsList[index]['imageUrl2'].isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                itemDetailsList[index]['imageUrl2'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // First image box
                        GestureDetector(
                          onTap: isLoading
                              ? null // Disable tap while loading
                              : () async {
                            await _showImageSourceDialog(2, setStateDialog); // Show dialog to choose image source
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3), // Add shadow for modern look
                                ),
                              ],
                              color: Colors.grey[200], // Light grey background
                            ),
                            child: pickedImages[2] != null // Show picked image if available
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                pickedImages[2]!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : itemDetailsList[index]['imageUrl3'].isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                itemDetailsList[index]['imageUrl3'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        // Second image box
                        GestureDetector(
                          onTap: isLoading
                              ? null // Disable tap while loading
                              : () async {
                            await _showImageSourceDialog(3, setStateDialog); // Show dialog to choose image source
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3), // Add shadow for modern look
                                ),
                              ],
                              color: Colors.grey[200], // Light grey background
                            ),
                            child: pickedImages[3] != null // Show picked image if available
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                pickedImages[3]!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : itemDetailsList[index]['imageUrl4'].isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                itemDetailsList[index]['imageUrl4'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Radio buttons for status (ToggleButtons in modern chip format)
                    ToggleButtons(
                      isSelected: statusOptions.map((status) => status == selectedStatus).toList(),
                      onPressed: (int selectedIndex) {
                        setStateDialog(() {
                          selectedStatus = statusOptions[selectedIndex]; // Update the selected status
                        });
                      },
                      borderColor: Colors.transparent, // Remove outer border
                      selectedBorderColor: Colors.transparent, // Remove outer border when selected
                      fillColor: Colors.transparent, // Remove fill color
                      renderBorder: false, // Disable rendering of the outer border
                      children: statusOptions.map((status) {
                        return Material(
                          color: Colors.transparent, // Ensure the Material widget doesn't add background color
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20), // Match the button's rounded corners
                            onTap: () {
                              setStateDialog(() {
                                selectedStatus = status; // Update the selected status
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                                color: selectedStatus == status
                                    ? status == 'healthy'
                                    ? Colors.lightGreen.withOpacity(0.3) // Light green for healthy
                                    : Colors.redAccent.withOpacity(0.3) // Light red for unhealthy
                                    : Colors.transparent, // Transparent when not selected
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2), // Add shadow for modern look
                                  ),
                                ],
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: selectedStatus == status
                                      ? status == 'healthy'
                                      ? Colors.green[800] // Dark green text for healthy
                                      : Colors.red[800] // Dark red text for unhealthy
                                      : Colors.grey, // Grey text when not selected
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Text field for description (taller and multiline)
                    SizedBox(
                      height: 150, // Set a fixed height for the text field
                      child: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          hintText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          contentPadding: const EdgeInsets.all(16), // Add padding inside the text field
                        ),
                        maxLines: null, // Allow unlimited lines
                        expands: true, // Make the text field grow dynamically
                        keyboardType: TextInputType.multiline, // Enable multiline input
                        textAlignVertical: TextAlignVertical.top, // Align text to the top
                        enabled: !isLoading, // Disable text field while loading
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    TextButton(
                      onPressed: isLoading
                          ? null // Disable button while loading
                          : () async {
                        setStateDialog(() {
                          isLoading = true; // Start loading
                        });

                        // Upload the images if new ones were picked
                        String? imageUrl1 = itemDetailsList[index]['imageUrl1'];
                        String? imageUrl2 = itemDetailsList[index]['imageUrl2'];
                        String? imageUrl3 = itemDetailsList[index]['imageUrl3'];
                        String? imageUrl4 = itemDetailsList[index]['imageUrl4'];

                        if (pickedImages[0] != null) {
                          final String fileName = 'item_${widget.inventoryId}_${index}_1.jpg';
                          final Reference storageRef =
                          FirebaseStorage.instance.ref().child('item_images/$fileName');

                          // Upload the file
                          await storageRef.putFile(pickedImages[0]!);

                          // Get the download URL
                          imageUrl1 = await storageRef.getDownloadURL();
                        }

                        if (pickedImages[1] != null) {
                          final String fileName = 'item_${widget.inventoryId}_${index}_2.jpg';
                          final Reference storageRef =
                          FirebaseStorage.instance.ref().child('item_images/$fileName');

                          // Upload the file
                          await storageRef.putFile(pickedImages[1]!);

                          // Get the download URL
                          imageUrl2 = await storageRef.getDownloadURL();
                        }

                        if (pickedImages[2] != null) {
                          final String fileName = 'item_${widget.inventoryId}_${index}_3.jpg';
                          final Reference storageRef =
                          FirebaseStorage.instance.ref().child('item_images/$fileName');

                          // Upload the file
                          await storageRef.putFile(pickedImages[2]!);

                          // Get the download URL
                          imageUrl3 = await storageRef.getDownloadURL();
                        }

                        if (pickedImages[3] != null) {
                          final String fileName = 'item_${widget.inventoryId}_${index}_4.jpg';
                          final Reference storageRef =
                          FirebaseStorage.instance.ref().child('item_images/$fileName');

                          // Upload the file
                          await storageRef.putFile(pickedImages[3]!);

                          // Get the download URL
                          imageUrl4 = await storageRef.getDownloadURL();
                        }

                        // Update the item's image URLs
                        itemDetailsList[index]['imageUrl1'] = imageUrl1;
                        itemDetailsList[index]['imageUrl2'] = imageUrl2;
                        itemDetailsList[index]['imageUrl3'] = imageUrl3;
                        itemDetailsList[index]['imageUrl4'] = imageUrl4;
                        itemDetailsList[index]['status'] = selectedStatus;
                        itemDetailsList[index]['description'] = descriptionController.text.trim();
                        itemDetailsList[index]['lastModified'] = DateTime.now().toIso8601String();

                        // Update Firestore
                        await _updateFirestoreItems();

                        setStateDialog(() {
                          isLoading = false; // Stop loading
                        });

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Item updated successfully")),
                        );
                      },
                      child: const Text("Update"),
                    ),
                    if (isLoading) // Show loading indicator if isLoading is true
                      const CircularProgressIndicator(),
                  ],
                ),
                TextButton(
                  onPressed: isLoading
                      ? null // Disable button while loading
                      : () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _increaseQuantity() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Increase"),
          content: const Text(
              "Are you sure you want to increase the quantity by 1?"),
          actions: [
            TextButton(
              onPressed: () async {
                // Update the quantity in Firestore
                await FirebaseFirestore.instance
                    .collection('inventories')
                    .doc(widget.inventoryId)
                    .update({
                  'quantity': quantity + 1,
                });

                // Add a new item to the list with the correct originalIndex
                setState(() {
                  quantity++;
                  itemDetailsList.add({
                    'originalIndex': quantity - 1,
                    // Set the originalIndex to the new item's position
                    'status': 'healthy',
                    // Default status
                    'description': '',
                    // Default description
                    'imageUrl': '',
                    'lastModified': DateTime.now().toIso8601String(),
                  });
                });

                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Quantity increased successfully")),
                );
              },
              child: const Text("Increase"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _sortItems(String sortBy) {
    setState(() {
      if (sortBy == 'name') {
        itemDetailsList.sort((a, b) =>
            a['description'].compareTo(b['description']));
      } else if (sortBy == 'date') {
        itemDetailsList.sort((a, b) =>
            b['lastModified'].compareTo(a['lastModified']));
      }
    });
  }

// Function to show a full-screen, zoomable image with a Back button
  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Make the background transparent
          insetPadding: EdgeInsets.zero, // Remove padding
          child: Stack(
            children: [
              // Full-screen image
              PhotoView(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent, // Make the background transparent
                ),
              ),
              // Back button at the bottom
              Positioned(
                bottom: 20, // Position the button at the bottom
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54, // Semi-transparent black
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show the description in a popup
  void _showDescriptionPopup(String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Description"),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showDecomposeDialog(int index) {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController purposeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Decompose Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: "Reason for decomposition",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: purposeController,
                decoration: const InputDecoration(
                  hintText: "Purpose of decomposition",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final String reason = reasonController.text.trim();
                final String purpose = purposeController.text.trim();

                if (reason.isNotEmpty && purpose.isNotEmpty) {
                  // Update the item's decomposition details
                  setState(() {
                    itemDetailsList[index]['decomposed'] = true;
                    itemDetailsList[index]['decompositionReason'] = reason;
                    itemDetailsList[index]['decompositionPurpose'] = purpose;
                    itemDetailsList[index]['lastModified'] = DateTime.now().toIso8601String();
                  });

                  // Update Firestore
                  await _updateFirestoreItems();

                  // Add the decomposed item to the "decomposed_plants" collection
                  await FirebaseFirestore.instance.collection('decomposed_plants').add({
                    'inventoryName': inventoryName,
                    'plantName': plantName,
                    'plantType': plantType,
                    'plantPart': plantPart,
                    'description': itemDetailsList[index]['description'],
                    'imageUrl1': itemDetailsList[index]['imageUrl1'],
                    'imageUrl2': itemDetailsList[index]['imageUrl2'],
                    'imageUrl3': itemDetailsList[index]['imageUrl3'],
                    'imageUrl4': itemDetailsList[index]['imageUrl4'],
                    'decompositionReason': reason,
                    'decompositionPurpose': purpose,
                    'decomposedBy': "Current User", // Replace with actual user data
                    'decomposedDate': DateTime.now().toIso8601String(),
                    'originalIndex': itemDetailsList[index]['originalIndex'], // Ensure this is included
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Item decomposed successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in both fields")),
                  );
                }
              },
              child: const Text("Decompose"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showDecompositionDetailsDialog(int index) {
    final item = itemDetailsList[index];
    bool showOtherDetails = false; // Track if "Other Details" is expanded

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text("Decomposition Details"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Plant Name: $plantName"),
                    const SizedBox(height: 8),
                    Text("Plant Type: $plantType"),
                    const SizedBox(height: 8),
                    Text("Plant Part: $plantPart"),
                    const SizedBox(height: 16),
                    Text("Reason for Decomposition: ${item['decompositionReason']}"),
                    const SizedBox(height: 8),
                    Text("Purpose of Decomposition: ${item['decompositionPurpose']}"),
                    const SizedBox(height: 16),
                    Text("Description: ${item['description']}"),
                    const SizedBox(height: 16),
                    // Button to toggle "Other Details"
                    ElevatedButton(
                      onPressed: () {
                        setStateDialog(() {
                          showOtherDetails = !showOtherDetails; // Toggle visibility
                        });
                      },
                      child: Text(showOtherDetails ? "Hide Other Details" : "Show Other Details"),
                    ),
                    if (showOtherDetails) ...[
                      const SizedBox(height: 16),
                      Text("Scientific Name: $scientificName"),
                      const SizedBox(height: 8),
                      Text("Family: $family"),
                      const SizedBox(height: 8),
                      Text("Size: $size"),
                      const SizedBox(height: 8),
                      Text("Shape: $shape"),
                      const SizedBox(height: 8),
                      Text("Color: $color"),
                      const SizedBox(height: 8),
                      Text("Texture: $texture"),
                      const SizedBox(height: 8),
                      Text("Growth Habit: $growthHabit"),
                      const SizedBox(height: 8),
                      Text("Lifespan: $lifespan"),
                      const SizedBox(height: 8),
                      Text("Native Region: $nativeRegion"),
                      const SizedBox(height: 8),
                      Text("Climate: $climate"),
                      const SizedBox(height: 8),
                      Text("Soil Preference: $soilPreference"),
                      const SizedBox(height: 8),
                      Text("Sunlight Requirements: $sunlightRequirements"),
                      const SizedBox(height: 8),
                      Text("Water Requirements: $waterRequirements"),
                      const SizedBox(height: 8),
                      Text("Propagation Method: $propagationMethod"),
                      const SizedBox(height: 8),
                      Text("Medicinal Properties: $medicinalProperties"),
                      const SizedBox(height: 8),
                      Text("Culinary Uses: $culinaryUses"),
                      const SizedBox(height: 8),
                      Text("Industrial Uses: $industrialUses"),
                      const SizedBox(height: 8),
                      Text("Nutritional Value: $nutritionalValue"),
                      const SizedBox(height: 8),
                      Text("Pollinators: $pollinators"),
                      const SizedBox(height: 8),
                      Text("Companion Planting: $companionPlanting"),
                      const SizedBox(height: 8),
                      Text("Pest Resistance: $pestResistance"),
                      const SizedBox(height: 8),
                      Text("Edibility: $edibility"),
                      const SizedBox(height: 8),
                      Text("Growth Rate: $growthRate"),
                      const SizedBox(height: 8),
                      Text("Flowering Season: $floweringSeason"),
                      const SizedBox(height: 8),
                      Text("Harvest Time: $harvestTime"),
                      const SizedBox(height: 8),
                      Text("Other Details: $otherDetails"),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plantName),
        actions: [
          // Sort Button
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Sort Items"),
                    content: const Text("Sort items by name or date added?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _sortItems('name');
                          Navigator.of(context).pop();
                        },
                        child: const Text("Sort by Name"),
                      ),
                      TextButton(
                        onPressed: () {
                          _sortItems('date');
                          Navigator.of(context).pop();
                        },
                        child: const Text("Sort by Date"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.sort),
          ),
          // Increase Quantity Button
          IconButton(
            onPressed: _increaseQuantity,
            icon: const Icon(Icons.add),
          ),
          // Edit Inventory Button
          IconButton(
            onPressed: _showEditInventoryDialog,
            icon: const Icon(Icons.edit_note_outlined),
          ),
          // Delete Inventory Button
          IconButton(
            onPressed: _deleteInventory,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Fetch the latest item details from Firestore
          await _fetchItemDetails();
        },
        child:ListView.builder(
          itemCount: quantity,
          itemBuilder: (context, index) {
            final item = itemDetailsList[index];
            final hasPhotos =
                item['imageUrl1'].isNotEmpty ||
                    item['imageUrl2'].isNotEmpty ||
                    item['imageUrl3'].isNotEmpty ||
                    item['imageUrl4'].isNotEmpty;
            final isDecomposed = item['decomposed'] ?? false;

            // Format the lastModified timestamp
            final lastModified = DateTime.parse(item['lastModified']);
            final formattedDate = DateFormat('MM/dd/yyyy - hh:mm a').format(lastModified);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDecomposed
                  ? Colors.grey[300] // Grey background for decomposed items
                  : item['status'] == 'healthy'
                  ? Colors.lightGreen[100]
                  : Colors.red[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: hasPhotos
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item number, status, and edit icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Item ${item['originalIndex'] + 1} | ${isDecomposed ? "Decomposed" : "Status: ${item['status']}"}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Row(
                          children: [
                            if (hasPhotos && !isDecomposed) // Only show decompose button if not already decomposed
                              IconButton(
                                onPressed: () {
                                  _showDecomposeDialog(index);
                                },
                                icon: const Icon(Icons.delete_forever),
                              ),
                            IconButton(
                              onPressed: () {
                                _showEditItemDialog(index);
                              },
                              icon: const Icon(Icons.playlist_add_circle),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Display images in a row (if not decomposed)
                    if (!isDecomposed)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (item['imageUrl1'].isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _showFullScreenImage(item['imageUrl1']);
                              },
                              child: Image.network(
                                item['imageUrl1'],
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (item['imageUrl2'].isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _showFullScreenImage(item['imageUrl2']);
                              },
                              child: Image.network(
                                item['imageUrl2'],
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (item['imageUrl3'].isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _showFullScreenImage(item['imageUrl3']);
                              },
                              child: Image.network(
                                item['imageUrl3'],
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (item['imageUrl4'].isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _showFullScreenImage(item['imageUrl4']);
                              },
                              child: Image.network(
                                item['imageUrl4'],
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Description and last modified
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (isDecomposed) {
                              _showDecompositionDetailsDialog(index); // Show decomposition details
                            } else {
                              _showDescriptionPopup(item['description']); // Show plant description
                            }
                          },
                          icon: const Icon(Icons.description),
                        ),
                        const Text("|"),
                        const SizedBox(width: 8),
                        Text(
                          "Last Modified: $formattedDate",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Blank list, add info",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showEditItemDialog(index);
                      },
                      icon: const Icon(Icons.playlist_add_circle),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

