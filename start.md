# 🎯 AuraControl Spa Management System - Getting Started Guide

**Welcome!** This guide will help you understand the AuraControl project and navigate all the documentation.

---

## TABLE OF CONTENTS

1. [What is AuraControl?](#what-is-auracontrol)
2. [Project Overview](#project-overview)
3. [Technology Stack](#technology-stack)
4. [How to Read the Documentation](#how-to-read-the-documentation)
5. [Reading Order & File Guide](#reading-order--file-guide)
6. [Quick Project Map](#quick-project-map)
7. [Common Questions](#common-questions)

---

## WHAT IS AURACONTROL?

### In Simple Terms

**AuraControl** is a **web-based spa management system** that helps spa businesses manage:
- 💇 **Customers** - Who books appointments
- 👨‍💼 **Technicians/Staff** - Who provides services
- 🛁 **Services** - What they offer (massage, haircut, facial, etc.)
- 📅 **Appointments** - When customers book services
- 🏢 **Resources** - Rooms, equipment, tools needed for services
- ⏱️ **Absence Requests** - When staff takes time off

### Real-World Example

```
Customer Sarah wants a massage on Monday 2PM
    ↓
She books through the website
    ↓
System finds available technicians and rooms
    ↓
Assigns her to Jane (technician) in Room A
    ↓
Charges her $75
    ↓
Jane gets notified
    ↓
Spa owner sees $75 revenue
```

### Who Uses It?

- **Spa Owners** - View revenue, manage staff
- **Technicians** - See their schedule, request time off
- **Customers** - Book appointments, view history
- **Admin** - Manage services, resources, pricing

---

## PROJECT OVERVIEW

### Architecture (3 Layers)

```
┌─────────────────────────────────────────────────────────┐
│ FRONTEND (Vue.js/React)                                 │
│ ├─ Login page                                           │
│ ├─ Customer dashboard (book appointments)               │
│ ├─ Technician dashboard (view schedule)                 │
│ └─ Admin dashboard (manage everything)                  │
└─────────────────────────────────────────────────────────┘
                    ↕ HTTP REST API
┌─────────────────────────────────────────────────────────┐
│ BACKEND (Java Spring Boot)                              │
│ ├─ Controllers (receive requests)                       │
│ ├─ Services (business logic)                            │
│ └─ Repositories (database queries)                      │
└─────────────────────────────────────────────────────────┘
                    ↕ SQL
┌─────────────────────────────────────────────────────────┐
│ DATABASE (PostgreSQL)                                   │
│ ├─ Tables (users, appointments, resources, etc.)       │
│ ├─ Triggers (automatic actions)                        │
│ ├─ Functions (complex calculations)                    │
│ └─ Views (pre-defined queries)                         │
└─────────────────────────────────────────────────────────┘
```

### Key Features

✅ **User Management** - Create accounts, roles (admin, tech, customer)  
✅ **Service Catalog** - Define services, prices, duration  
✅ **Appointment Booking** - Customers book, system prevents conflicts  
✅ **Resource Allocation** - Assign rooms/equipment to appointments  
✅ **Staff Management** - Manage technicians, their skills, schedules  
✅ **Revenue Tracking** - See daily/monthly revenue reports  
✅ **Absence Management** - Staff request time off  
✅ **Authentication** - Login, password reset, email verification  

---

## TECHNOLOGY STACK

### Frontend
- **Framework:** Vue.js or React
- **Build Tool:** Vite
- **Styling:** Tailwind CSS
- **HTTP Client:** Axios

### Backend
- **Language:** Java 17+
- **Framework:** Spring Boot 3.x
- **ORM:** Hibernate + Spring Data JPA
- **Build Tool:** Maven

### Database
- **System:** PostgreSQL 14+
- **Migrations:** Flyway (auto-runs SQL scripts)
- **Triggers:** Business logic in database
- **Functions:** Complex calculations in SQL

### DevOps
- **Containers:** Docker
- **Orchestration:** Docker Compose
- **CI/CD:** (if configured)

---

## HOW TO READ THE DOCUMENTATION

### Types of Documentation Files

| File Type | Purpose | For Whom |
|-----------|---------|----------|
| **start.md** | Getting started guide (YOU ARE HERE) | Beginners |
| **database.md** | Database schema, tables, structure | Backend devs |
| **controller.md** | HTTP API endpoints and routes | API users |
| **service.md** | Business logic and workflows | Developers |
| **repository.md** | Database queries and data access | Backend devs |
| **jpa_*.md** | Detailed execution traces of code | Deep divers |
| **v6_seed_data.md** | Test data initialization | QA/testers |

### Documentation Levels

```
BEGINNER LEVEL (Start Here)
    ↓
1. start.md ← What is the project?
2. database.md ← How is data stored?
3. controller.md ← What can I do with it?
    ↓
INTERMEDIATE LEVEL
    ↓
4. service.md ← How does business logic work?
5. repository.md ← How are queries built?
    ↓
ADVANCED LEVEL
    ↓
6. jpa_1_5.md ← Deep dive: Authentication & basic CRUD
7. jpa_6_10.md ← Deep dive: Complex transactions & triggers
8. jpa_11_15.md ← Deep dive: Searches & reporting
9. jpa_16_19.md ← Deep dive: Aggregations & advanced queries
    ↓
TEST/QA LEVEL
    ↓
10. v6_seed_data.md ← How to populate test data?
```

---

## READING ORDER & FILE GUIDE

### 📖 STEP 1: Understand the Database (Start Here!)

**File:** `database.md`  
**Time:** 15-20 minutes

**What you'll learn:**
- What tables exist (users, appointments, services, etc.)
- How tables relate to each other (foreign keys)
- What columns each table has
- What triggers and functions do

**Why important:**
- All data flows through the database
- Understanding structure = understanding the system

**Key Sections:**
- TABLE OF CONTENTS (skip to what interests you)
- DATABASE LAYER OVERVIEW
- POSTGRESQL SCHEMA ARCHITECTURE
- SQL FUNCTIONS
- SQL TRIGGERS

**Read this if you want to:** Understand data structure, run SQL queries, work with databases

---

### 📖 STEP 2: See What the API Can Do

**File:** `controller.md`  
**Time:** 20-30 minutes

**What you'll learn:**
- All HTTP endpoints (GET, POST, PUT, DELETE)
- What parameters each endpoint takes
- What each endpoint returns
- Example requests and responses

**Why important:**
- Frontend calls these endpoints
- Mobile apps call these endpoints
- You can test with Postman/curl

**Key Sections:**
- AUTHENTICATION ENDPOINTS
- CUSTOMER ENDPOINTS
- TECHNICIAN ENDPOINTS
- ADMIN ENDPOINTS
- ERROR RESPONSES

**Read this if you want to:** 
- Call the API
- Understand what frontend needs
- Test with Postman
- Integrate with mobile app

---

### 📖 STEP 3: Learn the Business Logic

**File:** `service.md`  
**Time:** 25-35 minutes

**What you'll learn:**
- How appointment booking works step-by-step
- How resource allocation happens
- How absence requests are validated
- How payments are calculated
- What happens when errors occur

**Why important:**
- Explains WHY the code is written this way
- Shows real business requirements
- Helps you understand constraints

**Key Sections:**
- SERVICE LAYER ARCHITECTURE
- AUTHENTICATION WORKFLOW
- APPOINTMENT BOOKING WORKFLOW
- ABSENCE REQUEST WORKFLOW
- REVENUE CALCULATION

**Read this if you want to:**
- Understand business requirements
- Add new features
- Fix bugs in logic
- Debug workflows

---

### 📖 STEP 4: See How Data is Queried

**File:** `repository.md`  
**Time:** 15-20 minutes

**What you'll learn:**
- How queries are built
- How to search appointments
- How to filter customers
- How pagination works
- Performance optimization techniques

**Why important:**
- Shows actual SQL queries
- Explains JOIN operations
- Helps optimize slow pages

**Key Sections:**
- REPOSITORY PATTERN OVERVIEW
- KEY REPOSITORIES
- QUERY EXAMPLES
- PERFORMANCE PATTERNS

**Read this if you want to:**
- Write database queries
- Optimize slow queries
- Understand SQL in Java
- Add new search filters

---

### 📖 STEP 5-8: Deep Dive into Execution Traces

**Files:** `jpa_1_5.md`, `jpa_6_10.md`, `jpa_11_15.md`, `jpa_16_19.md`  
**Time:** 30-45 minutes each (skip what you don't need)

**What you'll learn:**
- EXACT code locations (file names, line numbers)
- EXACT SQL statements executed
- How data maps between Java and database
- What errors can happen and why
- Complete execution trace from API to database and back

**Why important:**
- For debugging specific functions
- For performance optimization
- For understanding edge cases
- For adding new features

**Structure of each file:**
```
FUNCTION [NUMBER]: [FunctionName]
├─ Code Snippet (exact location)
├─ SQL Statement (what query runs)
├─ Java ↔ Database Mapping (type conversions)
├─ Trigger Interactions (what automatic actions happen)
├─ Exception Flows (what can go wrong)
└─ Timeline (step-by-step execution)
```

**Read this if you want to:**
- Debug a specific function
- Fix a bug in a transaction
- Understand trigger behavior
- Optimize a slow query
- Add similar functionality

---

### 📖 STEP 9: Test Data Setup

**File:** `v6_seed_data.md`  
**Time:** 10-15 minutes

**What you'll learn:**
- How test data is created
- What sample data is populated
- How to verify seed data
- How to clean up if needed

**Why important:**
- Running on empty database is boring
- Need realistic data to test
- 500K test appointments for stress testing

**Key Sections:**
- WHAT THIS FILE DOES
- EXECUTION FLOW
- DATA SUMMARY
- VERIFICATION STEPS

**Read this if you want to:**
- Set up local development
- Test the system
- Run load tests
- Clean up test data

---

## QUICK PROJECT MAP

### Which File to Read for Different Needs

#### 🔧 I'm a Backend Developer

Read in order:
1. **start.md** (this file) - Understand project
2. **database.md** - See schema and structure
3. **service.md** - Understand business logic
4. **repository.md** - Learn database queries
5. **jpa_1_5.md** to **jpa_16_19.md** - Deep dive when debugging

#### 🎨 I'm a Frontend Developer

Read in order:
1. **start.md** (this file) - Understand project
2. **controller.md** - See all API endpoints
3. **database.md** - Understand data structure
4. **jpa_1_5.md** - Understand API responses (if needed)

#### 🧪 I'm a QA/Tester

Read in order:
1. **start.md** (this file) - Understand project
2. **controller.md** - See all endpoints to test
3. **v6_seed_data.md** - Set up test data
4. **jpa_1_5.md** to **jpa_16_19.md** - Understand expected behavior

#### 📊 I'm a Data Analyst

Read in order:
1. **start.md** (this file) - Understand project
2. **database.md** - See all tables and columns
3. **repository.md** - Learn available queries
4. **jpa_11_15.md** to **jpa_16_19.md** - See reporting queries

#### 🚀 I'm Deploying to Production

Read in order:
1. **start.md** (this file) - Understand project
2. **database.md** - Database requirements
3. **v6_seed_data.md** - DO NOT RUN SEED DATA on production!
4. **controller.md** - Configure API endpoints

---

## COMMON QUESTIONS

### Q1: Where do I start as a complete beginner?

**A:** Read files in this order:
1. This file (start.md) - ✅ You're reading it!
2. database.md - Understand tables and data
3. controller.md - See what the API does
4. service.md - Understand business logic

After these 4 files, you'll have 80% understanding of the project.

---

### Q2: I want to add a new feature. Where do I look?

**A:** 
1. Check `database.md` - Is there a table for it?
2. Check `controller.md` - Do endpoints already exist?
3. Check `service.md` - What's the business logic?
4. Check `jpa_*.md` - How is similar feature implemented?
5. Write code following the same pattern

---

### Q3: I found a bug. How do I debug it?

**A:**
1. Find the API endpoint in `controller.md`
2. Find the service method in `service.md`
3. Find the database query in `repository.md`
4. Find exact code in `jpa_1_5.md` through `jpa_16_19.md`
5. Check exception flow in that same file
6. Debug step-by-step following the execution trace

---

### Q4: What do I need to run this locally?

**A:**
```bash
# Required
- Java 17+
- Maven
- PostgreSQL 14+
- Docker & Docker Compose (optional, but recommended)
- Node.js 16+ (for frontend)

# Quick start with Docker:
docker-compose up

# Then:
- Backend: http://localhost:8080
- Frontend: http://localhost:3000
- Database: localhost:5432
```

---

### Q5: What are triggers and why do they matter?

**A:** Triggers are automatic database actions.

**Example:**
```sql
TRIGGER: When appointment is inserted
ACTION: Automatically calculate end_time based on duration
```

Check `database.md` section "SQL TRIGGERS" to see all triggers.

---

### Q6: What's the difference between CRUD functions?

**A:**
- **CREATE** - Insert new data (POST)
- **READ** - Get existing data (GET)
- **UPDATE** - Modify existing data (PUT)
- **DELETE** - Remove data (DELETE)

All 19 functions in `jpa_*.md` files are CRUD operations.

---

### Q7: How is test data set up?

**A:** 
When you first run the app, Flyway automatically runs:
- V1__init_schema.sql - Create tables
- V2__add_booking_logic.sql - Add functions/triggers
- ... (more migrations)
- **V6__seed_data.sql** - Add test data (500K appointments!)

See `v6_seed_data.md` for details.

---

### Q8: What if I just want to understand one feature?

**A:** 
Here are shortcuts for common features:

**Feature: Booking an Appointment**
1. Check `controller.md` - POST /api/booking endpoint
2. Check `service.md` - "APPOINTMENT BOOKING WORKFLOW"
3. Check `jpa_1_5.md` - Function 4 (save appointment)
4. Check `database.md` - appointment table structure

**Feature: Staff Absence Requests**
1. Check `controller.md` - POST /api/absence endpoint
2. Check `service.md` - "ABSENCE REQUEST WORKFLOW"
3. Check `jpa_6_10.md` - Functions 6-7 (absence operations)

**Feature: Revenue Reports**
1. Check `controller.md` - GET /api/revenue endpoint
2. Check `jpa_11_15.md` - Function 15 (revenue statistics)
3. Check `database.md` - get_revenue_statistics() function

---

### Q9: Should I read all the jpa_*.md files?

**A:** Not necessarily. It depends on what you need:

**Read if:** You're debugging a specific function or optimizing performance  
**Skip if:** You just need to understand the system at a high level

**Minimum read:** jpa_1_5.md (authentication is important)  
**Recommended:** jpa_6_10.md (appointment booking logic)  
**Optional:** jpa_11_15.md, jpa_16_19.md (advanced queries)

---

### Q10: Is there a database diagram?

**A:** Yes! Check `database.md` section "POSTGRESQL SCHEMA ARCHITECTURE" for:
- Table relationships
- Entity diagram
- Data flows

---

## QUICK REFERENCE

### File Sizes & Reading Time

| File | Focus | Read Time | Priority |
|------|-------|-----------|----------|
| **start.md** | Getting started | 10 min | ⭐⭐⭐ Essential |
| **database.md** | Data structure | 20 min | ⭐⭐⭐ Essential |
| **controller.md** | API endpoints | 25 min | ⭐⭐⭐ Essential |
| **service.md** | Business logic | 30 min | ⭐⭐ Important |
| **repository.md** | Database queries | 20 min | ⭐⭐ Important |
| **jpa_1_5.md** | Auth + basic CRUD | 15 min | ⭐ Reference |
| **jpa_6_10.md** | Complex logic | 15 min | ⭐ Reference |
| **jpa_11_15.md** | Searches + reports | 15 min | ⭐ Reference |
| **jpa_16_19.md** | Aggregations | 15 min | ⭐ Reference |
| **v6_seed_data.md** | Test data | 10 min | ⭐ Reference |

**Total Essential Reading:** ~1.5 hours  
**Total Optional Reading:** ~1.5 hours  

---

## YOUR NEXT STEP

### Recommended Path:

1. ✅ **You just read:** start.md (this file)
2. 👉 **Next:** Open `database.md` and understand the schema
3. Then: Open `controller.md` and see what endpoints exist
4. Then: Open `service.md` and understand business workflows

**Expected Time:** 1-1.5 hours to understand 80% of the system

After that, you can:
- Start contributing code
- Debug issues efficiently  
- Add new features
- Optimize performance

---

## NEED HELP?

### If You Get Stuck:

1. **Check TABLE OF CONTENTS** in each .md file - Jump to relevant sections
2. **Use browser Find (Ctrl+F)** - Search for keywords in docs
3. **Cross-reference files** - Links between files show relationships
4. **Check code comments** - Backend code has comments explaining logic
5. **Look at examples** - Real code examples in documentation

---

**Good luck learning AuraControl! 🚀**

*Questions? Start with database.md next!*

---

**Last Updated:** December 30, 2025  
**Project:** AuraControl Spa Management System  
**Version:** 1.0

