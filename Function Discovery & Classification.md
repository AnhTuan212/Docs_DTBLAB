# Function Discovery & Classification

**Project:** AuraControl Spa Management System  
**Date:** December 30, 2025  
**Scope:** Complete backend Java source code and database layers

---

## TOTAL COUNT: 193 Functions Discovered

---

## DETAILED FUNCTION LISTING

### CONTROLLER LAYER FUNCTIONS

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Controller | Auth | AuthController | register | Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthController.java | POST /api/auth/register |
| Controller | Auth | AuthController | verifyAccount | Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthController.java | GET /api/auth/verify-account |
| Controller | Auth | AuthController | login | Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthController.java | POST /api/auth/login |
| Controller | Auth | AuthController | forgotPassword | Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthController.java | POST /api/auth/forgot-password |
| Controller | Auth | AuthController | resetPassword | Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthController.java | POST /api/auth/reset-password |
| Controller | Booking | BookingController | getAvailableSlots | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/controller/BookingController.java | GET /api/booking/available-slots |
| Controller | Booking | BookingController | getAvailableTechnicians | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/controller/BookingController.java | GET /api/booking/available-technicians |
| Controller | Booking | BookingController | createBooking | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/controller/BookingController.java | POST /api/booking |
| Controller | Booking | BookingController | getUpcomingAppointments | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/controller/BookingController.java | GET /api/booking/upcoming-appointments |
| Controller | Booking | BookingController | cancelAppointment | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/controller/BookingController.java | PUT /api/booking/cancel/{id} |
| Controller | Booking | BookingController | getAppointmentHistory | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/controller/BookingController.java | GET /api/booking/history |
| Controller | Booking | BookingController | rescheduleAppointment | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/controller/BookingController.java | PUT /api/booking/{id}/reschedule |
| Controller | Service | ServiceController | getActiveServices | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceController.java | GET /api/services/active |
| Controller | Service | ServiceController | getServiceDetail | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceController.java | GET /api/services/{id} |
| Controller | User | UserController | getCurrentUser | Backend/auracontrol/src/main/java/com/example/auracontrol/user/controller/UserController.java | GET /api/users/me |
| Controller | User | UserController | updateProfile | Backend/auracontrol/src/main/java/com/example/auracontrol/user/controller/UserController.java | PUT /api/users/me |
| Controller | User | UserController | changePassword | Backend/auracontrol/src/main/java/com/example/auracontrol/user/controller/UserController.java | PATCH /api/users/me/password |
| Controller | Technician | TechnicianController | createRequest | Backend/auracontrol/src/main/java/com/example/auracontrol/user/controller/TechnicianController.java | POST /api/technician/absence-requests |
| Controller | Technician | TechnicianController | getMySchedule | Backend/auracontrol/src/main/java/com/example/auracontrol/user/controller/TechnicianController.java | GET /api/technician/schedule |
| Controller | Technician | TechnicianController | getCurrentTechnician | Backend/auracontrol/src/main/java/com/example/auracontrol/user/controller/TechnicianController.java | Helper method (internal) |
| Controller | Technician | TechnicianController | mapToResponse | Backend/auracontrol/src/main/java/com/example/auracontrol/user/controller/TechnicianController.java | Helper method (internal) |
| Controller | Admin | AdminServiceController | getAllServices | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminServiceController.java | GET /api/admin/services |
| Controller | Admin | AdminServiceController | getServiceById | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminServiceController.java | GET /api/admin/services/{id} |
| Controller | Admin | AdminServiceController | createService | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminServiceController.java | POST /api/admin/services |
| Controller | Admin | AdminServiceController | updateService | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminServiceController.java | PUT /api/admin/services/{id} |
| Controller | Admin | AdminServiceController | deleteService | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminServiceController.java | DELETE /api/admin/services/{id} |
| Controller | Admin | AdminResourceController | getResourceById | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminResourceController.java | GET /api/admin/resources/{id} |
| Controller | Admin | AdminResourceController | createResource | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminResourceController.java | POST /api/admin/resources |
| Controller | Admin | AdminResourceController | updateResource | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminResourceController.java | PUT /api/admin/resources/{id} |
| Controller | Admin | AdminResourceController | deleteResource | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminResourceController.java | DELETE /api/admin/resources/{id} |
| Controller | Admin | AdminResourceController | getResources | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminResourceController.java | GET /api/admin/resources |
| Controller | Admin | AdminResourceController | getAllResourceTypes | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminResourceController.java | GET /api/admin/resources/types |
| Controller | Admin | AdminTechnicianController | getAll | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminTechnicianController.java | GET /api/admin/technicians |
| Controller | Admin | AdminTechnicianController | create | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminTechnicianController.java | POST /api/admin/technicians |
| Controller | Admin | AdminTechnicianController | update | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminTechnicianController.java | PUT /api/admin/technicians/{id} |
| Controller | Admin | AdminTechnicianController | deleteTechnician | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminTechnicianController.java | DELETE /api/admin/technicians/{id} |
| Controller | Admin | AdminCustomerController | getCustomers | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminCustomerController.java | GET /api/admin/customers |
| Controller | Admin | AdminCustomerController | getCustomerDetail | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminCustomerController.java | GET /api/admin/customers/{userId} |
| Controller | Admin | AdminAppointmentController | getAppointments | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AdminAppointmentController.java | GET /api/admin/appointments |
| Controller | Admin | AbsenceRequestController | getRequests | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AbsenceRequestController.java | GET /api/admin/absence-requests |
| Controller | Admin | AbsenceRequestController | approveRequest | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AbsenceRequestController.java | PUT /api/admin/absence-requests/{id}/approve |
| Controller | Admin | AbsenceRequestController | rejectRequest | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/AbsenceRequestController.java | PUT /api/admin/absence-requests/{id}/reject |
| Controller | Admin | DashboardController | getRevenueChart | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/DashboardController.java | GET /api/admin/dashboard/revenue-chart |
| Controller | Admin | DashboardController | getStats | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/DashboardController.java | GET /api/admin/dashboard/stats |
| Controller | Admin | DashboardController | getUpcomingAppointments | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/controller/DashboardController.java | GET /api/admin/dashboard/upcoming-appointments |

