-- add roles
begin
  users_management.add_role('Junior Salesman');
  users_management.add_role('Salesman');
  users_management.add_role('Manager');
  users_management.add_role('Administrator');
end;
/
-- add users
begin
  users_management.add_user('Chris', 'chris@sales.com', 'chris');
  users_management.add_user('John', 'john@sales.com', 'john');
  users_management.add_user('Helena', 'helena@sales.com', 'helena');
  users_management.add_user('David', 'david@sales.com', 'david');
end;
/
-- set roles
begin
  -- Chris is Junior Salesman
  users_management.set_user_role(1, 1);
  -- John is Salesman
  users_management.set_user_role(2, 2);
  -- Helena is Manager and Administrator
  users_management.set_user_role(3, 3);
  users_management.set_user_role(3, 4);
  -- David is Manager
  users_management.set_user_role(4, 3);
end;
/
-- add menu items
begin
  menu_management.add_menu_item('Sales', null, 1);
  menu_management.add_menu_item('Sales Data', 1, 1);
  menu_management.add_menu_item('Sales Reports', 1, 2);
  menu_management.add_menu_item('Management', null, 2);
  menu_management.add_menu_item('Assignments', 4, 1);
  menu_management.add_menu_item('Bonuses', 4, 2);
  menu_management.add_menu_item('Administration', null, 3);
  menu_management.add_menu_item('Documents', 7, 1);
  -- we change the order of the leaves that have as parent Administration
  -- Accounts gets order 1 and Documents will get order 2
  menu_management.add_menu_item('Accounts', 7, 1);
end;
/
-- set menu permissions per roles
begin
  -- Junior Salesman has permissions on Sales Data
  menu_management.set_role_permission(2, 1);
  -- Salesman has permissions on Sales, including Sales Data and Sales Reports
  menu_management.set_role_permission(1, 2);
  -- Manager has permissions on Management, including Assignments and Bonuses
  menu_management.set_role_permission(4, 3);
  -- Administrator has permissions on Administration, including Accounts and Documents
  menu_management.set_role_permission(7, 4);
end;
/
-- set special menu permissions per users
begin
  -- David has a separate permission on Documents
  menu_management.set_user_permission(8, 4);
end;
/

-- Chris is Junior Salesman, has direct permission on Sales Data (2) and indirect on parent Sales (1)
-- John is Salesman, has direct permission on Sales (1) and indirect on children  Sales Data (2) and Sales Reports (3)
-- Helena is Manager and Administrator, has direct permission on Management (4) and Administration (7)
-- and indirect on children Assignments (5), Bonuses (6), Documents (8) and Accounts (9)
-- David is Manager, has direct permission on Management (4) and indirect on children Assignments (5) and Bonuses (6)
-- also, David has a special direct permission on Documents (8) and indirect on parent Administration (7)
select user_name, menu_management.get_menu_management(user_id) from users;
