CREATE DEFINER=`root`@`localhost` PROCEDURE `ManageBooking`(IN bookingDate DATE, IN tableNumber INT)
BEGIN
    DECLARE tableCount INT;
    SELECT COUNT(*) INTO tableCount
    FROM Bookings 
    WHERE BookingDate = bookingDate AND TableNumber = tableNumber;

    IF tableCount > 0 THEN
        SELECT 'Table is already booked' AS BookingStatus;
    ELSE
        SELECT 'Table is available' AS BookingStatus;
    END IF;
END