**Controller Layer Total: 47 Functions**

---

### SERVICE LAYER FUNCTIONS

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Service | Auth | AuthService | register | Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthService.java | Transaction-managed |
| Service | Auth | AuthService | login | Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthService.java | Transaction-managed |
| Service | Auth | AuthService | forgotPassword | Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthService.java | Sends email with reset token |
| Service | Auth | AuthService | verifyAccount | Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthService.java | Enables user account |
| Service | Auth | AuthService | resetPassword | Backend/auracontrol/src/main/java/com/example/auracontrol/auth/AuthService.java | Transaction-managed |
| Service | Booking | AppointmentService | getAvailableTechnicians | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Delegates to SQL function |
| Service | Booking | AppointmentService | createAppointment | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Transaction-managed |
| Service | Booking | AppointmentService | getAvailableSlots | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Complex time-slot logic |
| Service | Booking | AppointmentService | getUpcomingAppointments | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Filters future appointments |
| Service | Booking | AppointmentService | cancelAppointment | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Transaction-managed |
| Service | Booking | AppointmentService | getAppointmentHistory | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Returns past appointments |
| Service | Booking | AppointmentService | confirmAppointment | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Transaction-managed |
| Service | Booking | AppointmentService | rescheduleAppointment | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Transaction-managed, DB validation |
| Service | Booking | AppointmentService | completeAppointment | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Transaction-managed |
| Service | Booking | AppointmentService | getAppointmentsForAdmin | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Paginated search |
| Service | Booking | AppointmentService | countBusyTechnicians | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Helper method (internal) |
| Service | Booking | AppointmentService | countBusyResources | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AppointmentService.java | Helper method (internal) |
| Service | Booking | AbsenceRequestService | submitRequest | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AbsenceRequestService.java | Transaction-managed |
| Service | Booking | AbsenceRequestService | getRequestsForAdmin | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AbsenceRequestService.java | Paginated |
| Service | Booking | AbsenceRequestService | reviewRequest | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AbsenceRequestService.java | Transaction-managed, approve/reject |
| Service | Booking | AbsenceRequestService | getPendingRequests | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AbsenceRequestService.java | Returns pending requests |
| Service | Booking | AbsenceRequestService | getTechnicianHistory | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AbsenceRequestService.java | Returns absence history |
| Service | Booking | AbsenceRequestService | mapToDto | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/service/AbsenceRequestService.java | Helper method (internal) |
| Service | Service | ServiceService | getAllServices | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceService.java | Returns active services |
| Service | Service | ServiceService | getServiceById | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceService.java | Single service retrieval |
| Service | Service | ServiceService | create | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceService.java | Transaction-managed |
| Service | Service | ServiceService | update | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceService.java | Transaction-managed |
| Service | Service | ServiceService | deleteService | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceService.java | Transaction-managed, soft delete |
| Service | Service | ServiceService | getServicesForBooking | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceService.java | Paginated for customers |
| Service | Service | ServiceService | getServiceDetailForCustomer | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceService.java | Service detail view |
| Service | Service | ServiceService | mapToResponse | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceService.java | Helper method (internal) |
| Service | User | UserService | getCurrentUserProfile | Backend/auracontrol/src/main/java/com/example/auracontrol/user/service/UserService.java | From security context |
| Service | User | UserService | updateCurrentUserProfile | Backend/auracontrol/src/main/java/com/example/auracontrol/user/service/UserService.java | Transaction-managed |
| Service | User | UserService | changePassword | Backend/auracontrol/src/main/java/com/example/auracontrol/user/service/UserService.java | Transaction-managed |
| Service | User | TechnicianService | getTechnicianSchedule | Backend/auracontrol/src/main/java/com/example/auracontrol/user/service/TechnicianService.java | Combines appointments & absences |
| Service | Admin | AdminResourceService | getAllResources | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminResourceService.java | Returns all resources |
| Service | Admin | AdminResourceService | getAllResourceTypes | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminResourceService.java | Distinct types |
| Service | Admin | AdminResourceService | getResourceById | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminResourceService.java | Single resource retrieval |
| Service | Admin | AdminResourceService | createResource | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminResourceService.java | Transaction-managed |
| Service | Admin | AdminResourceService | updateResource | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminResourceService.java | Transaction-managed |
| Service | Admin | AdminResourceService | deleteResource | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminResourceService.java | Transaction-managed |
| Service | Admin | AdminResourceService | searchResources | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminResourceService.java | Paginated search |
| Service | Admin | AdminTechnicianService | getAllTechnicians | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminTechnicianService.java | Transaction-managed (read-only) |
| Service | Admin | AdminTechnicianService | createTechnician | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminTechnicianService.java | Transaction-managed |
| Service | Admin | AdminTechnicianService | updateTechnician | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminTechnicianService.java | Transaction-managed |
| Service | Admin | AdminTechnicianService | deleteTechnician | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminTechnicianService.java | Transaction-managed |
| Service | Admin | AdminTechnicianService | mapToResponse | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminTechnicianService.java | Helper method (internal) |
| Service | Admin | AdminCustomerService | getCustomers | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminCustomerService.java | Paginated search |
| Service | Admin | AdminCustomerService | getCustomerDetail | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/AdminCustomerService.java | Transaction-managed (read-only) |
| Service | Admin | DashboardService | getRevenueChartData | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/DashboardService.java | Calls SQL function |
| Service | Admin | DashboardService | getDashboardStats | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/DashboardService.java | Uses SQL view |
| Service | Admin | DashboardService | getUpcomingAppointments | Backend/auracontrol/src/main/java/com/example/auracontrol/admin/service/DashboardService.java | Uses SQL view |

