CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `little_lee_dm`.`ordersview` AS
    SELECT 
        `little_lee_dm`.`orders`.`OrderID` AS `Orderid`,
        `little_lee_dm`.`orders`.`Quantity` AS `Quantity`,
        `little_lee_dm`.`orders`.`TotalCost` AS `TotalCost`
    FROM
        `little_lee_dm`.`orders`
    WHERE
        (`little_lee_dm`.`orders`.`Quantity` > 2)