CREATE DEFINER=`root`@`localhost` PROCEDURE `CancelBooking`(IN BookingID VARCHAR(45))
begin 

	DELETE from Bookings
    where Bookings.BookingID = BookingID;
    
end