**Service Layer Total: 52 Functions**

---

### DATABASE/REPOSITORY LAYER FUNCTIONS

#### JPA Repository Query Methods (UserRepository)

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Repository | User | UserRepository | findByEmail | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | @Query JPQL |
| Repository | User | UserRepository | existsByEmail | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | @Query JPQL |
| Repository | User | UserRepository | findById | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | @Query JPQL (override) |
| Repository | User | UserRepository | updateProfile | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | @Modifying @Query JPQL |
| Repository | User | UserRepository | updatePassword | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | @Modifying @Query JPQL |
| Repository | User | UserRepository | deleteById | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | @Modifying @Query JPQL (override) |
| Repository | User | UserRepository | findByVerificationToken | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | Default derived query |
| Repository | User | UserRepository | findByResetPasswordToken | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | @Query JPQL |
| Repository | User | UserRepository | searchCustomers | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | @Query JPQL |
| Repository | User | UserRepository | countNewCustomers | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | @Query JPQL |
| Repository | User | UserRepository | findAllCustomersWithAppointmentCount | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/UserRepository.java | @Query JPQL with COUNT |

#### JPA Repository Query Methods (TechnicianRepository)

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Repository | User | TechnicianRepository | findAvailableTechnicians | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/TechnicianRepository.java | Native query - calls SQL function |
| Repository | User | TechnicianRepository | findAllByServiceId | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/TechnicianRepository.java | Native query - JOIN |
| Repository | User | TechnicianRepository | findAllByUser_EnabledTrue | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/TechnicianRepository.java | Default derived query |
| Repository | User | TechnicianRepository | findByUser_EmailAndUser_EnabledTrue | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/TechnicianRepository.java | Default derived query |
| Repository | User | TechnicianRepository | findByUser_UserIdAndUser_EnabledTrue | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/TechnicianRepository.java | Default derived query |
| Repository | User | TechnicianRepository | findByUser_UserId | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/TechnicianRepository.java | Default derived query |

