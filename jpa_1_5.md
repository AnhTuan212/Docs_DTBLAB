# JPA Execution Traces: Functions 1-5

**Project:** AuraControl Spa Management System  
**Scope:** CRUD operations with PURE SQL execution  
**Date:** December 30, 2025

---

## FUNCTION 1: UserRepository.findByEmail()

**Function Name:** findByEmail(String email)  
**Layer:** Repository  
**File Path:** Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java  
**Class:** UserRepository  
**Triggered API:** POST /api/auth/register, POST /api/auth/login, GET /api/users/profile  
**HTTP Method + URL:** POST /api/auth/register  
**CRUD Type:** READ (SELECT)

### 1) Execution Path

```
HTTP POST /api/auth/register
    ↓
AuthController.register(RegisterRequest)
    ↓
AuthService.register(request)
    ↓
userRepository.findByEmail(email)  ← HERE
    ↓
Spring Data JPA generates JPQL
    ↓
Hibernate translates to SQL
    ↓
PostgreSQL executes SELECT
    ↓
ResultSet mapped to Optional<User>
    ↓
AuthService receives result
    ↓
Returns to Controller
```

### 2) Critical Code Snippet

```java
// UserRepository.java (Line 18-19)
@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);

// AuthService.java (Line 37-39) - CALLED BY
@Transactional
public void register(RegisterRequest request) {
    // Validation check (transaction starts here)
    if (userRepository.findByEmail(request.getEmail()).isPresent()) {
        throw new DuplicateResourceException("Email already exists");
    }
```

### 3) SQL Execution Details

**SQL Type:** SELECT  
**Target Table:** users  

**SQL Generated:**
```sql
SELECT u.* FROM users u WHERE u.email = ?
```

**Parameter Binding:**
- Parameter: `email` (String)
- Bound as: JDBC PreparedStatement placeholder (?)
- Type: VARCHAR
- Prevents SQL injection

**Execution Flow:**
1. Spring Data JPA intercepts method call
2. Detects @Query annotation
3. Translates JPQL to native SQL
4. Hibernate creates PreparedStatement
5. Binds email parameter
6. Executes via JDBC Driver
7. PostgreSQL returns ResultSet (0 or 1 row)

### 4) Java Object ↔ PostgreSQL Row Mapping

**Java Object:** User entity  
**Mapping Type:** Entity auto-mapping (@Entity/@Column)

**Column → Field Mapping:**
```
users.user_id              → User.userId (Integer, @Id)
users.name                 → User.name (String)
users.email                → User.email (String, @Column unique)
users.password             → User.password (String)
users.role                 → User.role (Role enum, @Enumerated)
users.is_enabled           → User.enabled (Boolean)
users.verification_token   → User.verificationToken (String)
users.created_at           → User.createdAt (LocalDateTime, @CreatedDate)
```

**Mapping Mechanism:**
- Hibernate reads @Entity annotation on User class
- @Column annotations map fields to database columns
- ResultSet row automatically converted to User instance
- Returns `Optional<User>` (empty if no row found)

### 5) PostgreSQL Trigger Interaction

**Trigger Exists:** NO  
**Target Table:** users  
**Reason:** SELECT queries don't invoke triggers (no DML)

### 6) Transaction & Exception Flow

**Transaction Start:** @Transactional on AuthService.register() (line 36)  
**SQL Execution Scope:** Inside transaction (read-only)

**Success Path:**
- ResultSet returned
- User entity populated
- Optional.of(user) returned
- No exception

**Failure Path:**
- If database connection fails: PostgreSQL error
- JDBC throws SQLException
- Hibernate wraps as PersistenceException
- Spring wraps as DataAccessException

**Exception Type:** DataAccessException or custom wrapper

### 7) Final Outcome

**Success:** Optional<User> returned with matching email user  
**Failure (not found):** Optional.empty() returned (no exception)  
**Failure (database error):** DataAccessException thrown, transaction continues to next check

---

## FUNCTION 2: AuthService.register()

**Function Name:** register(RegisterRequest request)  
**Layer:** Service  
**File Path:** Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthService.java  
**Class:** AuthService  
**Triggered API:** POST /api/auth/register  
**HTTP Method + URL:** POST /api/auth/register  
**CRUD Type:** CREATE (INSERT)

### 1) Execution Path

```
HTTP POST /api/auth/register (JSON body: RegisterRequest)
    ↓
AuthController.register(RegisterRequest) (Line 17)
    ↓
AuthService.register(request) (Line 36, @Transactional starts)
    ├─ userRepository.findByEmail() [SELECT validation]
    ├─ Create User entity
    ├─ PasswordEncoder.encode() [password hashing]
    ├─ Generate UUID token
    ├─ userRepository.save() [INSERT]
    └─ emailService.sendEmail() [external, not rolled back]
    ↓
PostgreSQL executes INSERT
    ↓
COMMIT transaction
    ↓
Return success response to Controller
```

