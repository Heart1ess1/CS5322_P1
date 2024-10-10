-- Insert data into Stores table
INSERT INTO Stores (StoreID, StoreName) VALUES (1, 'Tech Gadgets');
INSERT INTO Stores (StoreID, StoreName) VALUES (2, 'Book Haven');

-- Insert data into Consumers table
INSERT INTO Consumers (CustomerID, Username, PasswordHash, FullName, Email) VALUES (1, 'johndoe', 'hashedpassword1', 'John Doe', 'john@example.com');
INSERT INTO Consumers (CustomerID, Username, PasswordHash, FullName, Email) VALUES (2, 'janedoe', 'hashedpassword2', 'Jane Smith', 'jane@example.com');

-- Insert data into PlatformAdmins table
INSERT INTO PlatformAdmins (AdminID, Username, PasswordHash, FullName, Email) VALUES (1, 'admin1', 'adminpassword1', 'Alice Johnson', 'alice@example.com');
INSERT INTO PlatformAdmins (AdminID, Username, PasswordHash, FullName, Email) VALUES (2, 'admin2', 'adminpassword2', 'Bob Williams', 'bob@example.com');

-- Insert data into PlatformAdminStores table
INSERT INTO PlatformAdminStores (AdminID, StoreID) VALUES (1, 1); -- Alice manages Tech Gadgets
INSERT INTO PlatformAdminStores (AdminID, StoreID) VALUES (2, 2); -- Bob manages Book Haven

-- Insert data into StoreStaff table
INSERT INTO StoreStaff (StaffID, Username, PasswordHash, FullName, Email, StoreID, Role) VALUES (1, 'techstaff1', 'staffpassword1', 'Charlie Brown', 'charlie@example.com', 1, 'Admin');
INSERT INTO StoreStaff (StaffID, Username, PasswordHash, FullName, Email, StoreID, Role) VALUES (2, 'bookstaff1', 'staffpassword2', 'Dana White', 'dana@example.com', 2, 'CustomerService');

-- Insert data into Products table
INSERT INTO Products (ProductID, StoreID, ProductName, Description, Price, Quantity) VALUES (1, 1, 'Smartphone', 'Latest model smartphone with advanced features.', 699.99, 50);
INSERT INTO Products (ProductID, StoreID, ProductName, Description, Price, Quantity) VALUES (2, 1, 'Laptop', 'High-performance laptop suitable for gaming and work.', 1299.99, 30);
INSERT INTO Products (ProductID, StoreID, ProductName, Description, Price, Quantity) VALUES (3, 2, 'Novel', 'Bestselling fiction novel.', 19.99, 100);
INSERT INTO Products (ProductID, StoreID, ProductName, Description, Price, Quantity) VALUES (4, 2, 'Notebook', 'College-ruled notebook for students.', 2.99, 200);

-- Insert data into Orders table
INSERT INTO Orders (OrderID, CustomerID, TotalAmount, Status) VALUES (1, 1, 719.98, 'Pending'); -- John Doe's order
INSERT INTO Orders (OrderID, CustomerID, TotalAmount, Status) VALUES (2, 2, 22.98, 'Pending'); -- Jane Smith's order

-- Insert data into OrderItems table
INSERT INTO OrderItems (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES (1, 1, 1, 1, 699.99); -- John ordered a Smartphone
INSERT INTO OrderItems (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES (2, 1, 4, 1, 19.99); -- John also ordered a Notebook
INSERT INTO OrderItems (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES (3, 2, 3, 1, 19.99); -- Jane ordered a Novel
INSERT INTO OrderItems (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES (4, 2, 4, 1, 2.99); -- Jane also ordered a Notebook

-- Insert data into Payments table
INSERT INTO Payments (PaymentID, OrderID, Amount, PaymentMethod, Status) VALUES (1, 1, 719.98, 'Credit Card', 'Completed'); -- Payment for John's order
INSERT INTO Payments (PaymentID, OrderID, Amount, PaymentMethod, Status) VALUES (2, 2, 22.98, 'PayPal', 'Completed'); -- Payment for Jane's order

-- Insert data into CustomerMessages table
INSERT INTO CustomerMessages (MessageID, StoreID, SenderID, ReceiverID, SenderType, ReceiverType, MessageText) VALUES (1, 1, 1, 1, 'Consumer', 'Staff', 'I have a question about the smartphone.');
INSERT INTO CustomerMessages (MessageID, StoreID, SenderID, ReceiverID, SenderType, ReceiverType, MessageText) VALUES (2, 1, 1, 1, 'Staff', 'Consumer', 'Sure, how can I assist you?');
INSERT INTO CustomerMessages (MessageID, StoreID, SenderID, ReceiverID, SenderType, ReceiverType, MessageText) VALUES (3, 2, 2, 2, 'Consumer', 'Staff', 'Is the notebook available in different colors?');
INSERT INTO CustomerMessages (MessageID, StoreID, SenderID, ReceiverID, SenderType, ReceiverType, MessageText) VALUES (4, 2, 2, 2, 'Staff', 'Consumer', 'Yes, we have it in blue and black.');
