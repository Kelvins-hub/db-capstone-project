CREATE DEFINER=`root`@`localhost` PROCEDURE `CancelOrder`(IN OrderID varchar (45))
BEGIN 
    DELETE FROM Orders WHERE Orders.OrderID = OrderID;
END