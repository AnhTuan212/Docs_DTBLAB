-- jpa function :
-- List<Appointment> findAllByStartTimeBetweenAndStatusNot(
--         LocalDateTime start,
--         LocalDateTime end,
--         String status
-- );
-- sql function :
-- Query 1
EXPLAIN ANALYZE 
SELECT * FROM appointment 
WHERE start_time BETWEEN :start AND :end 
  AND status <> :status;

--------------------------------------------------------------------------------

-- jpa function :
-- List<Appointment> findByCustomer_User_EmailAndStartTimeBeforeOrderByStartTimeDesc(
--         String email,
--         LocalDateTime now
-- );
-- sql function :
-- Query 2
EXPLAIN ANALYZE 
SELECT a.* FROM appointment a
JOIN customer c ON a.customer_id = c.customer_id
JOIN users u ON c.user_id = u.user_id
WHERE u.email = :email 
  AND a.start_time < :now
ORDER BY a.start_time DESC;

--------------------------------------------------------------------------------

-- jpa function :
-- List<Appointment> findByCustomer_User_EmailAndStartTimeAfterAndStatusNotOrderByStartTimeAsc(
--         String email,
--         LocalDateTime now,
--         String status
-- );
-- sql function :
-- Query 3
EXPLAIN ANALYZE 
SELECT a.* FROM appointment a
JOIN customer c ON a.customer_id = c.customer_id
JOIN users u ON c.user_id = u.user_id
WHERE u.email = :email 
  AND a.start_time > :now 
  AND a.status <> :status
ORDER BY a.start_time ASC;

--------------------------------------------------------------------------------

-- jpa function :
-- // For upcoming appointments: only PENDING and CONFIRMED
-- List<Appointment> findByCustomer_User_EmailAndStatusInOrderByStartTimeAsc(
--         String email,
--         List<String> statuses
-- );
-- sql function :
-- Query 4
EXPLAIN ANALYZE 
SELECT a.* FROM appointment a
JOIN customer c ON a.customer_id = c.customer_id
JOIN users u ON c.user_id = u.user_id
WHERE u.email = :email 
  AND a.status IN (:status1, :status2)
ORDER BY a.start_time ASC;

--------------------------------------------------------------------------------

-- jpa function :
-- // For history: only COMPLETED appointments
-- List<Appointment> findByCustomer_User_EmailAndStatusOrderByStartTimeDesc(
--         String email,
--         String status
-- );
-- sql function :
-- Query 5
EXPLAIN ANALYZE 
SELECT a.* FROM appointment a
JOIN customer c ON a.customer_id = c.customer_id
JOIN users u ON c.user_id = u.user_id
WHERE u.email = :email 
  AND a.status = :status
ORDER BY a.start_time DESC;

--------------------------------------------------------------------------------

-- jpa function :
-- long countByCustomer_CustomerId(Integer customerId);
-- sql function :
-- Query 6
EXPLAIN ANALYZE 
SELECT count(*) 
FROM appointment 
WHERE customer_id = :customerId;

--------------------------------------------------------------------------------

-- jpa function :
-- List<Appointment> findByCustomer_CustomerIdOrderByStartTimeDesc(Integer customerId);
-- sql function :
-- Query 7
EXPLAIN ANALYZE 
SELECT * FROM appointment 
WHERE customer_id = :customerId
ORDER BY start_time DESC;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query(value = "SELECT * FROM get_revenue_statistics(:startDate, :endDate, :type)", nativeQuery = true)
-- List<RevenueStatDto> getRevenueStatistics(
--         @Param("startDate") LocalDateTime startDate,
--         @Param("endDate") LocalDateTime endDate,
--         @Param("type") String type
-- );
-- sql function :
-- Query 8
EXPLAIN ANALYZE 
SELECT * FROM get_revenue_statistics(:startDate, :endDate, :type);

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT COALESCE(SUM(a.finalPrice), 0) FROM Appointment a " +
--         "WHERE a.status = 'COMPLETED' " +
--         "AND a.endTime BETWEEN :start AND :end")
-- BigDecimal sumRevenueBetween(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);
-- sql function :
-- Query 9
EXPLAIN ANALYZE 
SELECT COALESCE(SUM(a.final_price), 0) 
FROM appointment a 
WHERE a.status = 'COMPLETED' 
  AND a.end_time BETWEEN :start AND :end;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT COUNT(a) FROM Appointment a " +