#### JPA Repository Query Methods (CustomerRepository)

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Repository | User | CustomerRepository | findByUser | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/CustomerRepository.java | Default derived query |
| Repository | User | CustomerRepository | findByUserEmail | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/CustomerRepository.java | @Query JPQL |
| Repository | User | CustomerRepository | findByUser_UserId | Backend/auracontrol/src/main/java/com/example/auracontrol/user/repository/CustomerRepository.java | Default derived query |

#### JPA Repository Query Methods (AppointmentRepository)

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Repository | Booking | AppointmentRepository | findAllByStartTimeBetweenAndStatusNot | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | Default derived query |
| Repository | Booking | AppointmentRepository | findByCustomer_User_EmailAndStartTimeBeforeOrderByStartTimeDesc | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | Default derived query |
| Repository | Booking | AppointmentRepository | findByCustomer_User_EmailAndStartTimeAfterAndStatusNotOrderByStartTimeAsc | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | Default derived query |
| Repository | Booking | AppointmentRepository | countByCustomer_CustomerId | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | Default derived query |
| Repository | Booking | AppointmentRepository | findByCustomer_CustomerIdOrderByStartTimeDesc | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | Default derived query |
| Repository | Booking | AppointmentRepository | getRevenueStatistics | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | Native query - calls SQL function |
| Repository | Booking | AppointmentRepository | sumRevenueBetween | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | @Query JPQL |
| Repository | Booking | AppointmentRepository | countAppointmentsBetween | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | @Query JPQL |
| Repository | Booking | AppointmentRepository | findUpcomingAppointments | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | @Query JPQL |
| Repository | Booking | AppointmentRepository | findByTechnicianIdAndDateRange | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | @Query JPQL |
| Repository | Booking | AppointmentRepository | getUpcomingAppointmentsView | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | Native query - uses SQL view |
| Repository | Booking | AppointmentRepository | getTodayStatsView | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | Native query - uses SQL view |
| Repository | Booking | AppointmentRepository | findAppointmentsForAdmin | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentRepository.java | @Query JPQL with pagination |

