CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMaxQuantity`()
BEGIN 
    SELECT Quantity as "Max Quantity in Orders"  FROM Orders
    Order by Quantity Desc Limit 1;
END