--         "WHERE a.status != 'CANCELLED' " +
--         "AND a.startTime BETWEEN :start AND :end")
-- long countAppointmentsBetween(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);
-- sql function :
-- Query 10
EXPLAIN ANALYZE 
SELECT COUNT(a.appointment_id) 
FROM appointment a 
WHERE a.status != 'CANCELLED' 
  AND a.start_time BETWEEN :start AND :end;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT a FROM Appointment a " +
--         "WHERE a.startTime >= :now " +
--         "AND a.status != :status " +
--         "ORDER BY a.startTime ASC")
-- List<Appointment> findUpcomingAppointments(
--         @Param("now") LocalDateTime now,
--         @Param("status") String status,
--         Pageable pageable
-- );
-- sql function :
-- Query 11
EXPLAIN ANALYZE 
SELECT a.* FROM appointment a 
WHERE a.start_time >= :now 
  AND a.status != :status 
ORDER BY a.start_time ASC
LIMIT :pageSize OFFSET :offset;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT a FROM Appointment a WHERE a.technician.technicianId = :techId " +
--         "AND a.status != 'CANCELLED' " +
--         "AND a.startTime < :to AND a.endTime > :from")
-- List<Appointment> findByTechnicianIdAndDateRange(
--         @Param("techId") Integer techId,
--         @Param("from") LocalDateTime from,
--         @Param("to") LocalDateTime to
-- );
-- sql function :
-- Query 12
EXPLAIN ANALYZE 
SELECT a.* FROM appointment a 
WHERE a.technician_id = :techId 
  AND a.status != 'CANCELLED' 
  AND a.start_time < :to 
  AND a.end_time > :from;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query(value = "SELECT * FROM v_upcoming_appointments ORDER BY start_time ASC LIMIT 10",
--         nativeQuery = true)
-- List<UpcomingAppointmentView> getUpcomingAppointmentsView();
-- sql function :
-- Query 13
EXPLAIN ANALYZE 
SELECT * FROM v_upcoming_appointments 
ORDER BY start_time ASC 
LIMIT 10;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query(value = "SELECT * FROM v_today_stats", nativeQuery = true)
-- TodayStatsView getTodayStatsView();
-- sql function :
-- Query 14
EXPLAIN ANALYZE 
SELECT * FROM v_today_stats;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT a FROM Appointment a " +
--         "WHERE (:status IS NULL OR a.status = :status) " +
--         "AND (:keyword IS NULL OR :keyword = '' OR " +
--         "LOWER(a.customer.user.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
--         "LOWER(a.technician.user.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
--         "LOWER(a.service.name) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
--         "ORDER BY a.startTime DESC")
-- Page<Appointment> findAppointmentsForAdmin(
--         @Param("keyword") String keyword,
--         @Param("status") String status,
--         Pageable pageable
-- );
-- sql function :
-- Query 15
EXPLAIN ANALYZE 
SELECT a.* FROM appointment a
LEFT JOIN customer c ON a.customer_id = c.customer_id
LEFT JOIN users u_cust ON c.user_id = u_cust.user_id
LEFT JOIN technician t ON a.technician_id = t.technician_id
LEFT JOIN users u_tech ON t.user_id = u_tech.user_id
LEFT JOIN service s ON a.service_id = s.service_id
WHERE (:status IS NULL OR a.status = :status)
  AND (:keyword IS NULL OR :keyword = '' OR 
       LOWER(u_cust.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR 
       LOWER(u_tech.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR 
       LOWER(s.name) LIKE LOWER(CONCAT('%', :keyword, '%')))
ORDER BY a.start_time DESC
LIMIT :pageSize OFFSET :offset;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT a FROM AbsenceRequest a " +
--        "WHERE a.technician.technicianId IN :techIds " +
--        "AND a.status = :status " +
--        "AND a.startDate < :endOfDay " +
--        "AND a.endDate > :startOfDay")
-- List<AbsenceRequest> findByTechnicianIdInAndStatusAndDateRange(
--        @Param("techIds") List<Integer> techIds,
--        @Param("status") String status,
--        @Param("startOfDay") LocalDateTime startOfDay,
--        @Param("endOfDay") LocalDateTime endOfDay
-- );
-- sql function :
-- Query 16
EXPLAIN ANALYZE 
SELECT * FROM absence_request 
WHERE technician_id IN (:techIds) 
  AND status = :status 
  AND start_date < :endOfDay 
  AND end_date > :startOfDay;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT ar FROM AbsenceRequest ar WHERE ar.technician.technicianId = :techId " +
--        "AND ar.endDate >= :from AND ar.startDate <= :to")
-- List<AbsenceRequest> findByTechnicianIdAndDateRange(Integer techId, LocalDateTime from, LocalDateTime to);
-- sql function :
-- Query 17
EXPLAIN ANALYZE 
SELECT * FROM absence_request 
WHERE technician_id = :techId 
  AND end_date >= :from 
  AND start_date <= :to;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT ar.appointment FROM AppointmentResource ar " +