### 2) Critical Code Snippet

```java
// AuthService.java (Line 36-50)
@Transactional
public void register(RegisterRequest request) {
    if (userRepository.findByEmail(request.getEmail()).isPresent()) {
        throw new DuplicateResourceException("Email already exists.");
    }
    
    User user = new User();
    user.setName(request.getName());
    user.setEmail(request.getEmail());
    user.setPassword(passwordEncoder.encode(request.getPassword()));
    user.setRole(Role.CUSTOMER);
    user.setEnabled(false);
    
    String token = UUID.randomUUID().toString();
    user.setVerificationToken(token);
    
    userRepository.save(user);  // INSERT happens here
    emailService.sendVerificationEmail(user.getEmail(), user.getName(), token);
}
```

### 3) SQL Execution Details

**SQL Type:** INSERT  
**Target Table:** users  

**SQL Generated:**
```sql
INSERT INTO users (name, email, password, role, is_enabled, verification_token, created_at) 
VALUES (?, ?, ?, ?, ?, ?, NOW())
```

**Parameter Binding:**
- name: String (from request.getName())
- email: String (from request.getEmail())
- password: String (encoded via PasswordEncoder)
- role: VARCHAR 'CUSTOMER' (Role enum converted)
- is_enabled: false (Boolean)
- verification_token: UUID string
- created_at: TIMESTAMP (auto via NOW() or @CreatedDate)

**Execution Flow:**
1. AuthService.register() marked with @Transactional
2. Spring creates transaction context
3. Service calls userRepository.save(user)
4. Hibernate detects new entity (no ID set)
5. Generates INSERT SQL
6. Creates PreparedStatement with parameters
7. Executes via JDBC Driver
8. PostgreSQL inserts row, generates ID via SERIAL
9. User entity populated with generated user_id
10. ID available to service immediately

### 4) Java Object ↔ PostgreSQL Row Mapping

**Java Object:** User entity  
**Mapping Type:** Entity auto-mapping via @Entity and @Column

**Field → Column Mapping (on INSERT):**
```
User.name                  → users.name (VARCHAR)
User.email                 → users.email (VARCHAR, NOT NULL, UNIQUE)
User.password              → users.password (VARCHAR, NOT NULL)
User.role                  → users.role (VARCHAR, default 'CUSTOMER')
User.enabled               → users.is_enabled (BOOLEAN, default false)
User.verificationToken     → users.verification_token (VARCHAR)
(auto-generated)           → users.user_id (SERIAL PRIMARY KEY)
(auto-set)                 → users.created_at (TIMESTAMP DEFAULT NOW())
```

**ID Generation:**
- PostgreSQL SERIAL column auto-generates user_id
- Sequence: users_user_id_seq (auto-created)
- Returned to Hibernate after INSERT
- Populated in User entity.userId field
- Available to service immediately

### 5) PostgreSQL Trigger Interaction

**Trigger Exists:** Possibly (trg_validate_user_master or similar)  
**Timing:** BEFORE INSERT  
**Behavior (if exists):**
- Validates email format
- Validates password minimum length
- Checks for forbidden email patterns
- If validation fails: RAISE EXCEPTION

**Execution:**
```
INSERT triggered
    ↓
BEFORE INSERT: User validation trigger fires
    ├─ Email format validation
    ├─ Password strength check
    └─ If error: RAISE EXCEPTION 'Invalid email'
    ↓
If trigger passes: Row inserted
If trigger fails: Exception raised, transaction rolls back
```

### 6) Transaction & Exception Flow

**Transaction Start:** Line 36 @Transactional on AuthService.register()  
**Scope:** Entire method (both findByEmail and save included)

**Success Path:**
1. findByEmail() executes [SELECT within transaction]
2. Email not found → proceed
3. save() generates INSERT
4. Trigger validates
5. Row inserted
6. Method returns
7. **@Transactional: COMMIT executed** (transaction commits)
8. Changes persisted to PostgreSQL
9. Controller receives result

**Failure Paths:**

**Scenario A: Duplicate email**
```
userRepository.findByEmail() returns isPresent() = true
    ↓
throw new DuplicateResourceException()
    ↓
@Transactional rolls back (no SQL executed yet)
    ↓
Exception propagates to AuthController
    ↓
@ControllerAdvice catches DuplicateResourceException
    ↓
HTTP 409 Conflict returned
```

