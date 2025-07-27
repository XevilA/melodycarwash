# 📚 Laundry Management System - REST API Documentation

## 🔧 System Architecture

### Firebase Services (Authentication & Account Management Only)
1. **Firebase Authentication** - User login/register
2. **Cloud Firestore** - User roles and vendor applications

### REST API (All Other Operations)
- Machine management
- Transaction processing
- Reports and analytics
- Settings management
- Data export/import

## 🌐 API Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'https://api.laundry-system.com/v1';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) {
    return {
      ...headers,
      'Authorization': 'Bearer $token',
    };
  }
}
```

## 🔑 Authentication Flow

### 1. Login Process
```
1. Firebase Auth → Email/Password login
2. Get Firebase ID Token
3. Send token to your API → /auth/validate-token
4. Receive API token for subsequent requests
```

### 2. Registration Process
```
1. Firebase Auth → Create account
2. Store role in Firestore
3. Create vendor application in Firestore
4. Admin approves → API creates vendor
```

## 📊 Firestore Collections (Limited Use)

### 1. `users` Collection
```json
{
  "email": "string",
  "role": "vendor|admin",
  "status": "pending|active|suspended",
  "createdAt": "timestamp",
  "approvedAt": "timestamp",
  "approvedBy": "adminUserId"
}
```

### 2. `vendor_applications` Collection
```json
{
  "name": "string",
  "email": "string",
  "storeName": "string",
  "phone": "string",
  "address": "string",
  "status": "pending|approved|rejected",
  "createdAt": "timestamp"
}
```

## 🔌 REST API Endpoints

### Authentication Endpoints

#### POST `/auth/validate-token`
Validate Firebase token and get API token
```json
Request:
{
  "firebaseUid": "string",
  "role": "vendor|admin"
}

Response:
{
  "apiToken": "string",
  "vendorData": {
    "id": "string",
    "name": "string",
    "storeName": "string"
  }
}
```

#### POST `/auth/logout`
Logout user
```json
Request:
{
  "userId": "string"
}

Response:
{
  "success": true
}
```

### Vendor Endpoints

#### POST `/vendors/register`
Register new vendor (called after Firebase account creation)
```json
Request:
{
  "firebaseUid": "string",
  "idToken": "string",
  "name": "string",
  "email": "string",
  "storeName": "string",
  "phone": "string",
  "address": "string"
}

Response:
{
  "vendorId": "string",
  "message": "Vendor registered successfully"
}
```

#### GET `/vendors/{vendorId}`
Get vendor details
```json
Response:
{
  "vendor": {
    "id": "string",
    "name": "string",
    "email": "string",
    "storeName": "string",
    "phone": "string",
    "status": "active|suspended",
    "machineCount": 10,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

### Machine Management Endpoints

#### GET `/machines/vendor/{vendorId}`
Get all machines for a vendor
```json
Response:
{
  "machines": [
    {
      "id": "string",
      "vendorId": "string",
      "machineNumber": 1,
      "type": "washer|dryer",
      "status": "available|active|maintenance",
      "currentProgram": "quick|normal|heavy|delicate",
      "remainingTime": 30,
      "startTime": "2024-01-01T10:00:00Z",
      "todayRevenue": 500,
      "prices": {
        "quick": 30,
        "normal": 40,
        "heavy": 50,
        "delicate": 45
      }
    }
  ]
}
```

#### POST `/machines/{machineId}/start`
Start a machine
```json
Request:
{
  "program": "quick|normal|heavy|delicate",
  "userId": "string"
}

Response:
{
  "transactionId": "string",
  "message": "Machine started successfully"
}
```

#### POST `/machines/{machineId}/stop`
Stop a machine
```json
Request:
{
  "userId": "string"
}

Response:
{
  "message": "Machine stopped successfully"
}
```

#### PUT `/machines/{machineId}/status`
Update machine status (maintenance toggle)
```json
Request:
{
  "status": "available|maintenance",
  "userId": "string"
}

Response:
{
  "message": "Machine status updated"
}
```

### Transaction Endpoints

#### GET `/transactions/vendor/{vendorId}`
Get transactions for a vendor
```json
Query Parameters:
- date: YYYY-MM-DD (optional)
- startDate: YYYY-MM-DD (optional)
- endDate: YYYY-MM-DD (optional)

Response:
{
  "transactions": [
    {
      "id": "string",
      "machineId": "string",
      "machineNumber": 1,
      "machineType": "washer",
      "program":