--        "WHERE ar.resource.type = :type " +
--        "AND ar.appointment.startTime BETWEEN :start AND :end " +
--        "AND ar.appointment.status <> 'CANCELLED'")
-- List<Appointment> findAppointmentsByResourceTypeAndDate(
--        @Param("type") String type,
--        @Param("start") LocalDateTime start,
--        @Param("end") LocalDateTime end
-- );
-- sql function :
-- Query 18
EXPLAIN ANALYZE 
SELECT a.* FROM appointment a
JOIN appointment_resource ar ON a.appointment_id = ar.appointment_id
JOIN resource r ON ar.resource_id = r.resource_id
WHERE r.type = :type 
  AND a.start_time BETWEEN :start AND :end 
  AND a.status <> 'CANCELLED';

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT r FROM Resource r " +
--        "WHERE r.deleted = false " +
--        "AND (:keyword IS NULL OR :keyword = '' OR LOWER(r.name) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
--        "AND (:type IS NULL OR :type = '' OR r.type = :type) " +
--        "ORDER BY r.resourceId DESC")
-- Page<Resource> searchResources(
--        @Param("keyword") String keyword,
--        @Param("type") String type,
--        org.springframework.data.domain.Pageable pageable
-- );
-- sql function :
-- Query 19
EXPLAIN ANALYZE 
SELECT * FROM resource 
WHERE deleted = false 
  AND (:keyword IS NULL OR :keyword = '' OR LOWER(name) LIKE LOWER(CONCAT('%', :keyword, '%'))) 
  AND (:type IS NULL OR :type = '' OR type = :type) 
ORDER BY resource_id DESC
LIMIT :pageSize OFFSET :offset;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT r FROM Resource r " +
--        "WHERE r.type = :type " +
--        "AND r.resourceId NOT IN :busyIds")
-- List<Resource> findAvailableResources(@Param("type") String type,
--                                     @Param("busyIds") Collection<Integer> busyIds,
--                                     Pageable pageable);
-- sql function :
-- Query 20
EXPLAIN ANALYZE 
SELECT * FROM resource 
WHERE type = :type 
  AND resource_id NOT IN (:busyIds)