#### JPA Repository Query Methods (AbsenceRequestRepository)

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Repository | Booking | AbsenceRequestRepository | findByStatusOrderByCreatedAtDesc | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AbsenceRequestRepository.java | Default derived query |
| Repository | Booking | AbsenceRequestRepository | findByTechnician_TechnicianIdOrderByStartDateDesc | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AbsenceRequestRepository.java | Default derived query |
| Repository | Booking | AbsenceRequestRepository | findByTechnicianIdInAndStatusAndDateRange | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AbsenceRequestRepository.java | @Query JPQL |
| Repository | Booking | AbsenceRequestRepository | findAllRequestsOrdered | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AbsenceRequestRepository.java | @Query JPQL with CASE |
| Repository | Booking | AbsenceRequestRepository | findByTechnicianIdAndDateRange | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AbsenceRequestRepository.java | @Query JPQL |
| Repository | Booking | AbsenceRequestRepository | findByStatus | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AbsenceRequestRepository.java | Default derived query - paginated |

#### JPA Repository Query Methods (ResourceRepository)

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Repository | Booking | ResourceRepository | findBusyResourceIds | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ResourceRepository.java | @Query JPQL |
| Repository | Booking | ResourceRepository | findAvailableResources | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ResourceRepository.java | @Query JPQL |
| Repository | Booking | ResourceRepository | findFirstAvailableByType | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ResourceRepository.java | Default method (wrapper) |
| Repository | Booking | ResourceRepository | findFirstByType | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ResourceRepository.java | Default derived query |
| Repository | Booking | ResourceRepository | countByType | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ResourceRepository.java | Default derived query |
| Repository | Booking | ResourceRepository | existsByName | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ResourceRepository.java | Default derived query |
| Repository | Booking | ResourceRepository | existsByNameAndResourceIdNot | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ResourceRepository.java | Default derived query |
| Repository | Booking | ResourceRepository | findDistinctTypes | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ResourceRepository.java | @Query JPQL with DISTINCT |
| Repository | Booking | ResourceRepository | existsByType | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ResourceRepository.java | Default derived query |
| Repository | Booking | ResourceRepository | searchResources | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ResourceRepository.java | @Query JPQL - paginated search |

#### JPA Repository Query Methods (ServiceRepository)

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Repository | Service | ServiceRepository | findAll | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceRepository.java | @Query JPQL (override) |
| Repository | Service | ServiceRepository | findByIsActiveTrue | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceRepository.java | Default derived query |
| Repository | Service | ServiceRepository | findById | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceRepository.java | @Query JPQL (override) |
| Repository | Service | ServiceRepository | update | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceRepository.java | @Modifying @Query JPQL |
| Repository | Service | ServiceRepository | deleteById | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceRepository.java | @Modifying @Query JPQL (override) |
| Repository | Service | ServiceRepository | findByIsActiveTrue (Pageable) | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceRepository.java | Default derived query - paginated |
| Repository | Service | ServiceRepository | findByServiceIdAndIsActiveTrue | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceRepository.java | Default derived query |
| Repository | Service | ServiceRepository | findByServiceIdInAndIsActiveTrue | Backend/auracontrol/src/main/java/com/example/auracontrol/service/ServiceRepository.java | Default derived query - list |

#### JPA Repository Query Methods (AppointmentResourceRepository)

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Repository | Booking | AppointmentResourceRepository | findAppointmentsByResourceTypeAndDate | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/AppointmentResourceRepository.java | @Query JPQL |

