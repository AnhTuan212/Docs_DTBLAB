# Backend Communication Architecture: Controller Layer

**Project:** AuraControl Spa Management System  
**Layer:** Controller Layer (HTTP Request Handling)  
**Date:** December 30, 2025

---

## TABLE OF CONTENTS
1. [Controller Layer Overview](#controller-layer-overview)
2. [How Controller Functions Receive Requests](#how-controller-functions-receive-requests)
3. [Data Mapping: DTO → Entity Flow](#data-mapping-dto--entity-flow)
4. [How Controller Calls Service Functions](#how-controller-calls-service-functions)
5. [Request Flow Diagram](#request-flow-diagram)
6. [Real-World Examples from AuraControl](#real-world-examples-from-auracontrol)
7. [HTTP Method Mapping](#http-method-mapping)

---

## CONTROLLER LAYER OVERVIEW

### What is the Controller Layer?

The **Controller Layer** is the first layer that receives HTTP requests from the frontend client (React SPA). It acts as the **entry point** to the backend application. The controller layer is responsible for:

1. **Receiving HTTP requests** from clients
2. **Parsing request data** (URL parameters, request body, headers)
3. **Validating input** using annotations like `@Valid`
4. **Mapping data** from DTOs (Data Transfer Objects) to internal representations
5. **Calling service layer functions** to execute business logic
6. **Formatting responses** and sending them back to the client

### Key Spring Boot Annotations Used

| Annotation | Purpose | Example |
|-----------|---------|---------|
| `@RestController` | Marks class as REST API controller | `@RestController public class BookingController` |
| `@RequestMapping` | Base URL path for all endpoints | `@RequestMapping("/api/booking")` |
| `@GetMapping` | Handles GET requests | `@GetMapping("/available-slots")` |
| `@PostMapping` | Handles POST requests | `@PostMapping` |
| `@PutMapping` | Handles PUT requests (updates) | `@PutMapping("/{id}")` |
| `@DeleteMapping` | Handles DELETE requests | `@DeleteMapping("/{id}")` |
| `@PatchMapping` | Handles PATCH requests (partial updates) | `@PatchMapping("/me/password")` |
| `@PathVariable` | Extracts ID from URL | `@PathVariable Integer id` |
| `@RequestParam` | Extracts query parameters | `@RequestParam int page` |
| `@RequestBody` | Maps JSON body to object | `@RequestBody BookingRequest request` |
| `@Valid` | Triggers validation | `@Valid BookingRequest request` |
| `@RequiredArgsConstructor` | Auto-generates constructor via Lombok | Dependency injection |

---

## HOW CONTROLLER FUNCTIONS RECEIVE REQUESTS

### Request Flow: From Browser to Controller

```
User Browser (React)
    ↓
HTTP Request (GET/POST/PUT/DELETE)
    ↓
Spring Boot DispatcherServlet (intercepts request)
    ↓
URL pattern matches @RequestMapping + @GetMapping/@PostMapping...
    ↓
Request Handler Adapter (identifies correct controller)
    ↓
Controller Function Executes
    ↓
Response sent back to browser
```

### Example: How BookingController Receives a Request

**Frontend sends request:**
```javascript
// React Frontend Code
axios.get('http://localhost:8081/api/booking/available-slots?serviceId=1&date=2025-10-20')
```

**Backend receives and processes:**
```java
// BookingController.java

@RestController
@RequestMapping("/api/booking")
@RequiredArgsConstructor
public class BookingController {
    private final AppointmentService appointmentService;

    @GetMapping("/available-slots")
    public ResponseEntity<?> getAvailableSlots(
            @RequestParam Integer serviceId,           // serviceId=1 from URL
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date  // date=2025-10-20
    ) {
        // Spring Boot automatically:
        // 1. Matches URL: /api/booking/available-slots
        // 2. Extracts serviceId=1 and date=2025-10-20 from query parameters
        // 3. Converts serviceId string "1" → Integer 1
        // 4. Converts date string "2025-10-20" → LocalDate object
        // 5. Passes values to this method
        
        List<String> slots = appointmentService.getAvailableSlots(serviceId, date);
        return ResponseEntity.ok(Map.of(
                "serviceId", serviceId,
                "date", date,
                "availableSlots", slots
        ));
    }
}
```

**What happened internally:**

| Step | What Spring Does | Result |
|------|------------------|--------|
| 1 | Receives HTTP GET request | URL: `/api/booking/available-slots?serviceId=1&date=2025-10-20` |
| 2 | Matches `@RequestMapping("/api/booking")` + `@GetMapping("/available-slots")` | Controller method identified |
| 3 | Extracts `@RequestParam Integer serviceId` | Converts string "1" → Integer 1 |
| 4 | Extracts `@RequestParam LocalDate date` with `@DateTimeFormat` | Converts "2025-10-20" → LocalDate object |
| 5 | Invokes the method | `getAvailableSlots(1, LocalDate.of(2025, 10, 20))` |

---

## DATA MAPPING: DTO → ENTITY FLOW

### What are DTOs?

**DTO = Data Transfer Object** — A lightweight class used to transfer data between layers without exposing internal Entity structure.

**Why DTOs?**
- ✅ Security: Don't expose all entity fields to frontend
- ✅ Decoupling: Frontend doesn't depend on entity structure
- ✅ Flexibility: Can transform data before sending
- ✅ Performance: Transfer only needed fields

### DTO Classes in AuraControl

```java
// DTO Example 1: BookingRequest (Frontend sends this)
public class BookingRequest {
    private Integer serviceId;
    private LocalDateTime startTime;
    private Integer technicianId;  // Can be null for auto-assign
}

// DTO Example 2: BookingResponseDto (Backend returns this)
@Data
@Builder
public class BookingResponseDto {
    private Integer id;
    private String serviceName;
    private LocalDateTime startTime;
    private Integer duration;
    private Integer serviceId;
    private String technicianName;
    private String status;
}

// Entity Example: Appointment (Internal database representation)
@Entity
@Table(name = "appointment")
public class Appointment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer appointmentId;

    @ManyToOne
    @JoinColumn(name = "customer_id")
    private Customer customer;

    @ManyToOne
    @JoinColumn(name = "technician_id")
    private Technician technician;

    @ManyToOne
    @JoinColumn(name = "service_id")
    private Service service;

    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String status;
    private BigDecimal finalPrice;
    private String noteText;
    // ... more fields
}
```

### Data Mapping Flow: Request → Processing → Response

```
Frontend (React)
    ↓
Sends JSON: {"serviceId": 1, "startTime": "2025-10-20T09:00:00", "technicianId": null}
    ↓
HTTP POST Request arrives at Controller
    ↓
Spring MVC Argument Resolver
    ↓
Deserializes JSON → BookingRequest DTO object
    ↓
@Valid validation (if present)
    ↓
Controller calls Service with DTO
    ↓
Service converts DTO → Entity (Appointment)
    ↓
Repository saves Entity to Database
    ↓
Service returns Entity
    ↓
Controller converts Entity → ResponseDTO
    ↓
Serializes ResponseDTO to JSON
    ↓
HTTP 200 OK + JSON Response
    ↓
Frontend (React) receives and displays data
```

### Real DTO Mapping Example from AuraControl

```java
// Controller receives DTO
@PostMapping
public ResponseEntity<?> createBooking(@RequestBody @Valid BookingRequest request) {
    // request is a BookingRequest DTO
    
    // Pass DTO to Service
    Appointment newAppointment = appointmentService.createAppointment(request);
    // Service converts DTO → Entity internally
    
    // Return as response
    return ResponseEntity.ok(Map.of(
            "message", "Booking successfully created!",
            "appointmentId", newAppointment.getAppointmentId(),
            "status", newAppointment.getStatus(),
            "startTime", newAppointment.getStartTime()
    ));
}

// Service receives DTO and converts to Entity
@Transactional(rollbackFor = Exception.class)
public Appointment createAppointment(BookingRequest request) {
    // DTO → Entity conversion happens here
    
    Appointment appointment = new Appointment();
    appointment.setCustomer(customer);
    appointment.setTechnician(technician);
    appointment.setService(service);
    appointment.setStartTime(request.getStartTime());  // DTO field
    appointment.setEndTime(endTime);
    appointment.setStatus("CONFIRMED");
    
    // Save Entity to database
    return appointmentRepository.save(appointment);
}
```

---

## HOW CONTROLLER CALLS SERVICE FUNCTIONS

### Dependency Injection Pattern

Controllers don't instantiate services directly. Instead, Spring Boot **injects** dependencies using constructor injection.

```java
@RestController
@RequestMapping("/api/booking")
@RequiredArgsConstructor  // Lombok generates constructor
public class BookingController {
    // Spring Boot automatically injects this
    private final AppointmentService appointmentService;
    
    // Lombok generates:
    // public BookingController(AppointmentService appointmentService) {
    //     this.appointmentService = appointmentService;
    // }
}
```

### How Controller → Service Communication Works

```
1. HTTP Request arrives at Controller method
    ↓
2. Spring MVC processes request (extracts parameters, validates)
    ↓
3. Controller method body executes
    ↓
4. Controller calls injected service method
    ↓
5. Service executes business logic
    ↓
6. Service returns result to Controller
    ↓
7. Controller formats response
    ↓
8. Response sent to client
```

### Example: Controller Calling Multiple Service Methods

```java
@PostMapping
public ResponseEntity<?> createBooking(@RequestBody @Valid BookingRequest request) {
    // Step 1: Call service method 1 - validate service exists
    Appointment newAppointment = appointmentService.createAppointment(request);
    
    // Step 2: The response is wrapped in ResponseEntity
    return ResponseEntity.ok(Map.of(
            "message", "Booking successfully created!.",
            "appointmentId", newAppointment.getAppointmentId(),
            "status", newAppointment.getStatus(),
            "startTime", newAppointment.getStartTime()
    ));
}
```

### Key Point: Service is Injected, Not Created

```java
// ❌ WRONG - Don't do this
public class BookingController {
    public ResponseEntity<?> createBooking(BookingRequest request) {
        AppointmentService service = new AppointmentService();  // ❌ Wrong!
        service.createAppointment(request);
    }
}

// ✅ CORRECT - Use dependency injection
@RestController
public class BookingController {
    private final AppointmentService appointmentService;  // ✅ Injected
    
    public BookingController(AppointmentService appointmentService) {
        this.appointmentService = appointmentService;  // ✅ Injected by Spring
    }
    
    public ResponseEntity<?> createBooking(BookingRequest request) {
        appointmentService.createAppointment(request);  // ✅ Correct!
    }
}
```

---

## REQUEST FLOW DIAGRAM

### Complete Request Processing Flow in AuraControl

```
┌─────────────────────────────────────────────────────────────────┐
│ FRONTEND (React Browser)                                        │
│ User clicks "Book Appointment"                                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ axios.post('/api/booking', 
                         │   {serviceId: 1, startTime: "2025-10-20T09:00"})
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│ NETWORK                                                         │
│ HTTP POST Request sent over TCP/IP                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│ SPRING BOOT SERVER (Port 8081)                                  │
│                                                                 │
│ DispatcherServlet (receives request)                            │
│   ↓                                                             │
│ HandlerMapping (matches URL pattern)                            │
│   ↓ Matches: POST /api/booking                                 │
│ Finds: BookingController.createBooking()                        │
│   ↓                                                             │
│ ArgumentResolver                                               │
│   ↓ Deserializes JSON body                                     │
│   ↓ Parses @RequestBody @Valid BookingRequest                 │
│   ↓ Validates annotations                                      │
│   ↓ Creates BookingRequest object                              │
│   ↓                                                             │
│ Controller Invocation                                          │
│   ├─→ BookingController.createBooking(request)                │
│   │                                                             │
│   ├─→ Line 1: appointmentService.createAppointment(request)   │
│   │   (calls Service Layer)                                    │
│   │                                                             │
│   └─→ Line 2: return ResponseEntity.ok(...)                   │
│       (formats response)                                       │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ (Response generation continues in Service Layer)
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│ RESPONSE GENERATION                                             │
│                                                                 │
│ MessageConverter (Jackson ObjectMapper)                         │
│   ↓ Converts response object to JSON                           │
│   ↓ Serializes: {"message": "...", "appointmentId": 1, ...}  │
│   ↓                                                             │
│ HttpServletResponse                                            │
│   ↓ Sets status: 200 OK                                       │
│   ↓ Sets headers: Content-Type: application/json              │
│   ↓ Writes body: JSON string                                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ HTTP 200 OK + JSON Response
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│ FRONTEND (React Browser)                                        │
│ Response received and parsed by axios                           │
│ React state updated                                             │
│ UI re-renders with success message                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## REAL-WORLD EXAMPLES FROM AURACONTROL

### Example 1: Simple GET Request (No Request Body)

```java
// REQUEST: GET /api/services/active?page=0&size=5

@RestController
@RequestMapping("/api/services")
public class ServiceController {
    private final ServiceService serviceService;

    @GetMapping("/active")
    public ResponseEntity<Page<ServiceBookingResponse>> getActiveServices(
            @RequestParam(defaultValue = "0") int page,    // From ?page=0
            @RequestParam(defaultValue = "5") int size     // From ?size=5
    ) {
        // Spring Boot automatically:
        // 1. Extracts page=0 from URL
        // 2. Extracts size=5 from URL
        // 3. If not provided, uses default values (0, 5)
        // 4. Passes to method

        Page<ServiceBookingResponse> result = serviceService.getServicesForBooking(page, size);
        return ResponseEntity.ok(result);
    }
}
```

**Flow:**
```
Browser: GET /api/services/active?page=0&size=5
    ↓
Spring extracts page=0, size=5
    ↓
Calls: getActiveServices(0, 5)
    ↓
serviceService.getServicesForBooking(0, 5)
    ↓
Returns Page<ServiceBookingResponse>
    ↓
ResponseEntity.ok() wraps response
    ↓
Jackson converts to JSON
    ↓
HTTP 200 OK + JSON
    ↓
Browser receives data
```

### Example 2: POST Request with JSON Body

```java
// REQUEST: POST /api/booking
// BODY: {
//   "serviceId": 1,
//   "startTime": "2025-10-20T09:00:00",
//   "technicianId": 5
// }

@RestController
@RequestMapping("/api/booking")
public class BookingController {
    private final AppointmentService appointmentService;

    @PostMapping
    public ResponseEntity<?> createBooking(
            @RequestBody @Valid BookingRequest request  // JSON body deserialized here
    ) {
        // Spring Boot automatically:
        // 1. Reads HTTP request body
        // 2. Jackson deserializes JSON → BookingRequest object
        // 3. @Valid triggers validation (checks @NotNull, @Min, etc.)
        // 4. If validation fails: 400 Bad Request
        // 5. If validation passes: method executes

        Appointment newAppointment = appointmentService.createAppointment(request);
        
        return ResponseEntity.ok(Map.of(
                "message", "Booking successfully created!",
                "appointmentId", newAppointment.getAppointmentId(),
                "status", newAppointment.getStatus(),
                "startTime", newAppointment.getStartTime()
        ));
    }
}

// DTO that receives the JSON
public class BookingRequest {
    private Integer serviceId;
    private LocalDateTime startTime;
    private Integer technicianId;
}
```

**Data Mapping Process:**
```
JSON String (from network):
{
  "serviceId": 1,
  "startTime": "2025-10-20T09:00:00",
  "technicianId": 5
}
    ↓
Jackson ObjectMapper deserialization
    ↓
BookingRequest object created:
{
  serviceId = 1,
  startTime = LocalDateTime(2025, 10, 20, 9, 0),
  technicianId = 5
}
    ↓
@Valid annotation validation
    ↓
Method receives BookingRequest object
    ↓
Pass to Service layer
```

### Example 3: PUT Request with Path Variable

```java
// REQUEST: PUT /api/admin/resources/5
// BODY: {
//   "name": "Room A Updated",
//   "type": "ROOM"
// }

@RestController
@RequestMapping("/api/admin/resources")
public class AdminResourceController {
    private final AdminResourceService adminResourceService;

    @PutMapping("/{id}")
    public ResponseEntity<Resource> updateResource(
            @PathVariable Integer id,                    // 5 from /api/admin/resources/5
            @RequestBody @Valid ResourceDto request      // JSON body
    ) {
        // Spring Boot extracts:
        // 1. Path variable: id = 5 (from /5)
        // 2. Request body: ResourceDto object
        
        return ResponseEntity.ok(adminResourceService.updateResource(id, request));
    }
}
```

**Flow:**
```
Request URL: PUT /api/admin/resources/5

Spring URL pattern matching:
@PutMapping("/{id}") matches /api/admin/resources/5
    ↓
Extracts @PathVariable: id = 5 (converted String → Integer)
    ↓
Deserializes JSON body → ResourceDto
    ↓
Calls: updateResource(5, ResourceDto)
    ↓
Service processes
    ↓
Returns updated Resource entity
    ↓
ResponseEntity.ok() wraps it
    ↓
HTTP 200 OK + JSON
```

### Example 4: DELETE Request with Path Variable

```java
// REQUEST: DELETE /api/admin/resources/5

@RestController
@RequestMapping("/api/admin/resources")
public class AdminResourceController {
    private final AdminResourceService adminResourceService;

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteResource(@PathVariable Integer id) {
        adminResourceService.deleteResource(id);
        return ResponseEntity.noContent().build();  // 204 No Content
    }
}
```

**Response:**
```
DELETE /api/admin/resources/5
    ↓
Spring extracts id=5
    ↓
Calls: adminResourceService.deleteResource(5)
    ↓
Service deletes from database
    ↓
ResponseEntity.noContent() = HTTP 204
    ↓
Response sent (no JSON body, just status code)
```

---

## HTTP METHOD MAPPING

### Complete HTTP Method → Spring Annotation Mapping

| HTTP Method | Spring Annotation | Use Case | Example from AuraControl |
|------------|------------------|----------|-------------------------|
| **GET** | `@GetMapping` | Retrieve data | `GET /api/services/active` - Get active services |
| **GET** | `@GetMapping` | Retrieve by ID | `GET /api/admin/resources/{id}` - Get resource details |
| **GET** | `@GetMapping` | Search/Filter | `GET /api/admin/customers?keyword=Nguyen` - Search customers |
| **POST** | `@PostMapping` | Create new record | `POST /api/booking` - Create appointment |
| **POST** | `@PostMapping` | Create new record | `POST /api/admin/resources` - Create resource |
| **PUT** | `@PutMapping` | Update entire record | `PUT /api/admin/services/{id}` - Update service |
| **PUT** | `@PutMapping` | Update entire record | `PUT /api/admin/resources/{id}` - Update resource |
| **PATCH** | `@PatchMapping` | Partial update | `PATCH /api/users/me/password` - Change password |
| **DELETE** | `@DeleteMapping` | Delete record | `DELETE /api/admin/services/{id}` - Delete service |

### Response Types

```java
// 1. ResponseEntity with data (200 OK)
return ResponseEntity.ok(data);
// HTTP 200 OK
// Body: JSON serialized data

// 2. ResponseEntity with created (201 Created)
return new ResponseEntity<>(newService, HttpStatus.CREATED);
// HTTP 201 Created
// Body: JSON of created resource

// 3. ResponseEntity no content (204 No Content)
return ResponseEntity.noContent().build();
// HTTP 204 No Content
// Body: empty

// 4. ResponseEntity with custom status
return ResponseEntity.status(HttpStatus.CREATED).body(newResource);
// HTTP 201 Created
// Body: JSON

// 5. ResponseEntity accepted (202 Accepted)
return ResponseEntity.accepted().build();
// HTTP 202 Accepted
```

---

## SUMMARY: CONTROLLER LAYER COMMUNICATION

### Key Points

1. **Entry Point**: Controllers receive HTTP requests via Spring's DispatcherServlet
2. **URL Routing**: `@RequestMapping` + `@GetMapping/@PostMapping` route to correct method
3. **Parameter Extraction**: 
   - `@PathVariable` from URL path
   - `@RequestParam` from query string
   - `@RequestBody` from request body
4. **Data Deserialization**: Jackson converts JSON → DTO objects
5. **Validation**: `@Valid` annotation triggers Bean Validation
6. **Service Calling**: Controller calls injected Service methods
7. **Response Formatting**: Controller wraps response in `ResponseEntity`
8. **Serialization**: Jackson converts response objects → JSON
9. **HTTP Response**: Spring sends HTTP status + JSON to client

### Request Journey Summary

```
HTTP Request
    ↓
Spring DispatcherServlet intercepts
    ↓
URL pattern matching (@RequestMapping/@GetMapping...)
    ↓
Parameter extraction & conversion
    ↓
JSON deserialization (Jackson)
    ↓
Validation (@Valid)
    ↓
Controller method invocation
    ↓
Service method called
    ↓
Response received from Service
    ↓
JSON serialization
    ↓
ResponseEntity wrapping
    ↓
HTTP Response sent to client
```

---

## NEXT STEPS

- **Next Document**: `service.md` - Service Layer explanation (business logic, @Transactional, calling repositories)
- **Then**: `database.md` - Database Layer (JPA, EntityManager, SQL generation)
- **Then**: `dataflow.md` - Complete data flow diagrams (both directions)
- **Finally**: `workflow.md` - End-to-end execution workflow