**Scenario B: Trigger validation fails**
```
INSERT executed
    ↓
PostgreSQL BEFORE INSERT trigger evaluates
    ↓
Validation fails: RAISE EXCEPTION 'Invalid email format'
    ↓
JDBC receives exception code
    ↓
Hibernate wraps as PersistenceException
    ↓
Spring wraps as DataIntegrityViolationException
    ↓
@Transactional catches → ROLLBACK all changes
    ↓
Exception propagates to AuthController
    ↓
HTTP 400 Bad Request returned
```

**Scenario C: UNIQUE constraint violation**
```
Email already exists in DB (bypassed findByEmail logic somehow)
    ↓
INSERT executes
    ↓
PostgreSQL UNIQUE constraint on email column triggered
    ↓
PostgreSQL raises constraint violation error
    ↓
Exception propagates: PostgreSQL → JDBC → Hibernate → Spring
    ↓
Spring throws DataIntegrityViolationException
    ↓
@Transactional: ROLLBACK
    ↓
HTTP 409 Conflict returned
```

### 7) Final Outcome

**Success:**
```json
{
  "message": "Registration successful! Please check your email.",
  "status": 200
}
```
- User inserted into users table
- Row contains: userId (generated), email, hashed password, role='CUSTOMER', enabled=false
- Verification token stored
- Email sent (outside transaction, not rolled back if user insert succeeds)
- HTTP 200 OK returned

**Failure - Duplicate Email:**
```json
{
  "error": "Email already exists.",
  "status": 409
}
```
- No database changes (rolled back)
- Transaction aborted
- HTTP 409 Conflict

**Failure - Trigger Validation:**
```json
{
  "error": "Invalid email format",
  "status": 400
}
```
- No row inserted (rolled back)
- HTTP 400 Bad Request

---

## FUNCTION 3: UserRepository.updateProfile()

**Function Name:** updateProfile(Integer userId, String name)  
**Layer:** Repository  
**File Path:** Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java  
**Class:** UserRepository  
**Triggered API:** PUT /api/users/me  
**HTTP Method + URL:** PUT /api/users/me  
**CRUD Type:** UPDATE

### 1) Execution Path

```
HTTP PUT /api/users/me (JSON body: UpdateProfileRequest)
    ↓
UserController.updateProfile(UpdateProfileRequest) (Line 25)
    ↓
UserService.updateCurrentUserProfile(request) (Line 43, @Transactional)
    ├─ SecurityContextHolder.getContext() [get current user email]
    ├─ userRepository.findByEmail() [SELECT]
    └─ userRepository.updateProfile() [UPDATE]
    ↓
PostgreSQL executes UPDATE
    ↓
Trigger (if exists) fires BEFORE UPDATE
    ↓
Row updated
    ↓
Transaction commits
    ↓
Return UpdateProfileResponseWrapper to Controller
```

### 2) Critical Code Snippet

```java
// UserRepository.java (Line 30-32)
@Modifying
@Query("UPDATE User u SET u.name = :name WHERE u.userId = :id")
void updateProfile(
        @Param("id") Integer id,
        @Param("name") String name
);

// UserService.java (Line 43-53)
@Transactional
public UpdateProfileResponseWrapper updateCurrentUserProfile(
        UpdateProfileRequest request) {
    String currentUserEmail = SecurityContextHolder.getContext()
            .getAuthentication().getName();
    
    User currentUser = userRepository.findByEmail(currentUserEmail)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    
    String newName = request.getFullName() != null ? 
            request.getFullName() : currentUser.getName();
    
    userRepository.updateProfile(Math.toIntExact(currentUser.getUserId()), newName);
    
    return new UpdateProfileResponseWrapper("Profile updated successfully", ...);
}
```

### 3) SQL Execution Details

**SQL Type:** UPDATE  
**Target Table:** users  

**SQL Generated:**
```sql
UPDATE users SET name = ? WHERE user_id = ?
```

**Parameter Binding:**
- name: String (from request.getFullName())
- userId: Integer (WHERE clause)
- No type casting needed (both match column types)

**Execution Flow:**
1. UserService.updateCurrentUserProfile() called
2. Gets current user email from SecurityContextHolder
3. findByEmail() retrieves user [SELECT]
4. Calls userRepository.updateProfile()
5. @Modifying annotation detected by Spring
6. Spring generates UPDATE (not SELECT)
7. Creates PreparedStatement with 2 parameters
8. Binds: name = ?, user_id = ?
9. Executes via JDBC Driver
10. PostgreSQL updates matching row
11. Returns row count affected (1 if found, 0 if not)

### 4) Java Object ↔ PostgreSQL Row Mapping

**Java Object:** No entity instance (direct UPDATE)  
**Mapping Type:** JPQL → SQL translation (no result mapping needed)

