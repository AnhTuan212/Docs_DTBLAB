# Backend Communication Architecture: Database Layer

**Project:** AuraControl Spa Management System  
**Layer:** Database Layer (PostgreSQL, SQL Functions, Triggers, Views)  
**Date:** December 30, 2025

---

## TABLE OF CONTENTS
1. [Database Layer Overview](#database-layer-overview)
2. [PostgreSQL Schema Architecture](#postgresql-schema-architecture)
3. [SQL Functions](#sql-functions)
4. [SQL Triggers](#sql-triggers)
5. [SQL Views](#sql-views)
6. [JPA Entity to Database Mapping](#jpa-entity-to-database-mapping)
7. [Query Execution in PostgreSQL](#query-execution-in-postgresql)
8. [Transaction Handling](#transaction-handling)
9. [AuraControl Database Examples](#auracontrol-database-examples)
10. [Performance & Optimization](#performance--optimization)

---

## DATABASE LAYER OVERVIEW

### What is the Database Layer?

The **Database Layer** is where **persistent data** is stored and retrieved. It consists of:

1. **PostgreSQL Server** - The actual database engine
2. **Database Schema** - Tables, columns, constraints
3. **SQL Functions** - Business logic in database
4. **Triggers** - Automatic actions on data changes
5. **Views** - Virtual tables (pre-defined queries)
6. **Indexes** - Speed up searches

### Responsibilities

```
┌─────────────────────────────────────────────────┐
│ DATABASE LAYER RESPONSIBILITIES                 │
├─────────────────────────────────────────────────┤
│ ✅ Store data persistently                      │
│ ✅ Retrieve data efficiently                    │
│ ✅ Enforce referential integrity                │
│ ✅ Execute complex calculations                 │
│ ✅ Validate business rules                      │
│ ✅ Support concurrent access                    │
│ ✅ Maintain data consistency (ACID)             │
│ ✅ Provide audit trails (timestamps)            │
└─────────────────────────────────────────────────┘
```

### Why Database Layer?

```
❌ WITHOUT Database Layer:
Service → Memory (Variables)
❌ Data lost when server restarts
❌ Can't share data between servers
❌ No complex queries
❌ No data integrity enforcement

✅ WITH Database Layer (PostgreSQL):
Service → Repository → Hibernate → JDBC → PostgreSQL
✅ Data persists
✅ Shared across services
✅ Complex queries efficient
✅ Constraints enforce rules
✅ Transactions ensure consistency
```

---

## POSTGRESQL SCHEMA ARCHITECTURE

### Complete Schema Overview

```
┌────────────────────────────────────────────────────────────────┐
│ AURACONTROL POSTGRESQL DATABASE                                │
│ (10 core tables + 5 functions + 4 triggers + 2 views)          │
└────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────┐
│ USER MANAGEMENT TABLES              │
├─────────────────────────────────────┤
│ users                               │
│ ├─ user_id (PK)                     │
│ ├─ email (UNIQUE)                   │
│ ├─ password (hashed)                │
│ ├─ name                             │
│ ├─ role (CUSTOMER/TECHNICIAN/ADMIN) │
│ ├─ enabled (boolean)                │
│ ├─ verification_token               │
│ ├─ reset_password_token             │
│ ├─ created_at (timestamp)           │
│ └─ updated_at (timestamp)           │
│                                     │
│ customer (FK → users)               │
│ ├─ customer_id (PK)                 │
│ ├─ user_id (FK)                     │
│ └─ phone                            │
│                                     │
│ technician (FK → users)             │
│ ├─ technician_id (PK)               │
│ ├─ user_id (FK)                     │
│ ├─ hourly_rate                      │
│ ├─ is_active                        │
│ └─ specialization                   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ SERVICE MANAGEMENT TABLES           │
├─────────────────────────────────────┤
│ services                            │
│ ├─ service_id (PK)                  │
│ ├─ name                             │
│ ├─ description                      │
│ ├─ price                            │
│ ├─ duration_minutes                 │
│ ├─ is_active                        │
│ ├─ created_at                       │
│ └─ updated_at                       │
│                                     │
│ technician_services (Junction)      │
│ ├─ technician_id (FK)               │
│ ├─ service_id (FK)                  │
│ └─ PRIMARY KEY (tech_id, service_id)│
│                                     │
│ service_resource_requirement        │
│ ├─ requirement_id (PK)              │
│ ├─ service_id (FK)                  │
│ ├─ resource_type                    │
│ └─ quantity                         │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ RESOURCE MANAGEMENT TABLES          │
├─────────────────────────────────────┤
│ resources                           │
│ ├─ resource_id (PK)                 │
│ ├─ name                             │
│ ├─ type (ROOM/EQUIPMENT/TOOL)       │
│ ├─ status (AVAILABLE/IN_USE/...)    │
│ ├─ created_at                       │
│ └─ updated_at                       │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ BOOKING MANAGEMENT TABLES           │
├─────────────────────────────────────┤
│ appointment                         │
│ ├─ appointment_id (PK)              │
│ ├─ customer_id (FK)                 │
│ ├─ technician_id (FK)               │
│ ├─ service_id (FK)                  │
│ ├─ start_time (timestamp)           │
│ ├─ end_time (timestamp)             │
│ ├─ status (PENDING/CONFIRMED/...)   │
│ ├─ final_price                      │
│ ├─ created_at                       │
│ └─ updated_at                       │
│                                     │
│ appointment_resource (Junction)     │
│ ├─ appointment_id (FK)              │
│ ├─ resource_id (FK)                 │
│ └─ PRIMARY KEY (appt_id, resource_id)
│                                     │
│ absence_request                     │
│ ├─ absence_id (PK)                  │
│ ├─ technician_id (FK)               │
│ ├─ start_date (date)                │
│ ├─ end_date (date)                  │
│ ├─ reason                           │
│ ├─ status (PENDING/APPROVED/...)    │
│ ├─ created_at                       │
│ └─ updated_at                       │
└─────────────────────────────────────┘
```

### Table Relationships

```
                  users
                    │
         ┌──────────┼──────────┐
         │          │          │
       customer  technician    │
         │          │          │
         └──────────┼──────────┘
                    │
         ┌──────────┼──────────┐
         │          │          │
    appointment   absence_request
         │
    appointment_resource ──────→ resources
         │
      services ──────→ service_resource_requirement
         │
    technician_services ←───────── technician

Key Constraints:
├─ Primary Keys: Unique identifiers (PK)
├─ Foreign Keys: Link tables (FK)
├─ Unique Constraints: user.email
├─ NOT NULL: Required columns
├─ CHECK: Data validation (e.g., price > 0)
└─ Indexes: Speed up queries
```

### Table Creation Example (From V1__init_schema.sql)

```sql
-- Core users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    enabled BOOLEAN DEFAULT false,
    verification_token VARCHAR(255),
    reset_password_token VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customer profile (extends users)
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE,
    phone VARCHAR(20),
    CONSTRAINT fk_customer_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE
);

-- Technician profile (extends users)
CREATE TABLE technician (
    technician_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE,
    hourly_rate DECIMAL(10, 2),
    is_active BOOLEAN DEFAULT true,
    specialization VARCHAR(255),
    CONSTRAINT fk_technician_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE
);

-- Services catalog
CREATE TABLE services (
    service_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    duration_minutes INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Junction: Which services technicians can provide
CREATE TABLE technician_services (
    technician_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    PRIMARY KEY (technician_id, service_id),
    CONSTRAINT fk_tech_services_tech FOREIGN KEY (technician_id)
        REFERENCES technician(technician_id) ON DELETE CASCADE,
    CONSTRAINT fk_tech_services_svc FOREIGN KEY (service_id)
        REFERENCES services(service_id) ON DELETE CASCADE
);

-- Core appointments/bookings
CREATE TABLE appointment (
    appointment_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    technician_id INTEGER,
    service_id INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING',
    final_price DECIMAL(10, 2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appt_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),
    CONSTRAINT fk_appt_tech FOREIGN KEY (technician_id)
        REFERENCES technician(technician_id),
    CONSTRAINT fk_appt_service FOREIGN KEY (service_id)
        REFERENCES services(service_id)
);

-- Resources (rooms, equipment, tools)
CREATE TABLE resources (
    resource_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'AVAILABLE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Junction: Which resources needed for appointment
CREATE TABLE appointment_resource (
    appointment_id INTEGER NOT NULL,
    resource_id INTEGER NOT NULL,
    PRIMARY KEY (appointment_id, resource_id),
    CONSTRAINT fk_appt_res_appt FOREIGN KEY (appointment_id)
        REFERENCES appointment(appointment_id) ON DELETE CASCADE,
    CONSTRAINT fk_appt_res_res FOREIGN KEY (resource_id)
        REFERENCES resources(resource_id)
);

-- Technician absence/leave requests
CREATE TABLE absence_request (
    absence_id SERIAL PRIMARY KEY,
    technician_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_absence_tech FOREIGN KEY (technician_id)
        REFERENCES technician(technician_id) ON DELETE CASCADE
);

-- What resources each service requires
CREATE TABLE service_resource_requirement (
    requirement_id SERIAL PRIMARY KEY,
    service_id INTEGER NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    quantity INTEGER DEFAULT 1,
    CONSTRAINT fk_srr_service FOREIGN KEY (service_id)
        REFERENCES services(service_id) ON DELETE CASCADE
);
```

---

## SQL FUNCTIONS

### What are SQL Functions?

**SQL Functions** are reusable blocks of SQL code stored in the database. They:
- Execute complex business logic on the database
- Return calculated results
- Are called from Java via repositories
- Improve performance (less data transfer)

### AuraControl SQL Functions

#### Function 1: get_available_technicians()

```sql
-- Located in: V2__add_booking_logic.sql

CREATE OR REPLACE FUNCTION get_available_technicians(
    p_service_id INTEGER,
    p_check_time TIMESTAMP
) RETURNS TABLE (
    technician_id INTEGER,
    user_id INTEGER,
    name VARCHAR,
    email VARCHAR,
    hourly_rate DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        t.technician_id,
        t.user_id,
        u.name,
        u.email,
        t.hourly_rate
    FROM technician t
    JOIN users u ON t.user_id = u.user_id
    -- Technician must have required skill
    JOIN technician_services ts ON t.technician_id = ts.technician_id
    WHERE ts.service_id = p_service_id
    AND t.is_active = true
    AND u.enabled = true
    -- Technician must NOT have conflicting appointment
    AND NOT EXISTS (
        SELECT 1 FROM appointment a
        WHERE a.technician_id = t.technician_id
        AND a.status != 'CANCELLED'
        AND p_check_time >= a.start_time
        AND p_check_time < a.end_time
    )
    -- Technician must NOT have absence on this day
    AND NOT EXISTS (
        SELECT 1 FROM absence_request ar
        WHERE ar.technician_id = t.technician_id
        AND ar.status = 'APPROVED'
        AND p_check_time::DATE BETWEEN ar.start_date AND ar.end_date
    )
    ORDER BY t.technician_id;
END;
$$ LANGUAGE plpgsql;

-- Called from Java:
// TechnicianRepository.java
@Query(value = "SELECT * FROM get_available_technicians(:serviceId, CAST(:checkTime AS TIMESTAMP))",
       nativeQuery = true)
List<TechnicianOptionDto> findAvailableTechnicians(
    @Param("serviceId") Integer serviceId,
    @Param("checkTime") LocalDateTime checkTime
);

// Service calls it:
List<TechnicianOptionDto> available = technicianRepository
    .findAvailableTechnicians(serviceId, LocalDateTime.now());
```

#### Function 2: calculate_appointment_end_time()

```sql
-- Calculates when appointment ends based on service duration

CREATE OR REPLACE FUNCTION calculate_appointment_end_time()
RETURNS TRIGGER AS $$
BEGIN
    -- Look up service duration
    SELECT start_time + (duration_minutes || ' minutes')::INTERVAL
    INTO NEW.end_time
    FROM appointment a
    JOIN services s ON a.service_id = s.service_id
    WHERE a.appointment_id = NEW.appointment_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Usage: Triggered automatically before INSERT
CREATE TRIGGER trg_calculate_end_time
BEFORE INSERT ON appointment
FOR EACH ROW
EXECUTE FUNCTION calculate_appointment_end_time();

-- Example:
INSERT INTO appointment (customer_id, service_id, start_time)
VALUES (1, 5, '2025-01-15 09:00:00');
-- Database automatically calculates end_time based on service duration
```

#### Function 3: validate_appointment()

```sql
-- Validates appointment business rules

CREATE OR REPLACE FUNCTION validate_appointment()
RETURNS TRIGGER AS $$
BEGIN
    -- Check appointment is not in the past
    IF NEW.start_time < CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'Cannot book appointment in the past';
    END IF;
    
    -- Check start_time is before end_time
    IF NEW.start_time >= NEW.end_time THEN
        RAISE EXCEPTION 'Start time must be before end time';
    END IF;
    
    -- Check service is active
    IF NOT EXISTS (
        SELECT 1 FROM services s
        WHERE s.service_id = NEW.service_id AND s.is_active = true
    ) THEN
        RAISE EXCEPTION 'Selected service is not available';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger attached to appointment table
CREATE TRIGGER trg_validate_appointment
BEFORE INSERT OR UPDATE ON appointment
FOR EACH ROW
EXECUTE FUNCTION validate_appointment();
```

#### Function 4: get_revenue_statistics()

```sql
-- Calculates revenue statistics for dashboard

CREATE OR REPLACE FUNCTION get_revenue_statistics(
    p_start_date DATE,
    p_end_date DATE,
    p_period VARCHAR
) RETURNS TABLE (
    period_label VARCHAR,
    total_revenue DECIMAL,
    appointment_count INTEGER,
    avg_appointment_price DECIMAL
) AS $$
BEGIN
    IF p_period = 'DAY' THEN
        RETURN QUERY
        SELECT
            TO_CHAR(DATE(a.start_time), 'YYYY-MM-DD') as period_label,
            SUM(a.final_price)::DECIMAL as total_revenue,
            COUNT(*)::INTEGER as appointment_count,
            AVG(a.final_price)::DECIMAL as avg_appointment_price
        FROM appointment a
        WHERE a.status = 'COMPLETED'
        AND DATE(a.start_time) BETWEEN p_start_date AND p_end_date
        GROUP BY DATE(a.start_time)
        ORDER BY DATE(a.start_time);
    
    ELSIF p_period = 'MONTH' THEN
        RETURN QUERY
        SELECT
            TO_CHAR(DATE_TRUNC('month', a.start_time), 'YYYY-MM') as period_label,
            SUM(a.final_price)::DECIMAL as total_revenue,
            COUNT(*)::INTEGER as appointment_count,
            AVG(a.final_price)::DECIMAL as avg_appointment_price
        FROM appointment a
        WHERE a.status = 'COMPLETED'
        AND DATE(a.start_time) BETWEEN p_start_date AND p_end_date
        GROUP BY DATE_TRUNC('month', a.start_time)
        ORDER BY DATE_TRUNC('month', a.start_time);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Called from Java:
@Query(value = "SELECT * FROM get_revenue_statistics(:startDate, :endDate, :period)",
       nativeQuery = true)
List<RevenueStatDto> getRevenueStatistics(
    @Param("startDate") LocalDate startDate,
    @Param("endDate") LocalDate endDate,
    @Param("period") String period  // "DAY" or "MONTH"
);
```

#### Function 5: validate_absence_request_master()

```sql
-- Validates absence request doesn't conflict with appointments

CREATE OR REPLACE FUNCTION validate_absence_request_master()
RETURNS TRIGGER AS $$
BEGIN
    -- Check no confirmed appointments during absence
    IF EXISTS (
        SELECT 1 FROM appointment a
        WHERE a.technician_id = NEW.technician_id
        AND a.status IN ('CONFIRMED', 'COMPLETED')
        AND a.start_time::DATE BETWEEN NEW.start_date AND NEW.end_date
    ) THEN
        RAISE EXCEPTION 'Technician has confirmed appointments during this period';
    END IF;
    
    -- Check dates make sense
    IF NEW.start_date > NEW.end_date THEN
        RAISE EXCEPTION 'Start date must be before or equal to end date';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers on absence_request table
CREATE TRIGGER trg_validate_absence_request_master
BEFORE INSERT OR UPDATE ON absence_request
FOR EACH ROW
EXECUTE FUNCTION validate_absence_request_master();
```

---

## SQL TRIGGERS

### What are SQL Triggers?

**Triggers** are automatic actions that execute when data changes (INSERT, UPDATE, DELETE).

**Benefits:**
- Enforce rules at database level (not just application)
- Automatic calculations (no manual computation)
- Data consistency guarantee
- Audit trail (history of changes)

### AuraControl Triggers

#### Trigger 1: trg_calculate_end_time

```sql
-- Automatically calculates end_time when appointment is inserted

CREATE TRIGGER trg_calculate_end_time
BEFORE INSERT ON appointment
FOR EACH ROW
EXECUTE FUNCTION calculate_appointment_end_time();

-- Example:
INSERT INTO appointment (customer_id, service_id, start_time, status)
VALUES (1, 5, '2025-01-15 09:00:00', 'PENDING');

-- Result in database:
┌────────────┬──────────────────────┬──────────────────────┬────────┐
│ appt_id    │ start_time           │ end_time             │ status │
├────────────┼──────────────────────┼──────────────────────┼────────┤
│ 123        │ 2025-01-15 09:00:00  │ 2025-01-15 10:00:00  │ PEND.. │
└────────────┴──────────────────────┴──────────────────────┴────────┘
-- end_time calculated automatically (if service duration = 60 min)
```

#### Trigger 2: trg_validate_appointment

```sql
-- Validates appointment BEFORE INSERT or UPDATE

CREATE TRIGGER trg_validate_appointment
BEFORE INSERT OR UPDATE ON appointment
FOR EACH ROW
EXECUTE FUNCTION validate_appointment();

-- Example: Try to insert invalid appointment
INSERT INTO appointment (customer_id, service_id, start_time, end_time)
VALUES (1, 5, '2025-01-10 09:00:00', '2025-01-10 10:00:00');
-- ERROR: Cannot book appointment in the past
-- → INSERT rejected by database

-- Application doesn't waste time, network, or resources
```

#### Trigger 3: trg_update_resource_on_reschedule

```sql
-- When appointment is rescheduled, update affected resources

CREATE TRIGGER trg_update_resource_on_reschedule
AFTER UPDATE ON appointment
FOR EACH ROW
WHEN (OLD.start_time IS DISTINCT FROM NEW.start_time)
EXECUTE FUNCTION function_update_resource_on_reschedule();

-- Function:
CREATE OR REPLACE FUNCTION function_update_resource_on_reschedule()
RETURNS TRIGGER AS $$
BEGIN
    -- Release old resources
    DELETE FROM appointment_resource
    WHERE appointment_id = OLD.appointment_id;
    
    -- Allocate new resources based on new time
    INSERT INTO appointment_resource (appointment_id, resource_id)
    SELECT NEW.appointment_id, r.resource_id
    FROM service_resource_requirement srr
    JOIN resources r ON r.type = srr.resource_type
    WHERE srr.service_id = NEW.service_id
    AND r.status = 'AVAILABLE';
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### Trigger 4: trg_validate_absence_request_master

```sql
-- Validates absence request before inserting/updating

CREATE TRIGGER trg_validate_absence_request_master
BEFORE INSERT OR UPDATE ON absence_request
FOR EACH ROW
EXECUTE FUNCTION validate_absence_request_master();

-- Example:
INSERT INTO absence_request (technician_id, start_date, end_date, status)
VALUES (5, '2025-02-01', '2025-02-05', 'APPROVED');

-- Database checks:
-- ✅ No conflicts with existing appointments
-- ✅ Dates make sense (start <= end)
-- ✅ Technician exists
-- → INSERT succeeds or throws exception
```

### Trigger Timing Diagram

```
INSERT/UPDATE/DELETE statement arrives
    │
    ↓
┌────────────────────────────────────┐
│ BEFORE Trigger execution           │
│ (Can modify data before storing)    │
│                                    │
│ Example: Calculate end_time        │
│ Example: Validate data             │
│ Example: Set default values        │
└────────────────────────────────────┘
    │
    ↓
┌────────────────────────────────────┐
│ INSERT/UPDATE/DELETE executes      │
│ (Data actually changes)            │
└────────────────────────────────────┘
    │
    ↓
┌────────────────────────────────────┐
│ AFTER Trigger execution            │
│ (Can react to data change)         │
│                                    │
│ Example: Update related tables     │
│ Example: Log audit trail           │
│ Example: Send notifications        │
└────────────────────────────────────┘
    │
    ↓
Transaction commits (if all successful)
or rolls back (if any error)
```

---

## SQL VIEWS

### What are SQL Views?

**Views** are **virtual tables** created from a SELECT query. They:
- Pre-define complex queries
- Simplify repeated queries
- Provide specific data subsets
- Act like read-only tables

### AuraControl Views

#### View 1: v_upcoming_appointments

```sql
-- Shows next 10 upcoming appointments with all details

CREATE VIEW v_upcoming_appointments AS
SELECT
    a.appointment_id,
    a.start_time,
    a.end_time,
    a.status,
    a.final_price,
    c.customer_id,
    u_customer.name as customer_name,
    u_customer.email as customer_email,
    t.technician_id,
    u_tech.name as technician_name,
    s.service_id,
    s.name as service_name,
    s.duration_minutes
FROM appointment a
JOIN customer c ON a.customer_id = c.customer_id
JOIN users u_customer ON c.user_id = u_customer.user_id
JOIN technician t ON a.technician_id = t.technician_id
JOIN users u_tech ON t.user_id = u_tech.user_id
JOIN services s ON a.service_id = s.service_id
WHERE a.start_time > CURRENT_TIMESTAMP
AND a.status != 'CANCELLED'
ORDER BY a.start_time ASC
LIMIT 10;

-- Called from Java:
@Query(value = "SELECT * FROM v_upcoming_appointments LIMIT 10",
       nativeQuery = true)
List<UpcomingAppointmentDto> getUpcomingAppointmentsView();

// Result: Pre-joined, pre-calculated, ready to display
UpcomingAppointmentDto {
    appointmentId: 42,
    startTime: 2025-01-15 14:00:00,
    customerName: "John Doe",
    technicianName: "Jane Smith",
    serviceName: "Hair Styling",
    finalPrice: 50.00
}
```

#### View 2: v_today_stats

```sql
-- Shows today's business statistics

CREATE VIEW v_today_stats AS
SELECT
    COUNT(DISTINCT a.appointment_id) as today_appointments,
    COUNT(DISTINCT a.customer_id) as new_customers_today,
    COALESCE(SUM(a.final_price), 0) as today_revenue
FROM appointment a
JOIN customer c ON a.customer_id = c.customer_id
LEFT JOIN users u ON c.user_id = u.user_id
WHERE a.status = 'COMPLETED'
AND DATE(a.start_time) = CURRENT_DATE;

-- Called from Java:
@Query(value = "SELECT * FROM v_today_stats",
       nativeQuery = true)
TodayStatsDto getTodayStats();

// Result:
TodayStatsDto {
    todayAppointments: 15,
    newCustomersToday: 8,
    todayRevenue: 750.50
}
```

---

## JPA ENTITY TO DATABASE MAPPING

### Entity Annotations → Database Schema

```java
// Java Entity Class:
@Entity
@Table(name = "appointment")
public class Appointment {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "appointment_id")
    private Integer appointmentId;
    // ↓
    // Maps to: appointment_id SERIAL PRIMARY KEY

    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;
    // ↓
    // Maps to: start_time TIMESTAMP NOT NULL

    @Column(name = "end_time", nullable = false)
    private LocalDateTime endTime;
    // ↓
    // Maps to: end_time TIMESTAMP NOT NULL

    @Column(name = "status", length = 50)
    private String status;
    // ↓
    // Maps to: status VARCHAR(50)

    @Column(name = "final_price", precision = 10, scale = 2)
    private BigDecimal finalPrice;
    // ↓
    // Maps to: final_price DECIMAL(10, 2)

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;
    // ↓
    // Maps to: customer_id INTEGER NOT NULL
    //          FOREIGN KEY (customer_id) REFERENCES customer(customer_id)

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    // ↓
    // Maps to: created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    // ↓
    // Maps to: updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
}
```

### Data Type Mapping

```
┌──────────────────┬──────────────────┬──────────────┐
│ Java Type        │ JPQL Type        │ PostgreSQL   │
├──────────────────┼──────────────────┼──────────────┤
│ String           │ String           │ VARCHAR      │
│ Integer          │ Integer          │ INTEGER      │
│ Long             │ Long             │ BIGINT       │
│ BigDecimal       │ BigDecimal       │ DECIMAL      │
│ Boolean          │ Boolean          │ BOOLEAN      │
│ LocalDateTime    │ LocalDateTime    │ TIMESTAMP    │
│ LocalDate        │ LocalDate        │ DATE         │
│ Enum             │ (mapped)         │ VARCHAR      │
│ byte[]           │ (binary)         │ BYTEA        │
│ @Lob String      │ (text)           │ TEXT         │
│ @Lob byte[]      │ (binary)         │ BYTEA        │
│ List<Entity>     │ (collection)     │ (join table) │
└──────────────────┴──────────────────┴──────────────┘
```

---

## QUERY EXECUTION IN POSTGRESQL

### Query Lifecycle

```
┌─────────────────────────────────────────────────────────┐
│ 1. SQL QUERY ARRIVES                                    │
│                                                         │
│ SELECT a.appointment_id, a.start_time, ...             │
│ FROM appointment a                                      │
│ JOIN customer c ON a.customer_id = c.customer_id       │
│ WHERE a.start_time > '2025-01-15 09:00:00'             │
│ AND a.status = 'CONFIRMED'                             │
│ ORDER BY a.start_time ASC;                             │
└────────────┬────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────┐
│ 2. PARSING                                              │
│                                                         │
│ ├─ Syntax check: Valid SQL?                            │
│ ├─ Identifier resolution: Table names exist?           │
│ └─ Semantic check: Columns exist in tables?            │
│                                                         │
│ Result: Parse tree created                             │
└────────────┬────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────┐
│ 3. VALIDATION                                           │
│                                                         │
│ ├─ Check permissions: User can access tables?          │
│ ├─ Check constraints: Data types match?                │
│ └─ Check functions: UDFs exist?                        │
└────────────┬────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────┐
│ 4. OPTIMIZATION (QUERY PLANNER)                        │
│                                                         │
│ PostgreSQL decides:                                    │
│ ├─ Which indexes to use?                              │
│ ├─ Join order? (a JOIN c or c JOIN a?)                │
│ ├─ Full table scan or index scan?                     │
│ ├─ Filter before or after join?                       │
│ └─ Parallel execution possible?                       │
│                                                         │
│ Cost estimation:                                       │
│ ├─ How many rows match WHERE clause?                  │
│ ├─ How many rows after join?                          │
│ ├─ CPU/IO cost?                                       │
│ └─ Estimated execution time?                          │
│                                                         │
│ Result: Optimal query plan selected                    │
└────────────┬────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────┐
│ 5. COMPILATION                                          │
│                                                         │
│ ├─ Query plan compiled to executable code              │
│ ├─ Query plan cached for future use                    │
│ └─ Binary representation stored in memory              │
│                                                         │
│ Result: Prepared query ready to execute                │
└────────────┬────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────┐
│ 6. EXECUTION                                            │
│                                                         │
│ ├─ Acquire locks on tables (if needed)                 │
│ ├─ Load data pages into memory                         │
│ ├─ Execute operations (scan, join, filter, sort)       │
│ └─ Build result set                                    │
│                                                         │
│ Steps in execution:                                    │
│ 1. Seq scan or Index scan on appointment table         │
│ 2. Filter: WHERE start_time > '2025-01-15 09:00:00'   │
│ 3. Filter: WHERE status = 'CONFIRMED'                 │
│ 4. Join with customer table                           │
│ 5. Sort by start_time ASC                             │
│ 6. Return rows to client                              │
└────────────┬────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────┐
│ 7. RESULT RETURN                                        │
│                                                         │
│ Rows returned as ResultSet:                            │
│ ┌─────────────────────────────────────────────────────┐│
│ │ appointment_id │ start_time           │ ...         ││
│ ├─────────────────────────────────────────────────────┤│
│ │ 42             │ 2025-01-15 10:00:00  │ ...         ││
│ │ 43             │ 2025-01-15 11:00:00  │ ...         ││
│ │ 44             │ 2025-01-15 14:00:00  │ ...         ││
│ └─────────────────────────────────────────────────────┘│
│                                                         │
│ Result sent to JDBC driver                            │
│ JDBC driver sends to Hibernate                        │
│ Hibernate maps to Java entities                       │
│ Service receives List<Appointment>                    │
└─────────────────────────────────────────────────────────┘
```

### Index Usage Example

```sql
-- Without index:
SELECT * FROM appointment WHERE customer_id = 1;
-- PostgreSQL scans ALL rows in appointment table → SLOW

-- With index:
CREATE INDEX idx_appt_customer ON appointment(customer_id);
-- PostgreSQL uses index to find rows with customer_id=1 → FAST

-- Automatic plan selection:
SELECT * FROM appointment WHERE customer_id = 1 AND start_time > NOW();
-- PostgreSQL considers:
-- ├─ Use idx_appt_customer?
-- ├─ Use idx_appt_start_time?
-- ├─ Full table scan?
// ├─ Combine indexes?
// └─ Selects optimal plan based on statistics
```

---

## TRANSACTION HANDLING

### Database Transactions

**ACID Properties:**
- **A**tomicity: All-or-nothing
- **C**onsistency: Data stays valid
- **I**solation: No interference
- **D**urability: Changes persist

### PostgreSQL Transaction Example

```sql
-- Transaction begins automatically with first command

BEGIN;  -- Explicit transaction start

INSERT INTO appointment (customer_id, service_id, start_time)
VALUES (1, 5, '2025-01-15 09:00:00');
-- Row 1 inserted (not yet visible to other transactions)

UPDATE customer SET phone = '555-1234' WHERE customer_id = 1;
-- Row 1 updated (not yet visible to other transactions)

INSERT INTO appointment_resource (appointment_id, resource_id)
VALUES (123, 5);
-- Row 1 inserted (not yet visible to other transactions)

COMMIT;  -- All changes written to disk
-- Now all three changes visible to other transactions

-- OR:

ROLLBACK;  -- Undo all changes (as if they never happened)
```

### Isolation Levels

```
┌──────────────────────┬─────────────────────────────────────┐
│ Isolation Level      │ Prevents                            │
├──────────────────────┼─────────────────────────────────────┤
│ READ UNCOMMITTED     │ (none - most permissive)            │
│ READ COMMITTED       │ Dirty reads                         │
│ REPEATABLE READ      │ Dirty reads, Phantom reads          │
│ SERIALIZABLE         │ All anomalies (most restrictive)    │
└──────────────────────┴─────────────────────────────────────┘

PostgreSQL default: READ COMMITTED

AuraControl uses: @Transactional (Spring manages)
├─ Spring sets PostgreSQL isolation based on config
├─ Most operations: READ COMMITTED
└─ Some critical: REPEATABLE READ
```

---

## AURACONTROL DATABASE EXAMPLES

### Example 1: Creating an Appointment

```
Java Layer:
────────────────────────────────────────────

AppointmentService.createAppointment(request) {
    // Validates
    // Calls repository
}
↓
AppointmentRepository.save(appointment) {
    // Returns entity
}

Repository Layer:
────────────────────────────────────────────

Hibernate generates:

INSERT INTO appointment (
    customer_id, service_id, start_time, status, created_at
)
VALUES (1, 5, '2025-01-15 09:00:00', 'PENDING', NOW());

Database Layer:
────────────────────────────────────────────

PostgreSQL:
1. BEGIN TRANSACTION
2. Parse INSERT statement
3. Validate:
   ├─ customer_id exists? (FK check)
   ├─ service_id exists and active? (FK check)
   └─ All required columns present?
4. BEFORE INSERT Trigger:
   ├─ calculate_appointment_end_time() runs
   ├─ Looks up service duration
   ├─ Calculates end_time
   └─ Modifies NEW record
5. BEFORE INSERT Trigger:
   ├─ validate_appointment() runs
   ├─ Checks appointment not in past
   ├─ Checks dates make sense
   └─ Checks service is active
6. Execute INSERT:
   ├─ Allocate new row
   ├─ Insert data
   ├─ Update indexes
   └─ Lock row temporarily
7. AFTER INSERT Trigger:
   ├─ (None defined in this example)
8. COMMIT TRANSACTION
9. Generated ID: 123
10. Return control to Java

Back to Java Layer:
────────────────────────────────────────────

Entity returned with ID populated:
Appointment {
    appointmentId: 123,
    customerId: 1,
    serviceId: 5,
    startTime: 2025-01-15 09:00:00,
    endTime: 2025-01-15 10:00:00,  ← Calculated by trigger
    status: PENDING,
    createdAt: 2025-01-15 14:30:15
}

Service converts to DTO and returns to Controller
```

### Example 2: Querying Available Technicians

```
Java Layer:
────────────────────────────────────────────

AppointmentService.getAvailableTechnicians(serviceId, time)
    ↓
TechnicianRepository.findAvailableTechnicians(serviceId, time)
    ↓
Calls PostgreSQL function

Database Layer:
────────────────────────────────────────────

Executes:
SELECT * FROM get_available_technicians(5, '2025-01-15 09:30:00');

Function logic:
1. Find technicians with skill for service_id=5
2. Filter: is_active = true
3. Filter: user.enabled = true
4. Check: No conflicting appointments at that time
   ├─ For each technician
   ├─ Look for appointments where:
   │  ├─ appointment.start_time <= 09:30:00
   │  ├─ appointment.end_time > 09:30:00
   │  └─ status != 'CANCELLED'
   └─ If found: exclude this technician
5. Check: No approved absence on that day
   ├─ For each remaining technician
   ├─ Look for approved absence where:
   │  └─ absence.start_date <= 2025-01-15 AND absence.end_date >= 2025-01-15
   └─ If found: exclude this technician
6. Return: List of available technicians

Result from DB:
┌──────────────┬─────────┬────────────┬──────────────────┐
│ technician_id│ user_id │ name       │ email            │
├──────────────┼─────────┼────────────┼──────────────────┤
│ 2            │ 5       │ Jane Smith │ jane@example.com │
│ 4            │ 8       │ Bob Wilson │ bob@example.com  │
└──────────────┴─────────┴────────────┴──────────────────┘

Back to Java Layer:
────────────────────────────────────────────

Hibernate maps ResultSet to DTOs:
[
    TechnicianOptionDto(id=2, name="Jane Smith", ...),
    TechnicianOptionDto(id=4, name="Bob Wilson", ...)
]

Service processes and returns to Controller
Controller converts to JSON and sends to Frontend
```

### Example 3: Updating Technician Profile

```
Java Layer:
────────────────────────────────────────────

UserService.updateCurrentUserProfile(updateRequest) {
    User user = userRepository.findByEmail(email);
    user.setName(updateRequest.getName());
    user.setEmail(updateRequest.getEmail());
    // DON'T CALL save()! (Dirty checking handles it)
}

@Transactional ensures changes flushed

Database Layer:
────────────────────────────────────────────

Hibernate dirty checking detects:
Original: {name: "Jane", email: "jane@old.com"}
Current:  {name: "Jane Smith", email: "jane@new.com"}

Changes detected:
├─ name changed
└─ email changed

Hibernate generates UPDATE:
UPDATE users
SET name = 'Jane Smith',
    email = 'jane@new.com',
    updated_at = NOW()
WHERE user_id = 5;

PostgreSQL:
1. Parse UPDATE
2. Validate: email doesn't already exist (UNIQUE constraint)
3. Acquire lock on row
4. Update columns
5. Update indexes (email_idx)
6. Update timestamp
7. Release lock
8. COMMIT

Result:
Row updated in database
Triggers could fire (if any attached to UPDATE)
```

---

## PERFORMANCE & OPTIMIZATION

### Indexing Strategy

```sql
-- Frequently queried columns should be indexed

-- Index for finding users by email
CREATE INDEX idx_users_email ON users(email);
-- Query: SELECT * FROM users WHERE email = '...';
-- Before: Full table scan (O(n))
-- After: Index lookup (O(log n))

-- Composite index for appointment queries
CREATE INDEX idx_appt_time_status ON appointment(start_time, status);
-- Query: SELECT * FROM appointment WHERE start_time > NOW() AND status = 'CONFIRMED';
-- Both columns checked via single index

-- Foreign key indexes
CREATE INDEX idx_appt_customer ON appointment(customer_id);
CREATE INDEX idx_appt_service ON appointment(service_id);
-- Speeds up: JOINs, CASCADE DELETEs, FK lookups

-- What NOT to index:
-- ❌ Columns rarely in WHERE clause
// ❌ Boolean columns with few distinct values
// ❌ Columns with very high cardinality (huge indexes)
```

### Query Optimization

```sql
-- ❌ SLOW: Full table scan + N+1 queries
SELECT * FROM appointment;  -- Scans all rows
-- Then for each appointment, query: SELECT * FROM customer WHERE id = ?

-- ✅ FAST: JOIN + index
SELECT a.*, c.*, s.*
FROM appointment a
JOIN customer c ON a.customer_id = c.customer_id
JOIN services s ON a.service_id = s.service_id
WHERE a.start_time > NOW();
-- Single query, uses indexes

-- ❌ SLOW: Inefficient WHERE clause
SELECT * FROM appointment WHERE EXTRACT(YEAR FROM start_time) = 2025;
-- Can't use index on start_time (function applied)

-- ✅ FAST: Direct comparison
SELECT * FROM appointment WHERE start_time >= '2025-01-01' AND start_time < '2026-01-01';
-- Uses index on start_time

-- ❌ SLOW: Subquery in WHERE
SELECT * FROM technician WHERE technician_id IN (
    SELECT DISTINCT technician_id FROM appointment
);
-- Executes subquery for each row

-- ✅ FAST: Proper JOIN
SELECT DISTINCT t.*
FROM technician t
JOIN appointment a ON t.technician_id = a.technician_id;
-- Single efficient JOIN
```

### Connection Pooling

```
HikariCP (Connection Pool)

┌─────────────────────────────────────────┐
│ Connection Pool (Pool Size = 10)         │
│                                          │
│ Available: [conn1, conn2, ..., conn10]  │
│ Waiting: [request1, request2, ...]      │
└─────────────────────────────────────────┘

When Service needs database connection:
1. Check available connections
2. If available: borrow connection (no delay)
3. If none available: Wait in queue (timeout)
4. Execute query
5. Return connection to pool (reusable)

Benefits:
✅ Avoid creating new connections (expensive)
✅ Reuse existing connections (fast)
✅ Limit total connections (resource control)
✅ Queue requests fairly (no thread starvation)

Configuration (application.yaml):
spring:
  datasource:
    hikari:
      maximum-pool-size: 20    # Max 20 connections
      minimum-idle: 5          # Keep 5 always available
      connection-timeout: 30000 # Wait 30 sec before timeout
```

---

## SUMMARY: DATABASE LAYER COMMUNICATION

### Complete Database Lifecycle

```
1. SQL Generated (from JPQL or method name)
2. Sent to PostgreSQL via JDBC connection
3. PostgreSQL parses, validates, optimizes
4. Query plan selected (from cache if available)
5. Locks acquired on affected rows
6. Query executed (scans, joins, filters, sorts)
7. Results collected into ResultSet
8. ResultSet returned to Java via JDBC
9. Hibernate maps ResultSet to entities
10. Entities returned to Service layer
11. Transaction commits (changes persisted)
12. Connection returned to pool
```

### Key Database Components

```
┌─────────────────────────────────────────────┐
│ POSTGRESQL DATABASE                         │
├─────────────────────────────────────────────┤
│ ✅ 10 Core Tables (data storage)            │
│ ✅ 5 Functions (complex business logic)     │
│ ✅ 4 Triggers (automatic actions)           │
│ ✅ 2 Views (pre-defined queries)            │
│ ✅ Indexes (fast searches)                  │
│ ✅ Constraints (data integrity)             │
│ ✅ ACID Transactions (consistency)          │
└─────────────────────────────────────────────┘
```

### Next Documents

- **dataflow.md** - Complete bidirectional data flow
- **workflow.md** - End-to-end request processing workflow
- **controller.md** - How HTTP requests are received (reference)