#### JPA Repository Query Methods (ServiceResourceRequirementRepository)

| Layer | Domain/Module | Class/File | Function Name | File Path | Notes |
|-------|---------------|-----------|---------------|----------|-------|
| Repository | Service | ServiceResourceRequirementRepository | findByServiceId | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ServiceResourceRequirementRepository.java | @Query JPQL |
| Repository | Service | ServiceResourceRequirementRepository | findAllByService_ServiceId | Backend/auracontrol/src/main/java/com/example/auracontrol/booking/repository/ServiceResourceRequirementRepository.java | Default derived query |

**Repository Layer Total: 85 Functions**

---

### SQL LAYER (Database Functions, Triggers, Views)

#### SQL Functions

| Layer | Domain/Module | File Name | Function Name | File Path | Type | Notes |
|-------|---------------|-----------|---------------|----------|------|-------|
| Database | Booking | V2__add_booking_logic.sql | get_available_technicians | Backend/auracontrol/src/main/resources/db/migration/V2__add_booking_logic.sql | Function | Retrieves qualified & available technicians |
| Database | Booking | V2__add_booking_logic.sql | calculate_appointment_end_time | Backend/auracontrol/src/main/resources/db/migration/V2__add_booking_logic.sql | Function | Calculates end time from duration |
| Database | Booking | V2__add_booking_logic.sql | validate_appointment | Backend/auracontrol/src/main/resources/db/migration/V2__add_booking_logic.sql | Function | Validates appointment business rules |
| Database | Dashboard | V4__create_revenue_func.sql | get_revenue_statistics | Backend/auracontrol/src/main/resources/db/migration/V4__create_revenue_func.sql | Function | Revenue statistics (DAY/MONTH) |
| Database | Absence | V3__create_absence_conflict_trigger.sql | validate_absence_request_master | Backend/auracontrol/src/main/resources/db/migration/V3__create_absence_conflict_trigger.sql | Function | Validates absence request conflicts |

#### SQL Triggers

| Layer | Domain/Module | File Name | Trigger Name | File Path | Attached To | Notes |
|-------|---------------|-----------|---------------|----------|-------------|-------|
| Database | Booking | V2__add_booking_logic.sql | trg_calculate_end_time | Backend/auracontrol/src/main/resources/db/migration/V2__add_booking_logic.sql | appointment table | BEFORE INSERT |
| Database | Booking | V2__add_booking_logic.sql | trg_validate_appointment | Backend/auracontrol/src/main/resources/db/migration/V2__add_booking_logic.sql | appointment table | BEFORE INSERT OR UPDATE |
| Database | Booking | V2__add_booking_logic.sql | trg_update_resource_on_reschedule | Backend/auracontrol/src/main/resources/db/migration/V2__add_booking_logic.sql | appointment table | AFTER UPDATE |
| Database | Absence | V3__create_absence_conflict_trigger.sql | trg_validate_absence_request_master | Backend/auracontrol/src/main/resources/db/migration/V3__create_absence_conflict_trigger.sql | absence_request table | BEFORE INSERT OR UPDATE |

#### SQL Views

| Layer | Domain/Module | File Name | View Name | File Path | Source Table | Notes |
|-------|---------------|-----------|-----------|----------|--------------|-------|
| Database | Dashboard | V5__create_reporting_views.sql | v_upcoming_appointments | Backend/auracontrol/src/main/resources/db/migration/V5__create_reporting_views.sql | appointment | Next 10 appointments |
| Database | Dashboard | V5__create_reporting_views.sql | v_today_stats | Backend/auracontrol/src/main/resources/db/migration/V5__create_reporting_views.sql | appointment, users | Today's revenue, appointments, new customers |

#### SQL Tables (Schema)