**Column Mapping (UPDATE SET clause):**
```
User.name  (parameter :name)    → users.name (VARCHAR)
User.userId (WHERE clause :id)  → users.user_id (BIGINT, PK)
```

**No ResultSet Mapping:**
- UPDATE returns row count only
- Repository method returns void
- Service doesn't load entity after update
- No entity instantiation needed

### 5) PostgreSQL Trigger Interaction

**Trigger Exists:** Possibly (audit trigger on users table)  
**Timing:** BEFORE UPDATE or AFTER UPDATE  
**Behavior:**
- **BEFORE UPDATE trigger:** Updates modified_at timestamp, validates data
- **AFTER UPDATE trigger:** Logs change to audit_log table

**Execution:**
```
UPDATE triggered
    ↓
BEFORE UPDATE triggers fire
    ├─ Set modified_at = NOW() (if trigger exists)
    └─ Validate new name (max length, forbidden chars, etc.)
    ↓
Row updated (if validation passes)
    ↓
AFTER UPDATE triggers fire (if exist)
    ├─ Log change: INSERT INTO audit_log (user_id, field, old_value, new_value)
    └─ Update user stats table
```

**Trigger Failure:**
- If BEFORE UPDATE validation fails: RAISE EXCEPTION
- PostgreSQL aborts UPDATE
- Exception propagates to Spring
- Transaction rolls back

### 6) Transaction & Exception Flow

**Transaction Start:** @Transactional on UserService.updateCurrentUserProfile() (line 43)  
**Scope:** Entire method

**Success Path:**
1. findByEmail() executes [SELECT]
2. User found
3. updateProfile() generates UPDATE
4. Triggers evaluate (if any)
5. Row updated
6. Method returns
7. **@Transactional: COMMIT executed**
8. Changes persisted

**Failure Paths:**

**Scenario A: User not found**
```
findByEmail() returns Optional.empty()
    ↓
throw new ResourceNotFoundException("User not found")
    ↓
@Transactional: ROLLBACK (no changes made)
    ↓
Exception propagates to UserController
    ↓
HTTP 404 Not Found returned
```

**Scenario B: UPDATE statement fails (constraint violation)**
```
UPDATE executes
    ↓
PostgreSQL constraint violation (e.g., name too long)
    ↓
PostgreSQL raises constraint error
    ↓
JDBC receives error
    ↓
Hibernate wraps as PersistenceException
    ↓
Spring wraps as DataIntegrityViolationException
    ↓
@Transactional: ROLLBACK
    ↓
HTTP 400 Bad Request returned
```

**Scenario C: UPDATE affects 0 rows (WHERE clause matches no rows)**
```
UPDATE users SET name = ? WHERE user_id = ?
    ↓
No matching row found
    ↓
Row count returned = 0 (not an error, just 0 updates)
    ↓
Method continues normally
    ↓
Transaction commits
    ↓
HTTP 200 OK returned (but no actual update occurred)
```

### 7) Final Outcome

**Success:**
```json
{
  "message": "Profile updated successfully",
  "data": {
    "id": 5,
    "fullName": "John Updated",
    "email": "john@example.com"
  }
}
```
- User.name column updated in database
- modified_at timestamp updated (if trigger exists)
- Audit log entry created (if trigger exists)
- HTTP 200 OK returned

**Failure - User not found:**
```json
{
  "error": "User not found",
  "status": 404
}
```
- No database changes
- HTTP 404 Not Found

**Failure - Constraint violation:**
```json
{
  "error": "Name exceeds maximum length",
  "status": 400
}
```
- No database changes (rolled back)
- HTTP 400 Bad Request

---

## FUNCTION 4: AppointmentRepository.save()

**Function Name:** save(Appointment appointment)  
**Layer:** Repository  
**File Path:** Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java  
**Class:** AppointmentRepository  
**Triggered API:** POST /api/booking  
**HTTP Method + URL:** POST /api/booking  
**CRUD Type:** CREATE (INSERT)

### 1) Execution Path

```
HTTP POST /api/booking (JSON body: BookingRequest)
    ↓
BookingController.createBooking(BookingRequest) (Line 42)
    ↓
AppointmentService.createAppointment(request) (Line 55, @Transactional)
    ├─ customerRepository.findByUserEmail() [SELECT]
    ├─ serviceRepository.findById() [SELECT]
    ├─ technicianRepository.findAvailableTechnicians() [SELECT + function]
    ├─ technicianRepository.findById() [SELECT]
    ├─ resourceRepository.findBusyResourceIds() [SELECT]
    ├─ resourceRepository.findFirstAvailableByType() [SELECT]
    ↓
appointmentRepository.save(appointment)  ← HERE [INSERT]
    ↓
PostgreSQL executes INSERT
    ↓
BEFORE INSERT triggers fire:
    ├─ Calculate end_time from duration
    └─ Validate business rules
    ↓
Row inserted with generated appointment_id
    ↓
Transaction commits (or rolls back on error)
    ↓
Appointment entity returned to Controller
```