LIMIT :pageSize OFFSET :offset;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT ar.id.resourceId FROM AppointmentResource ar " +
--        "JOIN ar.appointment a " +
--        "WHERE a.status <> 'CANCELLED' " +
--        "AND a.startTime < :endTime AND a.endTime > :startTime")
-- List<Integer> findBusyResourceIds(@Param("startTime") LocalDateTime startTime,
--                               @Param("endTime") LocalDateTime endTime);
-- sql function :
-- Query 21
EXPLAIN ANALYZE 
SELECT ar.resource_id 
FROM appointment_resource ar
JOIN appointment a ON ar.appointment_id = a.appointment_id
WHERE a.status <> 'CANCELLED' 
  AND a.start_time < :endTime 
  AND a.end_time > :startTime;

--------------------------------------------------------------------------------

-- jpa function :
-- Optional<Resource> findFirstByType(String type);
-- sql function :
-- Query 22
EXPLAIN ANALYZE 
SELECT * FROM resource 
WHERE type = :type 
LIMIT 1;

--------------------------------------------------------------------------------

-- jpa function :
-- long countByType(String type);
-- sql function :
-- Query 23
EXPLAIN ANALYZE 
SELECT count(*) 
FROM resource 
WHERE type = :type;

--------------------------------------------------------------------------------

-- jpa function :
-- boolean existsByName(String name);
-- sql function :
-- Query 24
EXPLAIN ANALYZE 
SELECT EXISTS (
    SELECT 1 
    FROM resource 
    WHERE name = :name
);

--------------------------------------------------------------------------------

-- jpa function :
-- boolean existsByNameAndResourceIdNot(String name, Integer id);
-- sql function :
-- Query 25
EXPLAIN ANALYZE 
SELECT EXISTS (
    SELECT 1 
    FROM resource 
    WHERE name = :name 
      AND resource_id <> :id
);

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT DISTINCT r.type FROM Resource r ORDER BY r.type")
-- List<String> findDistinctTypes();
-- sql function :
-- Query 26
EXPLAIN ANALYZE 
SELECT DISTINCT type 
FROM resource 
ORDER BY type;

--------------------------------------------------------------------------------

-- jpa function :
-- boolean existsByType(String type);
-- sql function :
-- Query 27
EXPLAIN ANALYZE 
SELECT EXISTS (
    SELECT 1 
    FROM resource 
    WHERE type = :type
);

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT r FROM Resource r " +
--         "WHERE r.deleted = false " +
--         "AND (:keyword IS NULL OR :keyword = '' OR LOWER(r.name) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
--         "AND (:type IS NULL OR :type = '' OR r.type = :type) " +
--         "ORDER BY r.resourceId DESC")
-- Page<Resource> searchResources(
--         @Param("keyword") String keyword,
--         @Param("type") String type,
--         org.springframework.data.domain.Pageable pageable
-- );
-- sql function :
-- Query 28
EXPLAIN ANALYZE 
SELECT * FROM resource 
WHERE deleted = false 
  AND (:keyword IS NULL OR :keyword = '' OR LOWER(name) LIKE LOWER(CONCAT('%', :keyword, '%'))) 
  AND (:type IS NULL OR :type = '' OR type = :type) 
ORDER BY resource_id DESC
LIMIT :pageSize OFFSET :offset;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT s FROM ServiceResourceRequirement s WHERE s.service.serviceId = :id")
-- List<ServiceResourceRequirement> findByServiceId(@Param("id") Integer id);
-- sql function :
-- Query 29
EXPLAIN ANALYZE 
SELECT * FROM service_resource_requirement 
WHERE service_id = :id;

--------------------------------------------------------------------------------

-- jpa function :
-- @Modifying
-- @Query("UPDATE Service s SET " +
--        "s.name = :name, " +
--        "s.description = :desc, " +
--        "s.price = :price, " +
--        "s.durationMinutes = :duration, " +
--        "s.isActive = :active " +
--        "WHERE s.serviceId = :id")
-- int update(
--        @Param("id") Integer id,
--        @Param("name") String name,
--        @Param("desc") String description,
--        @Param("price") BigDecimal price,
--        @Param("duration") Integer duration,
--        @Param("active") Boolean isActive
-- );
-- sql function :
-- Query 30
EXPLAIN ANALYZE 
UPDATE service 
SET name = :name, 
    description = :desc, 
    price = :price, 
    duration_minutes = :duration, 
    is_active = :active 
