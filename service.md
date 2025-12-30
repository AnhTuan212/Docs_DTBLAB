# Backend Communication Architecture: Service Layer

**Project:** AuraControl Spa Management System  
**Layer:** Service Layer (Business Logic & Transaction Management)  
**Date:** December 30, 2025

---

## TABLE OF CONTENTS
1. [Service Layer Overview](#service-layer-overview)
2. [How Service Functions Implement Business Logic](#how-service-functions-implement-business-logic)
3. [How Service Calls Repository/Database Functions](#how-service-calls-repositorydatabase-functions)
4. [Role of @Transactional Annotation](#role-of-transactional-annotation)
5. [Transaction Management Deep Dive](#transaction-management-deep-dive)
6. [Service Layer Communication Flow](#service-layer-communication-flow)
7. [Real-World Examples from AuraControl](#real-world-examples-from-auracontrol)
8. [Service Dependencies & Injection](#service-dependencies--injection)
9. [Error Handling in Service Layer](#error-handling-in-service-layer)

---

## SERVICE LAYER OVERVIEW

### What is the Service Layer?

The **Service Layer** is the **business logic tier** of the application. It sits between the **Controller Layer** (above) and the **Repository/Database Layer** (below).

**Responsibilities:**
1. **Process business logic** (rules, calculations, validations)
2. **Coordinate database operations** (call repositories)
3. **Manage transactions** (ensure data consistency)
4. **Handle security** (check permissions, validate data)
5. **Transform data** (convert between DTOs and Entities)
6. **Orchestrate complex workflows** (multi-step operations)

### Why Separate Service Layer?

```
❌ WITHOUT Service Layer:
Controller → Database
❌ All business logic in controller
❌ Hard to test
❌ Repeated code
❌ No reusability

✅ WITH Service Layer:
Controller → Service → Database
✅ Business logic centralized
✅ Easy to test (mock service)
✅ Reusable business logic
✅ Clean separation of concerns
```

### Service Layer Architecture in AuraControl

```
┌─────────────────────────────────────┐
│ CONTROLLER LAYER (47 functions)     │
│ Receives HTTP requests              │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│ SERVICE LAYER (52 functions)        │
│ ├─ AuthService (5)                  │
│ ├─ AppointmentService (17)          │
│ ├─ AbsenceRequestService (6)        │
│ ├─ ServiceService (6)               │
│ ├─ UserService (3)                  │
│ ├─ TechnicianService (1)            │
│ ├─ AdminResourceService (7)         │
│ ├─ AdminTechnicianService (5)       │
│ ├─ AdminCustomerService (2)         │
│ └─ DashboardService (3)             │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│ REPOSITORY LAYER (85 functions)     │
│ Accesses Database                   │
└─────────────────────────────────────┘
```

---

## HOW SERVICE FUNCTIONS IMPLEMENT BUSINESS LOGIC

### What is Business Logic?

**Business Logic** = Rules that define how the application operates

Examples in AuraControl:
- ✅ Validate appointment is not in the past
- ✅ Check technician has required skill
- ✅ Verify resource availability
- ✅ Calculate appointment end time from duration
- ✅ Validate absence request doesn't overlap with appointments
- ✅ Check 30-minute cancellation window

### Service Function Structure

```java
@Service
@RequiredArgsConstructor
public class ServiceClassName {
    // Step 1: Inject dependencies
    private final RepositoryInterface repository;
    private final AnotherService anotherService;
    
    // Step 2: Define business logic method
    @Transactional  // IMPORTANT: Manages database transaction
    public ResultType businessLogicMethod(InputType input) {
        // Step 3a: Validate input
        if (input == null) {
            throw new InvalidRequestException("Input cannot be null");
        }
        
        // Step 3b: Execute business rules
        // Call other services if needed
        AnotherEntity result = anotherService.helperMethod(input);
        
        // Step 3c: Call repository to access database
        EntityType entity = new EntityType();
        entity.setField1(input.getValue());
        
        // Step 3d: Persist to database
        EntityType savedEntity = repository.save(entity);
        
        // Step 3e: Return result to caller (Controller)
        return convertToDTO(savedEntity);
    }
}
```

### Real Example: AppointmentService.createAppointment()

```java
@Service
@RequiredArgsConstructor
public class AppointmentService {
    // Dependencies injected
    private final AppointmentRepository appointmentRepository;
    private final TechnicianRepository technicianRepository;
    private final ServiceRepository serviceRepository;
    private final CustomerRepository customerRepository;
    private final ResourceRepository resourceRepository;
    
    // Business logic method
    @Transactional(rollbackFor = Exception.class)
    public Appointment createAppointment(BookingRequest request) {
        
        // STEP 1: VALIDATE INPUT
        // Implicit: @Valid on @RequestBody validates in controller
        
        // STEP 2: RETRIEVE CURRENT CUSTOMER
        String currentUserEmail = SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getName();
        
        Customer customer = customerRepository.findByUserEmail(currentUserEmail)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "Customer not found with email: " + currentUserEmail));
        
        // STEP 3: RETRIEVE SERVICE INFO
        var service = serviceRepository.findById(request.getServiceId())
                .orElseThrow(() -> new ResourceNotFoundException("Service not found"));
        
        // STEP 4: VALIDATE SERVICE IS ACTIVE
        if (service.getIsActive() == null || !service.getIsActive()) {
            throw new ResourceNotFoundException("Service is inactive");
        }
        
        // STEP 5: GET AVAILABLE TECHNICIANS
        List<TechnicianOptionDto> availableTechs =
                technicianRepository.findAvailableTechnicians(
                        request.getServiceId(),
                        request.getStartTime()
                );
        
        // STEP 6: SELECT TECHNICIAN
        Technician technician;
        
        if (request.getTechnicianId() != null) {
            // Customer selected specific technician
            boolean isAvailable = availableTechs.stream()
                    .anyMatch(dto -> dto.getTechnicianId()
                            .equals(request.getTechnicianId()));
            
            if (!isAvailable) {
                throw new ResourceNotFoundException(
                        "Selected technician is busy or not qualified.");
            }
            
            technician = technicianRepository
                    .findById(request.getTechnicianId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Technician not found"));
        } else {
            // Auto-assign random available technician
            if (availableTechs.isEmpty()) {
                throw new ResourceNotFoundException(
                        "No available technician for this time slot.");
            }
            
            int randomIndex = new Random().nextInt(availableTechs.size());
            TechnicianOptionDto selectedDto = availableTechs.get(randomIndex);
            
            technician = technicianRepository
                    .findById(selectedDto.getTechnicianId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Auto-assigned technician not found"));
        }
        
        // STEP 7: CALCULATE APPOINTMENT DURATION
        LocalDateTime startTime = request.getStartTime();
        LocalDateTime endTime = startTime
                .plusMinutes(service.getDurationMinutes());
        
        // STEP 8: CHECK RESOURCE AVAILABILITY
        List<ServiceResourceRequirement> requirements = 
                serviceResourceRequirementRepository
                        .findByServiceId(service.getServiceId());
        
        if (!requirements.isEmpty()) {
            List<Integer> busyIds = resourceRepository
                    .findBusyResourceIds(startTime, endTime);
            
            if (busyIds.isEmpty()) {
                busyIds.add(-1);  // Prevent empty IN clause
            }
            
            for (ServiceResourceRequirement req : requirements) {
                String requiredType = req.getResourceType();
                
                // Find available resource of required type
                Resource foundResource = resourceRepository
                        .findFirstAvailableByType(requiredType, busyIds)
                        .orElseThrow(() -> new ResourceNotFoundException(
                                "No available resource of type: " + requiredType));
                
                busyIds.add(foundResource.getResourceId());
            }
        }
        
        // STEP 9: CREATE APPOINTMENT ENTITY
        Appointment appointment = new Appointment();
        appointment.setCustomer(customer);
        appointment.setTechnician(technician);
        appointment.setService(service);
        appointment.setStartTime(startTime);
        appointment.setEndTime(endTime);
        appointment.setStatus("CONFIRMED");
        
        // STEP 10: SAVE TO DATABASE
        Appointment savedAppointment = appointmentRepository.save(appointment);
        
        // STEP 11: RETURN RESULT
        return savedAppointment;
    }
}
```

**What happened above:**
1. ✅ Validated customer exists
2. ✅ Validated service exists and is active
3. ✅ Retrieved available technicians from database
4. ✅ Validated technician selection (explicit or auto-assign)
5. ✅ Calculated end time from service duration
6. ✅ Validated all required resources are available
7. ✅ Created new Appointment entity
8. ✅ Saved to database via repository
9. ✅ Returned result to controller

---

## HOW SERVICE CALLS REPOSITORY/DATABASE FUNCTIONS

### Repository Calling Pattern

Services **never** access the database directly. Instead, they use **Repository** interfaces that extend `JpaRepository`.

```
Service ← Calls → Repository Interface
                      ↓
                  (Spring generates implementation)
                      ↓
                  Hibernate/JPA
                      ↓
                  SQL Queries
                      ↓
                  PostgreSQL Database
```

### Types of Repository Queries

#### 1. Default JPA Repository Methods (Inherited)

```java
// Service class calls these methods (pre-built by Spring Data JPA)

// Find by ID
Optional<Service> service = serviceRepository.findById(1);

// Find all
List<Service> allServices = serviceRepository.findAll();

// Save/Update
Service saved = serviceRepository.save(service);

// Delete
serviceRepository.deleteById(1);

// Count
long total = serviceRepository.count();

// Check exists
boolean exists = serviceRepository.existsById(1);
```

#### 2. Custom Derived Query Methods

```java
// Method names that follow naming convention
// Spring Data JPA generates the SQL automatically

// Example: Find by field
Optional<User> user = userRepository.findByEmail("user@example.com");
// Generates: SELECT u FROM User u WHERE u.email = 'user@example.com'

// Example: Find with multiple conditions
List<Appointment> appts = appointmentRepository
    .findByCustomer_User_EmailAndStartTimeAfterAndStatusNotOrderByStartTimeAsc(
        email,
        now,
        "CANCELLED"
    );
// Generates: SELECT a FROM Appointment a 
//            WHERE a.customer.user.email = ? 
//            AND a.startTime > ? 
//            AND a.status != ? 
//            ORDER BY a.startTime ASC
```

#### 3. Custom @Query Methods (JPQL)

```java
// Explicit JPQL query written by developer
// Gives more control than naming convention

@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);

// Service calls it
Optional<User> user = userRepository.findByEmail("user@example.com");
```

#### 4. Custom @Query Methods (Native SQL)

```java
// Direct SQL queries (for complex operations)

@Query(value = "SELECT * FROM get_available_technicians(:serviceId, CAST(:checkTime AS TIMESTAMP))",
       nativeQuery = true)
List<TechnicianOptionDto> findAvailableTechnicians(
    @Param("serviceId") Integer serviceId,
    @Param("checkTime") LocalDateTime checkTime
);

// Service calls it
List<TechnicianOptionDto> available = technicianRepository
    .findAvailableTechnicians(1, LocalDateTime.now());
```

#### 5. Modifying Queries (UPDATE/DELETE)

```java
// For UPDATE and DELETE operations

@Modifying
@Query("UPDATE Service s SET s.isActive = false WHERE s.serviceId = :id")
void deactivateService(@Param("id") Integer id);

// Service calls it
serviceRepository.deactivateService(1);
```

### Real Example: Service Calling Multiple Repository Methods

```java
@Service
@RequiredArgsConstructor
public class AdminCustomerService {
    private final UserRepository userRepository;
    private final CustomerRepository customerRepository;
    private final AppointmentRepository appointmentRepository;
    
    @Transactional(readOnly = true)  // Read-only transaction
    public CustomerDetailResponse getCustomerDetail(Integer userId) {
        // Call 1: Find user in database
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "User not found"));
        
        // Call 2: Find customer associated with user
        Customer customer = customerRepository.findByUser_UserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "This user is not a customer"));
        
        // Call 3: Find all appointments for this customer
        List<Appointment> appointments = appointmentRepository
                .findByCustomer_CustomerIdOrderByStartTimeDesc(
                    customer.getCustomerId());
        
        // Build response
        CustomerDetailResponse response = new CustomerDetailResponse();
        response.setUserId(user.getUserId());
        response.setName(user.getName());
        response.setEmail(user.getEmail());
        response.setCustomerId(customer.getCustomerId());
        
        // Convert appointments to DTOs
        List<AppointmentHistoryDto> history = appointments.stream()
                .map(appt -> AppointmentHistoryDto.builder()
                        .appointmentId(appt.getAppointmentId())
                        .startTime(appt.getStartTime())
                        .endTime(appt.getEndTime())
                        .status(appt.getStatus())
                        .price(appt.getFinalPrice())
                        .serviceName(appt.getService().getName())
                        .technicianName(
                            appt.getTechnician() != null 
                                ? appt.getTechnician().getUser().getName() 
                                : "Undefined"
                        )
                        .build())
                .collect(Collectors.toList());
        
        response.setAppointmentHistory(history);
        
        return response;
    }
}
```

**Repository calls in order:**
1. `userRepository.findById(userId)` - Get user
2. `customerRepository.findByUser_UserId(userId)` - Get customer
3. `appointmentRepository.findByCustomer_CustomerIdOrderByStartTimeDesc()` - Get appointments

---

## ROLE OF @TRANSACTIONAL ANNOTATION

### What is a Transaction?

A **transaction** is a sequence of database operations that must either **all succeed** or **all fail** together.

**Transaction ACID Properties:**
- **A**tomicity: All or nothing (complete or rollback)
- **C**onsistency: Data remains consistent
- **I**solation: Operations don't interfere with each other
- **D**urability: Changes persist once committed

### @Transactional Annotation

```java
@Service
public class AppointmentService {
    
    @Transactional  // Marks method as transactional
    public Appointment createAppointment(BookingRequest request) {
        // All database operations here are in ONE transaction
        // If any step fails, ALL changes are rolled back
    }
}
```

### How @Transactional Works

```
┌─────────────────────────────────────────────────────┐
│ Method execution starts                             │
│ @Transactional interceptor activates                │
└────────────┬──────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────┐
│ Database Transaction BEGINS                         │
│ (ACID rules now apply)                              │
└────────────┬──────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────┐
│ Business logic executes                             │
│ ├─ Method code runs line by line                   │
│ ├─ Multiple repository.save() calls                │
│ ├─ Multiple repository.find() calls                │
│ └─ All within SAME transaction                     │
└────────────┬──────────────────────────────────────┘
             │
         ┌───┴─────────────────────────┐
         │                             │
         ↓                             ↓
    ✅ SUCCESS               ❌ EXCEPTION
         │                             │
         ↓                             ↓
   COMMIT Transaction          ROLLBACK Transaction
   (Save changes)              (Undo all changes)
         │                             │
         └─────────────┬──────────────┘
                       │
                       ↓
           Method returns / throws exception
```

### @Transactional Parameters

```java
@Transactional(rollbackFor = Exception.class)
public Appointment createAppointment(BookingRequest request) {
    // rollbackFor: Which exceptions trigger rollback
}

@Transactional(readOnly = true)
public List<Appointment> getAppointments() {
    // readOnly: No database writes expected
    // Optimization: Tells Spring not to create write transaction
}

@Transactional(timeout = 30)
public void longRunningOperation() {
    // timeout: Max time (seconds) method can take
    // If exceeded, transaction rolls back
}

@Transactional(propagation = Propagation.REQUIRES_NEW)
public void independentOperation() {
    // propagation: How nested transactions work
}
```

### Transaction Propagation Levels

```
┌────────────────────────────┬─────────────────────────────────┐
│ Propagation Level          │ Behavior                        │
├────────────────────────────┼─────────────────────────────────┤
│ REQUIRED (default)         │ Use existing or create new      │
│ REQUIRES_NEW               │ Always create new, suspend old  │
│ NESTED                     │ Create savepoint within tx      │
│ NOT_SUPPORTED              │ Run outside transaction         │
│ NEVER                      │ Fail if already in transaction  │
│ SUPPORTS                   │ Use existing or run without     │
│ MANDATORY                  │ Fail if not in transaction      │
└────────────────────────────┴─────────────────────────────────┘
```

### Real Example: Transaction Rollback

```java
@Transactional(rollbackFor = Exception.class)
public void complexOperation() {
    // Step 1: Save appointment
    Appointment appt = new Appointment();
    appt.setStartTime(LocalDateTime.now());
    appointmentRepository.save(appt);  // DB INSERT
    
    // Step 2: Update technician schedule
    technician.setAvailable(false);
    technicianRepository.save(technician);  // DB UPDATE
    
    // Step 3: Send email
    emailService.sendConfirmation(customer.getEmail());
    
    // Step 4: ERROR OCCURS!
    throw new RuntimeException("Email service failed!");
    
    // RESULT:
    // - Appointment INSERT rolled back
    // - Technician UPDATE rolled back
    // - All changes undone
    // - Database in original state
    // - Email was already sent (can't roll back)
}
```

---

## TRANSACTION MANAGEMENT DEEP DIVE

### Transaction Lifecycle

```
1. BEFORE Method Execution
   ├─ Spring creates transaction context
   ├─ Database connection obtained from pool
   ├─ Transaction begins (BEGIN)
   └─ Isolation level set

2. DURING Method Execution
   ├─ All database operations run within transaction
   ├─ Changes buffered in memory (not immediately written)
   ├─ Other connections can't see uncommitted changes
   └─ Read locks/write locks acquired as needed

3. AFTER Method Execution
   ├─ If no exception: COMMIT
   │  ├─ All changes written to database
   │  ├─ Transaction ends
   │  └─ Connection returned to pool
   │
   └─ If exception: ROLLBACK
      ├─ All changes discarded
      ├─ Transaction ends
      └─ Connection returned to pool
```

### Dirty Read Prevention

```
Transaction 1                          Transaction 2
├─ BEGIN                              ├─ BEGIN
├─ READ user.balance = 100            │
├─ CALCULATE: 100 - 50 = 50           │
├─ UPDATE user.balance = 50           │
│                                      ├─ READ user.balance = 50 (dirty read!)
├─ ERROR: Insufficient permissions    │  (Transaction 1 hasn't committed yet)
├─ ROLLBACK                           │
│  └─ balance back to 100             │
│                                      ├─ UPDATE balance based on 50
└─ Transaction 1 ends                 └─ COMMIT (now balance is wrong!)

WITH ISOLATION LEVEL:
Transaction 1                          Transaction 2
├─ BEGIN (REPEATABLE_READ)            ├─ BEGIN
├─ READ user.balance = 100 (locked)   │
├─ CALCULATE: 100 - 50 = 50           │
├─ UPDATE user.balance = 50           │
│                                      ├─ WAIT (locked by Transaction 1)
├─ ERROR: Insufficient permissions    │
├─ ROLLBACK                           │
│  └─ Lock released, balance = 100    │
│                                      ├─ READ user.balance = 100 (correct!)
└─ Transaction 1 ends                 └─ No dirty read!
```

### Cascading Transactions in Service Layer

```java
@Service
public class ServiceA {
    private final ServiceB serviceB;
    private final RepositoryA repositoryA;
    
    @Transactional  // Transaction A starts
    public void methodA() {
        repositoryA.save(entity1);
        
        // Calls another service method
        serviceB.methodB();  // Uses same transaction A
        
        repositoryA.save(entity2);
    }
}

@Service
public class ServiceB {
    private final RepositoryB repositoryB;
    
    @Transactional  // Joins Transaction A (propagation=REQUIRED)
    public void methodB() {
        repositoryB.save(entity3);  // Same transaction as ServiceA
    }
}

// Timeline:
// 1. ServiceA.methodA() starts → Transaction A begins
// 2. entity1 saved
// 3. ServiceB.methodB() called → joins Transaction A
// 4. entity3 saved (within Transaction A)
// 5. ServiceB.methodB() ends
// 6. entity2 saved
// 7. ServiceA.methodA() ends → Transaction A commits or rolls back
// Result: All 3 entities saved/rolled back together
```

---

## SERVICE LAYER COMMUNICATION FLOW

### Complete Communication Sequence

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. CONTROLLER LAYER                                             │
│ (Request arrives from HTTP)                                     │
│                                                                 │
│ @PostMapping                                                    │
│ public ResponseEntity<?> createBooking(                         │
│     @RequestBody @Valid BookingRequest request                 │
│ ) {                                                             │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Calls: appointmentService.createAppointment(request)
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. SERVICE LAYER BEGINS                                         │
│ (Transaction created)                                           │
│                                                                 │
│ @Transactional(rollbackFor = Exception.class)                  │
│ public Appointment createAppointment(BookingRequest request) {  │
│                                                                 │
│     // Business Logic Step 1: Validate input                   │
│     if (request == null) {                                      │
│         throw new InvalidRequestException("...");              │
│     }                                                           │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Calls: customerRepository.findByUserEmail(email)
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. REPOSITORY LAYER - FIRST CALL                                │
│ (Database Query 1)                                              │
│                                                                 │
│ public interface CustomerRepository extends JpaRepository {    │
│     @Query("SELECT c FROM Customer c WHERE c.user.email...")   │
│     Optional<Customer> findByUserEmail(String email);          │
│ }                                                               │
│                                                                 │
│ Spring automatically:                                          │
│ 1. Translates to SQL: SELECT * FROM customer WHERE...          │
│ 2. Executes against PostgreSQL                                 │
│ 3. Maps ResultSet to Customer entity                           │
│ 4. Returns Optional<Customer>                                  │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Returns: Optional.of(customer)
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. SERVICE LAYER CONTINUES                                      │
│                                                                 │
│     // Business Logic Step 2: Process retrieved data           │
│     Customer customer = customerRepository.findByUserEmail...  │
│         .orElseThrow(...);                                      │
│                                                                 │
│     // Business Logic Step 3: Retrieve service info            │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Calls: serviceRepository.findById(id)
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. REPOSITORY LAYER - SECOND CALL                               │
│ (Database Query 2)                                              │
│                                                                 │
│ public interface ServiceRepository extends JpaRepository {     │
│     @Query("SELECT s FROM Service s WHERE s.serviceId = :id") │
│     Optional<Service> findById(@Param("id") Integer id);       │
│ }                                                               │
│                                                                 │
│ Returns: Optional<Service>                                      │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Returns service entity
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. SERVICE LAYER CONTINUES                                      │
│                                                                 │
│     // Validate service is active                              │
│     if (!service.getIsActive()) {                              │
│         throw new ResourceNotFoundException(...);              │
│     }                                                           │
│                                                                 │
│     // Get available technicians                               │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Calls: technicianRepository.findAvailableTechnicians(...)
             │ (This calls SQL function in database)
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 7. REPOSITORY LAYER - COMPLEX QUERY                             │
│ (Database Function Call)                                        │
│                                                                 │
│ @Query(value = "SELECT * FROM get_available_technicians(...)", │
│        nativeQuery = true)                                      │
│ List<TechnicianOptionDto> findAvailableTechnicians(...);       │
│                                                                 │
│ Executes in PostgreSQL:                                        │
│ SELECT * FROM get_available_technicians(serviceId, checkTime) │
│                                                                 │
│ Returns: List<TechnicianOptionDto>                             │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Returns available technicians list
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 8. SERVICE LAYER CONTINUES                                      │
│                                                                 │
│     // Validate technician selection                           │
│     if (request.getTechnicianId() != null) {                   │
│         // Customer selected specific tech                    │
│         ...                                                     │
│     } else {                                                    │
│         // Auto-assign                                         │
│         ...                                                     │
│     }                                                           │
│                                                                 │
│     // Create appointment entity                               │
│     Appointment appointment = new Appointment();               │
│     appointment.setCustomer(customer);                         │
│     appointment.setTechnician(technician);                     │
│     ...                                                         │
│                                                                 │
│     // FINAL: Save to database                                 │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Calls: appointmentRepository.save(appointment)
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 9. REPOSITORY LAYER - FINAL CALL                                │
│ (Database INSERT)                                               │
│                                                                 │
│ public interface AppointmentRepository extends JpaRepository { │
│     Appointment save(Appointment appointment);                  │
│ }                                                               │
│                                                                 │
│ Spring/Hibernate:                                              │
│ 1. Detects this is a new entity (no ID)                        │
│ 2. Generates INSERT SQL                                        │
│ 3. Executes: INSERT INTO appointment (...) VALUES (...)        │
│ 4. Returns entity with generated ID                            │
│                                                                 │
│ Within Transaction: Changes buffered (not yet committed)       │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Returns: Appointment (with ID)
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 10. SERVICE LAYER ENDS                                          │
│                                                                 │
│     return appointment;  // Return to Controller               │
│ }  // @Transactional: COMMIT transaction (write to database)  │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Returns: Appointment object
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 11. CONTROLLER LAYER RECEIVES RESPONSE                          │
│                                                                 │
│     Appointment newAppointment = appointmentService           │
│         .createAppointment(request);                           │
│                                                                 │
│     return ResponseEntity.ok(Map.of(                           │
│         "message", "Booking created!",                         │
│         "appointmentId", newAppointment.getAppointmentId(),   │
│         ...                                                     │
│     ));                                                         │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Converts response to JSON
             ↓
┌─────────────────────────────────────────────────────────────────┐
│ 12. HTTP RESPONSE SENT TO FRONTEND                              │
│                                                                 │
│ HTTP 200 OK                                                    │
│ Content-Type: application/json                                 │
│ Body: {                                                        │
│   "message": "Booking successfully created!",                 │
│   "appointmentId": 42,                                         │
│   ...                                                           │
│ }                                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## REAL-WORLD EXAMPLES FROM AURACONTROL

### Example 1: Service with Multiple Repository Calls (AuthService.register)

```java
@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final CustomerRepository customerRepository;
    
    @Transactional
    public void register(RegisterRequest request) {
        // Step 1: Check if email already exists
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new DuplicateResourceException("Email already exists.");
        }
        
        // Step 2: Create user entity
        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(Role.CUSTOMER);
        user.setEnabled(false);  // Not enabled until verified
        
        // Step 3: Generate verification token
        String token = UUID.randomUUID().toString();
        user.setVerificationToken(token);
        
        // Step 4: Save user to database
        userRepository.save(user);
        
        // Step 5: Send verification email (external service)
        emailService.sendVerificationEmail(
            user.getEmail(), 
            user.getName(), 
            token
        );
        
        // If email fails, transaction rolls back (if configured)
    }
}
```

**Service-Repository interaction:**
1. Calls `userRepository.findByEmail()` - Repository query
2. Calls `userRepository.save()` - Repository insert
3. Calls `emailService.sendVerificationEmail()` - External service (not part of transaction)

### Example 2: Service with Business Logic & Calculations (AppointmentService.getAvailableSlots)

```java
@Service
@RequiredArgsConstructor
public class AppointmentService {
    private final ServiceRepository serviceRepository;
    private final TechnicianRepository technicianRepository;
    private final AppointmentRepository appointmentRepository;
    private final AbsenceRequestRepository absenceRequestRepository;
    
    public List<String> getAvailableSlots(Integer serviceId, LocalDate date) {
        List<String> availableSlots = new ArrayList<>();
        
        // Step 1: Get service duration
        var service = serviceRepository.findById(serviceId)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "Service not found"));
        int durationMinutes = service.getDurationMinutes();
        
        // Step 2: Get all technicians for this service
        List<Technician> skilledTechs = 
                technicianRepository.findAllByServiceId(serviceId);
        
        if (skilledTechs.isEmpty()) {
            return availableSlots;  // No available slots
        }
        
        // Step 3: Get all appointments for the day
        LocalDateTime startOfDay = date.atTime(0, 0, 0);
        LocalDateTime endOfDay = date.atTime(23, 59, 59);
        
        List<Appointment> todaysAppointments = 
                appointmentRepository
                        .findAllByStartTimeBetweenAndStatusNot(
                            startOfDay, 
                            endOfDay, 
                            "CANCELLED");
        
        // Step 4: Get all absence requests for technicians
        List<Integer> techIds = skilledTechs.stream()
                .map(Technician::getTechnicianId)
                .collect(Collectors.toList());
        
        List<AbsenceRequest> absences = 
                absenceRequestRepository
                        .findByTechnicianIdInAndStatusAndDateRange(
                            techIds, 
                            "APPROVED", 
                            startOfDay, 
                            endOfDay);
        
        // Step 5: Calculate available time slots (09:00 to 21:00, every 15 min)
        LocalDateTime currentSlot = date.atTime(9, 0);
        LocalDateTime closingTime = date.atTime(21, 0);
        
        while (!currentSlot.plusMinutes(durationMinutes)
                .isAfter(closingTime)) {
            LocalDateTime slotEnd = currentSlot.plusMinutes(durationMinutes);
            
            // Skip lunch (12:00-14:00)
            LocalDateTime lunchStart = date.atTime(12, 0);
            LocalDateTime lunchEnd = date.atTime(14, 0);
            
            if (currentSlot.isBefore(lunchEnd) && 
                slotEnd.isAfter(lunchStart)) {
                currentSlot = currentSlot.plusMinutes(15);
                continue;
            }
            
            // Skip past slots
            if (currentSlot.isBefore(LocalDateTime.now())) {
                currentSlot = currentSlot.plusMinutes(15);
                continue;
            }
            
            // Step 6: Check if any technician is available
            long busyTechCount = skilledTechs.stream()
                    .filter(tech -> {
                        // Check appointments
                        boolean hasAppointment = todaysAppointments.stream()
                                .anyMatch(appt ->
                                        appt.getTechnician()
                                            .getTechnicianId()
                                            .equals(tech.getTechnicianId()) &&
                                        appt.getStartTime().isBefore(slotEnd) &&
                                        appt.getEndTime().isAfter(currentSlot)
                                );
                        
                        // Check absences
                        boolean isAbsent = absences.stream()
                                .anyMatch(abs ->
                                        abs.getTechnician()
                                            .getTechnicianId()
                                            .equals(tech.getTechnicianId()) &&
                                        abs.getStartDate().isBefore(slotEnd) &&
                                        abs.getEndDate().isAfter(currentSlot)
                                );
                        
                        return hasAppointment || isAbsent;
                    })
                    .count();
            
            if (busyTechCount < skilledTechs.size()) {
                availableSlots.add(currentSlot.format(
                    DateTimeFormatter.ofPattern("HH:mm")
                ));
            }
            
            currentSlot = currentSlot.plusMinutes(15);
        }
        
        return availableSlots;
    }
}
```

**Repository calls:**
1. `serviceRepository.findById()` - Get service duration
2. `technicianRepository.findAllByServiceId()` - Get qualified techs
3. `appointmentRepository.findAllByStartTimeBetweenAndStatusNot()` - Get bookings
4. `absenceRequestRepository.findByTechnicianIdInAndStatusAndDateRange()` - Get absences

**Business logic:**
- Calculates 15-minute slots
- Filters out lunch time
- Filters out past times
- Checks technician availability
- Checks absence requests

### Example 3: Service with Transaction Rollback (AbsenceRequestService.reviewRequest)

```java
@Service
@RequiredArgsConstructor
public class AbsenceRequestService {
    private final AbsenceRequestRepository absenceRequestRepository;
    
    @Transactional
    public void reviewRequest(Integer requestId, String status) {
        // Validate status
        if (!status.equals("APPROVED") && !status.equals("REJECTED")) {
            throw new InvalidRequestException("Invalid status");
        }
        
        // Step 1: Retrieve request
        AbsenceRequest request = absenceRequestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "Cannot find request with id: " + requestId));
        
        // Step 2: Update status
        request.setStatus(status);
        
        // Step 3: Save to database
        absenceRequestRepository.save(request);
        
        // If any database constraint is violated (e.g., trigger in database),
        // this transaction will rollback
    }
}
```

If database trigger `trg_validate_absence_request_master` detects conflict:
- ✅ Transaction rollback triggered
- ✅ Database raises exception
- ✅ Service layer catches it
- ✅ All changes discarded
- ✅ Database in original state

---

## SERVICE DEPENDENCIES & INJECTION

### How Services Get Dependencies

```java
@Service
@RequiredArgsConstructor  // Lombok: auto-generates constructor
public class AppointmentService {
    // Declaring dependencies
    private final AppointmentRepository appointmentRepository;
    private final TechnicianRepository technicianRepository;
    private final ServiceRepository serviceRepository;
    private final CustomerRepository customerRepository;
    
    // Lombok generates equivalent of:
    // public AppointmentService(
    //     AppointmentRepository appointmentRepository,
    //     TechnicianRepository technicianRepository,
    //     ServiceRepository serviceRepository,
    //     CustomerRepository customerRepository
    // ) {
    //     this.appointmentRepository = appointmentRepository;
    //     this.technicianRepository = technicianRepository;
    //     this.serviceRepository = serviceRepository;
    //     this.customerRepository = customerRepository;
    // }
}
```

### Dependency Resolution

```
Spring Container Initialization
    ↓
Scans classpath for @Service, @Repository, @Controller, etc.
    ↓
Finds AppointmentService.java
    ↓
Analyzes constructor dependencies:
    ├─ AppointmentRepository (looks for @Repository)
    ├─ TechnicianRepository (looks for @Repository)
    ├─ ServiceRepository (looks for @Repository)
    └─ CustomerRepository (looks for @Repository)
    ↓
Creates all repositories (they extend JpaRepository)
    ↓
Creates AppointmentService with injected repositories
    ↓
When Controller requests AppointmentService,
Spring provides pre-configured instance with all dependencies
```

### Service Calling Another Service

```java
@Service
public class AdminResourceService {
    private final ResourceRepository resourceRepository;
    private final AnotherService anotherService;  // Inject another service
    
    @Transactional
    public Resource createResource(ResourceDto request) {
        // Call another service
        boolean isDuplicate = anotherService.checkDuplicate(request);
        
        if (isDuplicate) {
            throw new DuplicateResourceException(...);
        }
        
        // Continue with repository call
        Resource resource = new Resource();
        resource.setName(request.getName());
        
        return resourceRepository.save(resource);
    }
}
```

**Transactional behavior:**
- When AnotherService method also has `@Transactional`
- It joins the parent transaction (propagation = REQUIRED by default)
- All repository calls are part of same transaction
- If either service fails, entire transaction rolls back

---

## ERROR HANDLING IN SERVICE LAYER

### Custom Exception Hierarchy

```
Exception (Java)
    ↓
    ├─ RuntimeException
    │   ├─ ResourceNotFoundException (Custom)
    │   ├─ DuplicateResourceException (Custom)
    │   ├─ InvalidRequestException (Custom)
    │   └─ AccessDeniedException (Spring Security)
    │
    └─ CheckedException
        └─ Exception
```

### Exception Handling in Service

```java
@Service
public class UserService {
    private final UserRepository userRepository;
    
    @Transactional
    public UserProfileResponse getCurrentUserProfile() {
        String currentUserEmail = SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getName();
        
        // Exception 1: User not found
        User user = userRepository.findByEmail(currentUserEmail)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "Cannot find User"));
        
        // If thrown: 404 Not Found returned to client
        
        return UserProfileResponse.builder()
                .id(Math.toIntExact(user.getUserId()))
                .fullName(user.getName())
                .email(user.getEmail())
                .build();
    }
    
    @Transactional
    public void changePassword(ChangePasswordRequest request) {
        String currentUserEmail = SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getName();
        
        User user = userRepository.findByEmail(currentUserEmail)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "User not found"));
        
        // Exception 2: Invalid old password
        if (!passwordEncoder.matches(
            request.getCurrentPassword(), 
            user.getPassword())) {
            throw new InvalidRequestException(
                "Old password is not correct.");
        }
        
        // If thrown: 400 Bad Request returned to client
        
        String encodedNewPassword = passwordEncoder
                .encode(request.getNewPassword());
        
        userRepository.updatePassword(
            Math.toIntExact(user.getUserId()), 
            encodedNewPassword);
    }
}
```

### Exception Flow to Client

```
Service throws exception
    ↓
Transaction rollback triggered (if @Transactional)
    ↓
Exception propagates to Controller
    ↓
GlobalExceptionHandler catches exception
    ↓
ErrorResponse built
    ↓
HTTP status code determined:
    ├─ ResourceNotFoundException → 404
    ├─ DuplicateResourceException → 409
    ├─ InvalidRequestException → 400
    └─ AccessDeniedException → 403
    ↓
JSON error response sent to client
    ↓
Frontend displays error message
```

---

## SUMMARY: SERVICE LAYER COMMUNICATION

### Key Points

1. **Business Logic**: Services implement rules, validations, calculations
2. **Repository Calls**: Services invoke repository methods to access database
3. **Transactions**: @Transactional ensures atomic operations (all or nothing)
4. **Rollback**: Exceptions trigger automatic transaction rollback
5. **Dependency Injection**: Services receive repositories via constructor
6. **Error Handling**: Custom exceptions for specific error conditions
7. **Cascading**: Service-to-service calls use same transaction

### Service → Repository Flow

```
Service Method Called
    ↓
Validate input/business rules
    ↓
Call repository method
    ↓
Repository generates SQL
    ↓
Hibernate executes against PostgreSQL
    ↓
ResultSet returned
    ↓
ResultSet mapped to Java entity
    ↓
Entity returned to service
    ↓
Service processes entity
    ↓
If @Transactional: COMMIT all changes
    ↓
Return result to controller
```

### Next Documents

- **database.md** - How JPA, Hibernate, and EntityManager work
- **dataflow.md** - Complete bidirectional data flow
- **workflow.md** - End-to-end request processing workflow