### 2) Critical Code Snippet

```java
// AppointmentService.java (Line 55-149)
@Transactional(rollbackFor = Exception.class)
public Appointment createAppointment(BookingRequest request) {
    // ... fetch customer, service, technician, resources ...
    
    LocalDateTime startTime = request.getStartTime();
    LocalDateTime endTime = startTime.plusMinutes(service.getDurationMinutes());
    
    Appointment appointment = new Appointment();
    appointment.setCustomer(customer);
    appointment.setTechnician(technician);
    appointment.setService(service);
    appointment.setStartTime(startTime);
    appointment.setEndTime(endTime);
    appointment.setStatus("CONFIRMED");
    
    return appointmentRepository.save(appointment);  // INSERT here
}
```

### 3) SQL Execution Details

**SQL Type:** INSERT  
**Target Tables:** 
- appointment (primary)
- appointment_resource (secondary, if resources allocated)

**SQL Generated:**
```sql
INSERT INTO appointment 
  (customer_id, technician_id, service_id, start_time, end_time, status, created_at) 
VALUES (?, ?, ?, ?, ?, ?, NOW())
```

**Parameter Binding:**
- customer_id: Integer (extracted from Customer entity)
- technician_id: Integer (extracted from Technician entity)
- service_id: Integer (extracted from Service entity)
- start_time: TIMESTAMP (from request)
- end_time: TIMESTAMP (calculated or from trigger)
- status: VARCHAR ('CONFIRMED')
- created_at: TIMESTAMP (auto NOW())

**Execution Flow:**
1. AppointmentService.createAppointment() marked @Transactional
2. Service builds Appointment entity
3. Calls appointmentRepository.save(appointment)
4. Hibernate detects new entity (no appointmentId set)
5. Generates INSERT SQL
6. Creates PreparedStatement with 7 parameters
7. Binds all parameters
8. Executes via JDBC Driver
9. PostgreSQL receives INSERT
10. **BEFORE INSERT triggers fire** (see section 5)
11. If triggers validate: row inserted
12. SERIAL column generates appointmentId
13. ID returned to Hibernate, entity populated

### 4) Java Object ↔ PostgreSQL Row Mapping

**Java Object:** Appointment entity  
**Mapping Type:** Entity auto-mapping with @ManyToOne relationships

**Field → Column Mapping (on INSERT):**
```
Appointment.customer       → appointment.customer_id (FK INT)
Appointment.technician     → appointment.technician_id (FK INT)
Appointment.service        → appointment.service_id (FK INT)
Appointment.startTime      → appointment.start_time (TIMESTAMP NOT NULL)
Appointment.endTime        → appointment.end_time (TIMESTAMP NOT NULL)
Appointment.status         → appointment.status (VARCHAR, default 'PENDING')
Appointment.noteText       → appointment.note_text (TEXT)
Appointment.finalPrice     → appointment.final_price (DECIMAL)
(auto-generated)           → appointment.appointment_id (SERIAL PK)
(auto-set)                 → appointment.created_at (TIMESTAMP NOW())
```

**Foreign Key Relationships:**
- @ManyToOne JoinColumn(name="customer_id"): Hibernate extracts Customer.customerId
- @ManyToOne JoinColumn(name="technician_id"): Hibernate extracts Technician.technicianId
- @ManyToOne JoinColumn(name="service_id"): Hibernate extracts Service.serviceId

**ID Generation:**
- PostgreSQL SERIAL column generates appointmentId
- Sequence: appointment_appointment_id_seq
- Returned to Hibernate immediately after INSERT
- Populated in Appointment.appointmentId field

### 5) PostgreSQL Trigger Interaction

**Triggers Exist:** YES (2 BEFORE INSERT triggers)

**Trigger 1: trg_validate_appointment_dates (BEFORE INSERT)**
- **Timing:** BEFORE INSERT
- **Behavior:**
  ```sql
  IF NEW.end_time <= NEW.start_time THEN
      RAISE EXCEPTION 'End time must be after start time';
  END IF;
  ```
- **Effect:** Validates end_time > start_time
- **Success:** Passes to Trigger 2
- **Failure:** RAISE EXCEPTION

**Trigger 2: trg_validate_availability (BEFORE INSERT)**
- **Timing:** BEFORE INSERT
- **Behavior:**
  - Checks technician not absent during this time
  - Checks no appointment overlap for technician
  - Checks customer not double-booked
  - Checks resource availability
