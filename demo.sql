-- write is the root of the first tree. contains posts and pages
insert into menu_items(menu_item_id, menu_parent_id, menu_item_order, menu_item_label)
  values(1, null, 1, 'Write');
-- posts is a branch in the write tree. contains categories code and courses
insert into menu_items(menu_item_id, menu_parent_id, menu_item_order, menu_item_label)
  values(2, 1, 1, 'Posts');
-- pages is a branch in the write tree. contains homepage and contact
insert into menu_items(menu_item_id, menu_parent_id, menu_item_order, menu_item_label)
  values(3, 1, 2, 'Pages');
-- code is a leaf in the posts branch
insert into menu_items(menu_item_id, menu_parent_id, menu_item_order, menu_item_label)
  values(4, 2, 1, 'Code');
-- courses is a leaf in the posts branch
insert into menu_items(menu_item_id, menu_parent_id, menu_item_order, menu_item_label)
  values(5, 2, 2, 'Courses');
-- homepage is a leaf in the pages branch
insert into menu_items(menu_item_id, menu_parent_id, menu_item_order, menu_item_label)
  values(6, 3, 1, 'Homepage');
-- contact is a leaf in the pages branch
insert into menu_items(menu_item_id, menu_parent_id, menu_item_order, menu_item_label)
  values(7, 3, 2, 'Contact');
-- moderate is the root of the second tree. contains comments and users
insert into menu_items(menu_item_id, menu_parent_id, menu_item_order, menu_item_label)
  values(8, null, 2, 'Moderate');
-- comments is a leaf in the moderate tree
insert into menu_items(menu_item_id, menu_parent_id, menu_item_order, menu_item_label)
  values(9, 8, 1, 'Comments');
-- users is a leaf in the moderate tree
insert into menu_items(menu_item_id, menu_parent_id, menu_item_order, menu_item_label)
  values(10, 8, 2, 'Users');

-- admin role will have permissions on all menu
insert into roles(role_id, role_name)
  values(1, 'Admin');
-- writer role will have permission to write posts
insert into roles(role_id, role_name)
  values(2, 'Writer');
-- moderator role will have permission to moderate comments
insert into roles(role_id, role_name)
  values(3, 'Moderator');

-- picard will be admin
insert into users(user_id, user_name, user_mail, user_login)
  values(1, 'Picard', 'picard@tng.com', 'picard');
-- data will be writer
insert into users(user_id, user_name, user_mail, user_login)
  values(2, 'Data', 'data@tng.com', 'data');
-- troy will be writer and moderator
insert into users(user_id, user_name, user_mail, user_login)
  values(3, 'Troy', 'troy@tng.com', 'troy');
-- riker will be writer and will have a separate permission to write on contact page
insert into users(user_id, user_name, user_mail, user_login)
  values(4, 'Riker', 'riker@tng.com', 'riker');

-- roles of each user
insert into users_roles(user_id, role_id)
  values(1, 1);
insert into users_roles(user_id, role_id)
  values(2, 2);
insert into users_roles(user_id, role_id)
  values(3, 2);
insert into users_roles(user_id, role_id)
  values(3, 3);
insert into users_roles(user_id, role_id)
  values(4, 2);

-- permissions for roles
insert into menu_roles(menu_item_id, role_id)
  values(1, 1);
insert into menu_roles(menu_item_id, role_id)
  values(8, 1);
insert into menu_roles(menu_item_id, role_id)
  values(2, 2);
insert into menu_roles(menu_item_id, role_id)
  values(9, 3);

-- permissions for users
insert into menu_users(menu_item_id, user_id)
  values(7, 4);

-- permissions for role with trees permission - administrator
select user_id, menu_permissions.get_menu_permissions(user_id) permissions 
  from users 
 where user_id = 1;

-- 2 -- permissions for role with branch permission - writer
select user_id, menu_permissions.get_menu_permissions(user_id) permissions 
  from users 
 where user_id = 2;

-- 3 -- permissions for two roles with branch permissions - writer and moderator
select user_id, menu_permissions.get_menu_permissions(user_id) permissions 
  from users 
 where user_id = 3;

-- 4 -- permissions for role with branch permissions plus user with leaf permission - writer and contact page
select user_id, menu_permissions.get_menu_permissions(user_id) permissions 
  from users 
 where user_id = 4;
