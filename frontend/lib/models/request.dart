class Request {
  final String id;
  // Assume serviceType name is fetched directly or derived
  final String serviceType;
  final String status; // Comes as String from API, e.g., "PENDING"
  // Assume location address is fetched directly or derived
  final String locationAddress;
  final DateTime createdAt;

  Request({
    required this.id,
    required this.serviceType,
    required this.status,
    required this.locationAddress,
    required this.createdAt,
  });

  // Factory constructor to create a Request object from JSON
  // Adjust based on your actual API response structure for requests
  factory Request.fromJson(
    Map<String, dynamic> json,
    Map<int, String> serviceTypeMap,
  ) {
    // --- Adjusted Parsing ---
    // Example: Assuming API returns full serviceType object
    // {
    //   "id": "req1",
    //   "serviceType": { "id": 1, "name": "Tire Change" },
    //   "location": { "address": "123 Main St" },
    //   "status": "PENDING",
    //   "createdAt": "2023-10-27T10:00:00Z"
    // }

    String serviceName =
        json['serviceType']?['name'] as String? ?? 'Unknown Service';
    // Or if it just returns serviceTypeId and you want to use the map (though you said not to fetch map):
    // int serviceTypeId = json['serviceTypeId'] as int?;
    // String serviceName = serviceTypeMap[serviceTypeId] ?? 'Unknown Service';

    String address =
        json['location']?['address'] as String? ?? 'Unknown Location';
    String rawStatus = json['status'] as String? ?? 'UNKNOWN';

    // Extract just the status name if it's an enum string like "RequestStatus.PENDING"
    String statusName = rawStatus.split('.').last;

    return Request(
      id: json['id'] as String,
      serviceType: serviceName,
      status: statusName,
      locationAddress: address,
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ), // Adjust format if needed by your API
    );
    // --- End Adjusted Parsing ---
  }

  // Optional: If your API structure is different and simpler (e.g., direct fields)
  // factory Request.fromJsonDirect(Map<String, dynamic> json) {
  //   return Request(
  //     id: json['id'],
  //     serviceType: json['serviceTypeName'] ?? 'Unknown Service', // If API provides name directly
  //     status: (json['status'] as String?)?.split('.')?.last ?? 'UNKNOWN',
  //     locationAddress: json['locationAddress'] ?? 'Unknown Location',
  //     createdAt: DateTime.parse(json['createdAt']),
  //   );
  // }
}