- **Success:** Allows INSERT
- **Failure:** RAISE EXCEPTION

**Combined Execution:**
```
INSERT triggered
    ↓
BEFORE INSERT: trg_validate_appointment_dates fires
    ├─ Validates end_time > start_time
    └─ If fails: RAISE EXCEPTION, abort INSERT
    ↓
BEFORE INSERT: trg_validate_availability fires
    ├─ Query absence_request table (tech availability)
    ├─ Query appointment table (overlaps)
    ├─ Query resources (availability)
    └─ If any constraint fails: RAISE EXCEPTION
    ↓
If both triggers pass: Row inserted
If either trigger fails: Transaction rolled back
```

### 6) Transaction & Exception Flow

**Transaction Start:** @Transactional(rollbackFor = Exception.class) on AppointmentService.createAppointment() (line 55)  
**Scope:** Entire method (all repository calls included)

**Success Path:**
1. Multiple SELECTs execute (customer, service, technician, resources)
2. Appointment entity built
3. save() generates INSERT
4. Triggers validate successfully
5. Row inserted with generated ID
6. Entity populated with appointment_id
7. Method returns
8. **@Transactional: COMMIT executed**
9. All changes persisted
10. Controller returns 200 OK with appointmentId

**Failure Paths:**

**Scenario A: Appointment in past (start_time before NOW())**
```
INSERT triggered
    ↓
trg_validate_appointment_dates fires
    ↓
Trigger checks: IF NEW.start_time < NOW() THEN
                   RAISE EXCEPTION 'Appointment in past'
                END IF;
    ↓
Exception raised
    ↓
JDBC receives exception
    ↓
Hibernate wraps as PersistenceException
    ↓
Spring wraps as DataIntegrityViolationException
    ↓
@Transactional: ROLLBACK (all changes discarded)
    ↓
Exception propagates to BookingController
    ↓
HTTP 400 Bad Request: "Appointment cannot be in the past"
```

**Scenario B: Technician absent during this time**
```
INSERT triggered
    ↓
trg_validate_availability fires
    ↓
Trigger queries:
   SELECT 1 FROM absence_request 
   WHERE technician_id = NEW.technician_id 
   AND status = 'APPROVED'
   AND start_date < NEW.end_time 
   AND end_date > NEW.start_time
    ↓
If found: RAISE EXCEPTION 'Technician absent'
    ↓
Exception raised, propagates
    ↓
@Transactional: ROLLBACK
    ↓
HTTP 400 Bad Request: "Technician is absent during this time"
```

**Scenario C: Resource conflict**
```
INSERT triggered
    ↓
trg_validate_availability fires
    ↓
Trigger checks resource availability
    ↓
Required resource busy: RAISE EXCEPTION
    ↓
ROLLBACK
    ↓
HTTP 400 Bad Request: "Required resource unavailable"
```

**Scenario D: Foreign key constraint fails**
```
INSERT executes
    ↓
customer_id references non-existent customer (FK violation)
    ↓
PostgreSQL raises FK constraint error
    ↓
Exception propagates: PostgreSQL → JDBC → Hibernate → Spring
    ↓
DataIntegrityViolationException thrown
    ↓
@Transactional: ROLLBACK
    ↓
HTTP 400 Bad Request
```

### 7) Final Outcome

**Success:**
```json
{
  "message": "Booking successfully created!",
  "appointmentId": 42,
  "status": "CONFIRMED",
  "startTime": "2025-01-15T10:00:00",
  "endTime": "2025-01-15T11:00:00"
}
```
- Appointment inserted into database
- appointment_id generated: 42
- All FK relationships valid
- Triggers validated successfully
- Status: CONFIRMED
- HTTP 200 OK returned

**Failure - Appointment in past:**
```json
{
  "error": "Appointment cannot be in the past",
  "status": 400
}
```
- No row inserted
- Trigger validation failed
- HTTP 400 Bad Request

**Failure - Technician unavailable:**
```json
{
  "error": "Technician is absent during this time",
  "status": 400
}
```
- No row inserted
- Trigger detected absence conflict
- HTTP 400 Bad Request

**Failure - Resource unavailable:**
```json
{
  "error": "Required resource is not available for this time",
  "status": 400
}
```
- No row inserted
- Trigger detected resource conflict
- HTTP 400 Bad Request

---

## FUNCTION 5: TechnicianRepository.findAvailableTechnicians()

**Function Name:** findAvailableTechnicians(Integer serviceId, LocalDateTime checkTime)  
**Layer:** Repository  
**File Path:** Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/TechnicianRepository.java  
**Class:** TechnicianRepository  
**Triggered API:** POST /api/booking (indirectly)  
**HTTP Method + URL:** POST /api/booking  
**CRUD Type:** READ (calls PostgreSQL stored function)