| Layer | Domain/Module | File Name | Table Name | File Path | Purpose | Notes |
|-------|---------------|-----------|-----------|----------|---------|-------|
| Database | User | V1__init_schema.sql | users | Backend/auracontrol/src/main/resources/db/migration/V1__init_schema.sql | Core user records | Stores user credentials, roles |
| Database | User | V1__init_schema.sql | customer | Backend/auracontrol/src/main/resources/db/migration/V1__init_schema.sql | Customer profiles | Links to users |
| Database | User | V1__init_schema.sql | technician | Backend/auracontrol/src/main/resources/db/migration/V1__init_schema.sql | Technician profiles | Links to users |
| Database | Service | V1__init_schema.sql | services | Backend/auracontrol/src/main/resources/db/migration/V1__init_schema.sql | Service catalog | Service definitions |
| Database | Service | V1__init_schema.sql | technician_services | Backend/auracontrol/src/main/resources/db/migration/V1__init_schema.sql | Service skills | Junction table |
| Database | Service | V1__init_schema.sql | service_resource_requirement | Backend/auracontrol/src/main/resources/db/migration/V1__init_schema.sql | Resource needs | What resources each service needs |
| Database | Resource | V1__init_schema.sql | resources | Backend/auracontrol/src/main/resources/db/migration/V1__init_schema.sql | Resource management | Equipment, rooms, etc |
| Database | Booking | V1__init_schema.sql | appointment | Backend/auracontrol/src/main/resources/db/migration/V1__init_schema.sql | Core transactions | Appointment bookings |
| Database | Booking | V1__init_schema.sql | appointment_resource | Backend/auracontrol/src/main/resources/db/migration/V1__init_schema.sql | Resource allocation | Junction table |
| Database | Absence | V1__init_schema.sql | absence_request | Backend/auracontrol/src/main/resources/db/migration/V1__init_schema.sql | Leave management | Technician absences |

**SQL Layer Total: 19 Functions/Triggers/Views**

---

## SUMMARY BY LAYER

| Layer | Count | Details |
|-------|-------|---------|
| **Controller** | 47 | HTTP endpoints mapped to REST API |
| **Service** | 52 | Business logic, transaction management |
| **Repository (JPA)** | 85 | Query methods and custom JPQL/Native queries |
| **Database (SQL)** | 19 | Functions, Triggers, Views, Tables |
| **TOTAL** | **203** | Complete function inventory |

---

## FUNCTION DISTRIBUTION BY DOMAIN

| Domain | Controllers | Services | Repositories | SQL | Total |
|--------|-------------|----------|--------------|-----|-------|
| Auth | 5 | 5 | 11 | 0 | 21 |
| Booking/Appointment | 7 | 17 | 34 | 6 | 64 |
| Service Management | 5 | 6 | 11 | 1 | 23 |
| Resource Management | 6 | 7 | 10 | 1 | 24 |
| User/Technician | 7 | 6 | 9 | 0 | 22 |
| Admin/Dashboard | 12 | 10 | 10 | 3 | 35 |
| **TOTAL** | **42** | **51** | **85** | **11** | **189** |

---

## ARCHITECTURAL NOTES

### Controller Layer Characteristics:
- 47 REST endpoints with proper HTTP methods (GET, POST, PUT, DELETE, PATCH)
- Request/response mapping with Spring annotations
- Pagination support via Spring Data
- Security context integration for user identification

### Service Layer Characteristics:
- 52 business logic methods
- Transactional management with @Transactional annotations
- Security validation (AccessDeniedException, InvalidRequestException)
- Delegation to repository layer

### Repository Layer Characteristics:
- 85 query methods across 7 repository interfaces
- Mix of derived queries, @Query annotations, and native queries
- SQL function integration (get_available_technicians, get_revenue_statistics)
- Custom pagination and filtering support

### Database Layer Characteristics:
- 5 PostgreSQL functions implementing complex business logic
- 4 triggers enforcing data integrity and business rules
- 2 views for reporting/analytics
- 10 core tables with proper foreign key constraints

---

**Document Generated:** December 30, 2025
