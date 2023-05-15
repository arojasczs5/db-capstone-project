/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


CREATE DATABASE IF NOT EXISTS `littlelemondb` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `littlelemondb`;

CREATE TABLE IF NOT EXISTS `bookings` (
  `BookingID` int(11) NOT NULL AUTO_INCREMENT,
  `TableNo` tinyint(4) NOT NULL,
  `BookingDate` date NOT NULL,
  `BookingSlot` time NOT NULL,
  `StaffID` int(11) NOT NULL,
  `CustomerID` int(11) NOT NULL,
  PRIMARY KEY (`BookingID`),
  KEY `fk_Bookings_Staff` (`StaffID`),
  KEY `fk_Bookings_Customers1` (`CustomerID`),
  CONSTRAINT `fk_Bookings_Customers1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_Bookings_Staff` FOREIGN KEY (`StaffID`) REFERENCES `staff` (`StaffID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `bookings` (`BookingID`, `TableNo`, `BookingDate`, `BookingSlot`, `StaffID`, `CustomerID`) VALUES
	(1, 1, '2023-12-04', '09:30:00', 4, 1),
	(2, 2, '2023-12-05', '07:30:00', 1, 2),
	(3, 5, '2023-12-05', '09:30:00', 5, 3),
	(4, 1, '2023-12-05', '09:30:00', 1, 1);

DELIMITER //
CREATE PROCEDURE `CancelOrder`(IN anOrderID INT)
BEGIN
	DECLARE confirmation VARCHAR(60);
	
	#Check if that OrderID exists
	IF EXISTS(SELECT orders.OrderID FROM orders WHERE orders.OrderID=anOrderID) THEN
		#Check if is not cancelled already
		IF NOT EXISTS(SELECT orderstatus.OrderID FROM orderstatus WHERE orderstatus.OrderID=anOrderID AND orderstatus.`Status`='Cancelled') THEN
			#Cancel orders that have only 'Reserved' status
			IF NOT EXISTS(SELECT orderstatus.OrderID FROM orderstatus WHERE orderstatus.OrderID=anOrderID AND orderstatus.`Status`<>'Reserved') THEN
				#Proceed with cancellation
				INSERT INTO orderstatus(OrderID, Date, Status) VALUES (anOrderID, NOW(), 'Cancelled');
				SET confirmation = CONCAT("Order ", anOrderID, " is cancelled");
			ELSE
				SET confirmation = "That Order was already fulfilled, can't be cancelled";
			END IF;
		ELSE
			SET confirmation = "That OrderID was already cancelled";
		END IF;		
	ELSE
	   SET confirmation = "That OrderID number doesn't exist";
	END IF;
	
	SELECT confirmation;
END//
DELIMITER ;

CREATE TABLE IF NOT EXISTS `customers` (
  `CustomerID` int(11) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(100) NOT NULL,
  `LastName` varchar(100) NOT NULL,
  `ContactNumber` int(11) NOT NULL,
  `Email` varchar(150) NOT NULL,
  `Address` varchar(255) NOT NULL,
  PRIMARY KEY (`CustomerID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `customers` (`CustomerID`, `FirstName`, `LastName`, `ContactNumber`, `Email`, `Address`) VALUES
	(1, 'Ale', 'Re', 2147483647, 'ale.re@hotmail.com', '123 Durán'),
	(2, 'Vero', 'Al', 2111111111, 'vero.al@hotmail.com', '567 Bouger'),
	(3, 'Pipo', 'Vu', 2000000000, 'pipo.vu@gmail.com', '890 Piropos');

DELIMITER //
CREATE PROCEDURE `GetMaxQuantity`()
BEGIN
SELECT MAX(orderitems.Quantity) FROM orderitems;
END//
DELIMITER ;

CREATE TABLE IF NOT EXISTS `items` (
  `ItemID` int(11) NOT NULL,
  `Name` varchar(150) NOT NULL,
  PRIMARY KEY (`ItemID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `items` (`ItemID`, `Name`) VALUES
	(1, 'Olives'),
	(2, 'Lasagna'),
	(3, 'Pizza'),
	(4, 'Rice with grey'),
	(5, 'Roasted pork'),
	(6, 'Leafhoppers'),
	(7, 'Lettuce'),
	(8, 'Tomato'),
	(9, 'Tacos'),
	(10, 'Refried beans'),
	(11, 'Chili souce'),
	(12, 'Meat burrito'),
	(13, 'Custard'),
	(14, 'Tiramisu'),
	(15, 'Jamoncillo');

CREATE TABLE IF NOT EXISTS `menuitems` (
  `MenuItemID` int(11) NOT NULL AUTO_INCREMENT,
  `StarterID` int(11) NOT NULL,
  `CourseID` int(11) NOT NULL,
  `DesertID` int(11) DEFAULT NULL,
  `Price` decimal(10,0) NOT NULL,
  PRIMARY KEY (`MenuItemID`),
  KEY `fk_MenuItems_Items1` (`StarterID`),
  KEY `fk_MenuItems_Items2` (`CourseID`),
  KEY `fk_MenuItems_Items3` (`DesertID`),
  CONSTRAINT `fk_MenuItems_Items1` FOREIGN KEY (`StarterID`) REFERENCES `items` (`ItemID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_MenuItems_Items2` FOREIGN KEY (`CourseID`) REFERENCES `items` (`ItemID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_MenuItems_Items3` FOREIGN KEY (`DesertID`) REFERENCES `items` (`ItemID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `menuitems` (`MenuItemID`, `StarterID`, `CourseID`, `DesertID`, `Price`) VALUES
	(1, 1, 3, 14, 50),
	(2, 1, 2, 14, 40),
	(3, 6, 5, 13, 65),
	(4, 7, 9, 15, 45),
	(5, 8, 12, 15, 60),
	(6, 6, 5, 15, 60);

CREATE TABLE IF NOT EXISTS `menus` (
  `MenuID` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `MenusItemsID` int(11) DEFAULT NULL,
  `Cuisine` varchar(150) NOT NULL,
  PRIMARY KEY (`MenuID`),
  KEY `fk_Menus_MenuItems1` (`MenusItemsID`),
  CONSTRAINT `fk_Menus_MenuItems1` FOREIGN KEY (`MenusItemsID`) REFERENCES `menuitems` (`MenuItemID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `menus` (`MenuID`, `Name`, `MenusItemsID`, `Cuisine`) VALUES
	(1, 'Italian menu 1', 1, 'Italian'),
	(2, 'Italian menu 2', 2, 'Italian'),
	(3, 'Cuban menu 1', 3, 'Cuban'),
	(4, 'Mexican menu 1', 4, 'Mexican'),
	(5, 'Mexican menu 2', 5, 'Mexican'),
	(6, 'Fusion menu 1', 6, 'Fusion');

-- temporal table of a VIEW to overcome dependencies error if any
CREATE TABLE `menusorderedmore2` (
	`Name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- temporal table of a VIEW to overcome dependencies error if any
CREATE TABLE `ordercostmore150` (
	`CustomerID` INT(11) NOT NULL,
	`FullName` VARCHAR(201) NOT NULL COLLATE 'utf8mb4_general_ci',
	`OrderID` INT(11) NOT NULL,
	`TotalCost` DECIMAL(10,0) NULL,
	`OrderedMenus` MEDIUMTEXT NULL COLLATE 'utf8mb4_general_ci',
	`StarterNames` MEDIUMTEXT NULL COLLATE 'utf8mb4_general_ci',
	`CurseNames` MEDIUMTEXT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS `orderitems` (
  `OrderID` int(11) NOT NULL,
  `MenuID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL,
  PRIMARY KEY (`OrderID`,`MenuID`),
  KEY `fk_OrderItems_Menus1` (`MenuID`),
  CONSTRAINT `fk_OrderItems_Menus1` FOREIGN KEY (`MenuID`) REFERENCES `menus` (`MenuID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_OrderItems_Orders1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `orderitems` (`OrderID`, `MenuID`, `Quantity`) VALUES
	(1, 4, 1),
	(1, 5, 1),
	(2, 1, 4),
	(3, 1, 2),
	(3, 2, 1),
	(4, 1, 1),
	(4, 2, 1),
	(4, 3, 1),
	(4, 6, 2);

CREATE TABLE IF NOT EXISTS `orders` (
  `OrderID` int(11) NOT NULL,
  `Date` date NOT NULL,
  `BookingID` int(11) NOT NULL,
  `TotalCost` decimal(10,0) DEFAULT NULL,
  PRIMARY KEY (`OrderID`),
  KEY `fk_Orders_Bookings1` (`BookingID`),
  CONSTRAINT `fk_Orders_Bookings1` FOREIGN KEY (`BookingID`) REFERENCES `bookings` (`BookingID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `orders` (`OrderID`, `Date`, `BookingID`, `TotalCost`) VALUES
	(1, '2023-05-04', 1, 105),
	(2, '2023-05-05', 2, 206),
	(3, '2023-05-05', 3, 90),
	(4, '2023-05-05', 4, 275);

CREATE TABLE IF NOT EXISTS `orderstatus` (
  `OrderID` int(11) NOT NULL,
  `Date` datetime NOT NULL,
  `Status` varchar(50) NOT NULL,
  PRIMARY KEY (`OrderID`,`Date`),
  CONSTRAINT `fk_OrderSatus_Orders1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `orderstatus` (`OrderID`, `Date`, `Status`) VALUES
	(1, '2023-05-04 08:01:00', 'Reserved'),
	(1, '2023-05-04 09:35:00', 'Processed'),
	(1, '2023-05-04 09:38:00', 'Delivered'),
	(1, '2023-05-04 09:46:00', 'Invoiced'),
	(2, '2023-05-04 20:16:00', 'Reserved'),
	(2, '2023-05-05 07:33:00', 'Processed'),
	(2, '2023-05-05 07:38:00', 'Delivered'),
	(2, '2023-05-05 07:41:00', 'Invoiced'),
	(3, '2023-05-05 08:12:00', 'Reserved'),
	(3, '2023-05-15 16:53:06', 'Cancelled'),
	(4, '2023-05-05 08:18:00', 'Reserved');

-- temporal table of a VIEW to overcome dependencies error if any
CREATE TABLE `ordersview` (
	`OrderId` INT(11) NOT NULL,
	`Quantity` DECIMAL(32,0) NULL,
	`TotalCost` DECIMAL(10,0) NULL
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS `staff` (
  `StaffID` int(11) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(100) NOT NULL,
  `LastName` varchar(100) NOT NULL,
  `ContactNumber` int(11) NOT NULL,
  `Email` varchar(150) NOT NULL,
  `Address` varchar(255) NOT NULL,
  `Role` varchar(100) NOT NULL,
  `AnnualSalary` decimal(10,0) NOT NULL,
  PRIMARY KEY (`StaffID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `staff` (`StaffID`, `FirstName`, `LastName`, `ContactNumber`, `Email`, `Address`, `Role`, `AnnualSalary`) VALUES
	(1, 'Pedro', 'Ma', 1777777777, 'p.ma@littlelemon..com', '123 Verde', 'Waiter', 10000),
	(2, 'María', 'Pe', 1333333333, 'm.pe@littlelemon.com', '234 Azul', 'Cook', 12000),
	(3, 'Alberto', 'Si', 1444444444, 'a.si@littlelemon.com', '567 Rojo', 'Manager', 16000),
	(4, 'Berta', 'Mu', 1555555555, 'b.mu@littlemon.com', '890 Gris', 'Cashier', 12500),
	(5, 'Silvia', 'Te', 1999999999, 's.te@littlelemon.com', '268 Violeta', 'Waiter', 10200);

-- dropping temporal table and creating final structure of a VIEW
DROP TABLE IF EXISTS `menusorderedmore2`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `menusorderedmore2` AS SELECT menus.Name
FROM menus 
WHERE menus.MenuID=ANY(SELECT orderitems.MenuID
								FROM orderitems
								GROUP BY orderitems.MenuID
								HAVING COUNT(orderitems.MenuID) > 2)

/*Same result using JOINS*/
/*
SELECT menus.Name, COUNT(orderitems.Quantity) AS OrderCount
   FROM orderitems
   INNER JOIN menus ON menus.MenuID=orderitems.MenuID
	GROUP BY menus.Name
   HAVING OrderCount > 2
*/ ;

-- dropping temporal table and creating final structure of a VIEW
DROP TABLE IF EXISTS `ordercostmore150`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ordercostmore150` AS SELECT customers.CustomerID,
		CONCAT(customers.FirstName, " ", customers.LastName) AS FullName,
		orders.OrderID, orders.TotalCost,
		GROUP_CONCAT(menus.Name SEPARATOR ", ") AS OrderedMenus,
		GROUP_CONCAT(DISTINCT i.Name SEPARATOR ", ") AS StarterNames, GROUP_CONCAT(DISTINCT j.Name SEPARATOR ", ") AS CurseNames
    FROM customers
    INNER JOIN bookings ON bookings.CustomerID=customers.CustomerID
    INNER JOIN	orders ON orders.OrderID=bookings.BookingID
    INNER JOIN orderitems ON orderitems.OrderID = orders.OrderID
    INNER JOIN menus ON menus.MenuID=orderitems.MenuID
    INNER JOIN menuitems ON menuitems.MenuItemID=menus.MenusItemsID
    INNER JOIN items i ON i.ItemID=menuitems.StarterID
    INNER JOIN items j ON j.ItemID=menuitems.CourseID
    WHERE orders.TotalCost > 150
    GROUP BY orders.OrderID ;

-- dropping temporal table and creating final structure of a VIEW
DROP TABLE IF EXISTS `ordersview`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ordersview` AS SELECT orders.OrderId,  SUM(orderitems.Quantity) AS Quantity, orders.TotalCost
    FROM orders
    INNER JOIN orderitems ON orders.OrderID=orderitems.OrderID
    GROUP BY orders.OrderId
    HAVING Quantity > 2 ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