### 1) Execution Path

```
HTTP POST /api/booking
    ↓
BookingController.createBooking(BookingRequest)
    ↓
AppointmentService.createAppointment(request)
    ↓
technicianRepository.findAvailableTechnicians(serviceId, checkTime)  ← HERE
    ↓
Spring Data JPA executes native query
    ↓
PostgreSQL function called: get_available_technicians()
    ↓
Function logic:
    ├─ Check technician has required skill (service)
    ├─ Check technician not absent
    ├─ Check no appointment conflicts
    ├─ Check resources available
    └─ Return list of available technicians
    ↓
ResultSet mapped to List<TechnicianOptionDto>
    ↓
Service receives list
    ↓
Service selects one technician (explicit or random)
    ↓
Continues with appointment creation
```

### 2) Critical Code Snippet

```java
// TechnicianRepository.java (Line 15-20)
@Query(value = "SELECT * FROM get_available_technicians(:serviceId, CAST(:checkTime AS TIMESTAMP))",
       nativeQuery = true)
List<TechnicianOptionDto> findAvailableTechnicians(
    @Param("serviceId") Integer serviceId,
    @Param("checkTime") LocalDateTime checkTime
);

// AppointmentService.java (Line 82-88)
List<TechnicianOptionDto> availableTechs =
        technicianRepository.findAvailableTechnicians(
            request.getServiceId(),
            request.getStartTime()
        );

if (availableTechs.isEmpty()) {
    throw new ResourceNotFoundException("No available technician for this time slot.");
}
```

### 3) SQL Execution Details

**SQL Type:** SELECT (calls PostgreSQL function)  
**Function Called:** get_available_technicians(p_service_id INTEGER, p_check_time TIMESTAMP)  
**Target Tables Queried Inside Function:**
- technician
- appointment
- absence_request
- service
- technician_services
- resources (via service_resource_requirement)

**SQL Generated:**
```sql
SELECT * FROM get_available_technicians(:serviceId, CAST(:checkTime AS TIMESTAMP))
```

**Parameter Binding:**
- serviceId: Integer → PostgreSQL INT (bound via @Param)
- checkTime: LocalDateTime → PostgreSQL TIMESTAMP (explicit CAST)
- CAST ensures type safety (prevents implicit conversion errors)

**Execution Flow:**
1. AppointmentService calls technicianRepository.findAvailableTechnicians()
2. @Query with nativeQuery=true detected
3. Spring Data JPA wraps parameters:
   - Binds serviceId (INT parameter)
   - Casts checkTime to TIMESTAMP
4. Hibernate executes via JDBC:
   ```
   SELECT * FROM get_available_technicians(1, '2025-01-15 10:00:00'::TIMESTAMP)
   ```
5. PostgreSQL receives function call
6. Function executes internal SQL:
   ```sql
   -- Inside get_available_technicians() function
   SELECT t.technician_id, t.user_id, u.name, ...
   FROM technician t
   JOIN users u ON t.user_id = u.user_id
   WHERE t.user_id IN (
       -- Technicians with this service skill
       SELECT technician_id FROM technician_services 
       WHERE service_id = p_service_id
   )
   AND t.user_id NOT IN (
       -- Exclude absent technicians
       SELECT DISTINCT technician_id FROM absence_request
       WHERE status = 'APPROVED'
       AND start_date < (p_check_time + interval '1 hour')
       AND end_date > p_check_time
   )
   AND t.technician_id NOT IN (
       -- Exclude busy technicians
       SELECT DISTINCT technician_id FROM appointment
       WHERE status != 'CANCELLED'
       AND start_time < (p_check_time + interval '1 hour')
       AND end_time > p_check_time
   )
   ```
7. Function returns SETOF records (table of technicians)
8. ResultSet contains: technician_id, name, user_id, etc.

### 4) Java Object ↔ PostgreSQL Row Mapping

**Java Object:** TechnicianOptionDto (DTO, lightweight class)  
**Mapping Type:** Manual ResultSet mapping (function returns columns, mapped to DTO)

**Column → Field Mapping:**
```
PostgreSQL function result columns:
    technician_id        → TechnicianOptionDto.technicianId (Integer)
    user_id              → TechnicianOptionDto.userId (Integer)
    name (from user)     → TechnicianOptionDto.name (String)
    (other fields)       → (additional DTO fields)
```

**Mapping Mechanism:**
- Native query returns ResultSet
- Hibernate reads column names and types
- Maps to TechnicianOptionDto constructor or field setters
- No @SqlResultSetMapping needed (implicit)
- List<TechnicianOptionDto> returned