WHERE service_id = :id;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query(value = "SELECT t.* FROM technician t " +
--        "JOIN technician_services ts ON t.technician_id = ts.technician_id " +
--        "JOIN users u ON t.user_id = u.user_id " +
--        "WHERE ts.service_id = :serviceId AND u.is_enabled = true",
--        nativeQuery = true)
-- List<Technician> findAllByServiceId(@Param("serviceId") Integer serviceId);
-- sql function :
-- Query 31
EXPLAIN ANALYZE 
SELECT t.* FROM technician t 
JOIN technician_services ts ON t.technician_id = ts.technician_id 
JOIN users u ON t.user_id = u.user_id 
WHERE ts.service_id = :serviceId 
  AND u.is_enabled = true;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query(value = "SELECT * FROM get_available_technicians(:serviceId, CAST(:checkTime AS TIMESTAMP))",
--        nativeQuery = true)
-- List<TechnicianOptionDto> findAvailableTechnicians(
--        @Param("serviceId") Integer serviceId,
--        @Param("checkTime") LocalDateTime checkTime
-- );
-- sql function :
-- Query 32
EXPLAIN ANALYZE 
SELECT * FROM get_available_technicians(:serviceId, CAST(:checkTime AS TIMESTAMP));

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT u FROM User u WHERE u.role = 'CUSTOMER' " +
--        "AND u.enabled = true " +
--        "AND (:keyword IS NULL OR :keyword = '' OR " +
--        "LOWER(u.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
--        "LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')))")
-- Page<User> searchCustomers(@Param("keyword") String keyword, Pageable pageable);
-- sql function :
-- Query 33
EXPLAIN ANALYZE 
SELECT * FROM users 
WHERE role = 'CUSTOMER' 
  AND enabled = true 
  AND (:keyword IS NULL OR :keyword = '' OR 
       LOWER(name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR 
       LOWER(email) LIKE LOWER(CONCAT('%', :keyword, '%')))
LIMIT :pageSize OFFSET :offset;

--------------------------------------------------------------------------------

-- jpa function :
-- @Query("SELECT new com.example.auracontrol.admin.dto.CustomerListResponse(" +
--        "u.userId, u.name, u.email, c.customerId, COUNT(a)) " +
--        "FROM User u " +
--        "JOIN Customer c ON u.userId = c.user.userId " +
--        "LEFT JOIN Appointment a ON c.customerId = a.customer.customerId " +
--        "WHERE u.role = 'CUSTOMER' " +
--        "AND (:keyword IS NULL OR LOWER(u.name) LIKE LOWER(CONCAT('%', CAST(:keyword AS string), '%')) " +
--        "OR LOWER(u.email) LIKE LOWER(CONCAT('%', CAST(:keyword AS string), '%'))) " +
--        "GROUP BY u.userId, u.name, u.email, c.customerId")
-- Page<CustomerListResponse> findAllCustomersWithAppointmentCount(@Param("keyword") String keyword, Pageable pageable);
-- sql function :
-- Query 34
EXPLAIN ANALYZE 
SELECT u.user_id, u.name, u.email, c.customer_id, COUNT(a.appointment_id) 
FROM users u 
JOIN customer c ON u.user_id = c.user_id 
LEFT JOIN appointment a ON c.customer_id = a.customer_id 
WHERE u.role = 'CUSTOMER' 
  AND (:keyword IS NULL OR 
       LOWER(u.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR 
       LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')))
GROUP BY u.user_id, u.name, u.email, c.customer_id
LIMIT :pageSize OFFSET :offset;