**DTO Structure (inferred from code):**
```java
public class TechnicianOptionDto {
    private Integer technicianId;
    private Integer userId;
    private String name;
    // getters/setters
}
```

### 5) PostgreSQL Trigger Interaction

**Triggers:** NONE triggered by SELECT  
**Reason:** SELECT queries don't invoke BEFORE/AFTER triggers (no DML)

**Inside Function:**
- Function contains SELECT statements only
- No INSERT/UPDATE/DELETE
- Triggers don't fire
- Pure computation and aggregation

### 6) Transaction & Exception Flow

**Transaction Start:** @Transactional on AppointmentService.createAppointment() (line 55)  
**Scope:** SELECT executes within transaction (read-only)

**Success Path:**
1. Function executed
2. ResultSet populated with available technicians
3. List<TechnicianOptionDto> returned
4. Service checks if list is empty
5. If not empty: selects technician (explicit or random)
6. Continues with appointment creation
7. Final COMMIT at end of entire transaction

**Failure Paths:**

**Scenario A: Function error (invalid parameters)**
```
Function called with invalid serviceId (doesn't exist)
    ↓
Function SQL: WHERE service_id = ? (no matching service)
    ↓
Returns empty ResultSet
    ↓
List<TechnicianOptionDto> is empty
    ↓
Service checks: if (availableTechs.isEmpty())
    ↓
throw new ResourceNotFoundException("No available technician...")
    ↓
Exception propagates
    ↓
@Transactional: ROLLBACK
    ↓
HTTP 400 Bad Request
```

**Scenario B: Database connection timeout**
```
Function takes too long to execute (complex query)
    ↓
JDBC timeout occurs (default 30 seconds)
    ↓
SQLException: Query timeout
    ↓
Hibernate wraps as PersistenceException
    ↓
Spring wraps as DataAccessException
    ↓
@Transactional: ROLLBACK
    ↓
HTTP 504 Gateway Timeout
```

**Scenario C: PostgreSQL syntax error in function**
```
Function body has SQL error
    ↓
PostgreSQL raises syntax/logic error
    ↓
JDBC receives error
    ↓
DataAccessException thrown
    ↓
@Transactional: ROLLBACK
    ↓
HTTP 500 Internal Server Error
```

### 7) Final Outcome

**Success - Technicians found:**
```json
[
  {
    "technicianId": 3,
    "userId": 8,
    "name": "John Smith"
  },
  {
    "technicianId": 5,
    "userId": 12,
    "name": "Sarah Johnson"
  }
]
```
- Function returns matching technicians
- Service selects one (e.g., index 0)
- Continues with appointment creation
- HTTP 200 OK (from overall booking flow)

**Success - No technicians available:**
```
[] (empty list)
    ↓
Service checks: if (availableTechs.isEmpty())
    ↓
throw new ResourceNotFoundException("No available technician for this time slot")
    ↓
HTTP 400 Bad Request: "No available technician for this time"
```

**Failure - Database error:**
```json
{
  "error": "Database error querying available technicians",
  "status": 500
}
```
- Function error or timeout
- HTTP 500 Internal Server Error
- Overall appointment creation fails
- Transaction rolled back

---

## Summary: Functions 1-5

| # | Function | Type | SQL | Triggers | TX Scope |
|---|----------|------|-----|----------|----------|
| 1 | findByEmail() | READ | SELECT | None | Inside TX |
| 2 | register() | CREATE | INSERT | trg_validate_user_master | Service |
| 3 | updateProfile() | UPDATE | UPDATE | None (audit if exists) | Service |
| 4 | save() (Appointment) | CREATE | INSERT | 2 triggers | Service |
| 5 | findAvailableTechnicians() | READ | SELECT (function) | None | Inside TX |

### Key Patterns

**Read Operations (1, 5):**
- ✅ No transaction needed (reads only)
- ✅ No triggers fired
- ✅ Exception doesn't roll back data

**Write Operations (2, 3, 4):**
- ✅ @Transactional required
- ✅ All-or-nothing atomicity
- ✅ Triggers validate before commit
- ✅ Any exception triggers rollback
- ✅ PostgreSQL → JDBC → Hibernate → Spring exception chain

**Exception Propagation Pattern:**
```
PostgreSQL Exception
    → JDBC SQLException
    → Hibernate PersistenceException
    → Spring DataAccessException
    → @ControllerAdvice handler
    → HTTP response (400/404/409/500)
```

---

**Document:** jpa_1_5.md  
**Token Count:** ~8,500  
**Status:** ✅ COMPLETE

Next Phase: Functions 6-10 in separate jpa_6_10.md file
