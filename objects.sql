drop table menu_users;
/
drop table menu_roles;
/
drop table menu_items;
/
drop table users_roles;
/
drop table users;
/
drop table roles;
/

-- the roles table stores the roles in the application
create table roles(
  role_id integer,
  role_name varchar2(100)
  );
/
alter table roles
  add constraint roles_pk 
  primary key(role_id);
/

-- the users table stores the users in the application
create table users(
  user_id integer,
  user_name varchar2(100),
  user_mail varchar2(100),
  user_login varchar2(100)
  );
/
alter table users
  add constraint users_pk 
  primary key(user_id);
/

-- the users-roles table stores the roles for each user
create table users_roles(
  user_id integer,
  role_id integer
  );
/
alter table users_roles
  add constraint users_roles_pk 
  primary key(user_id, role_id);
/

-- the menu-items table stores the menu items in the application
create table menu_items(
  menu_item_id integer,
  menu_parent_id integer,
  menu_item_order integer,
  menu_item_label varchar2(100)
  );
/
alter table menu_items
  add constraint menu_items_pk 
  primary key(menu_item_id);
/

-- the menu-roles table stores the permissions on menu items for each role
create table menu_roles(
  menu_item_id integer,
  role_id integer
  );
/
alter table menu_roles
  add constraint menu_roles_pk 
  primary key(menu_item_id, role_id);
/

-- the menu-users table stores the permissions on menu items for each user
create table menu_users(
  menu_item_id integer,
  user_id integer
  );
/
alter table menu_users
  add constraint menu_users_pk 
  primary key(menu_item_id, user_id);
/

create or replace package menu_permissions as

  -- returns a comma separated list of permissions on menu items for the given user
  function get_menu_permissions(pi_user_id in integer) return varchar2;

end;
/

create or replace package body menu_permissions as

  -- returns a comma separated list of permissions on child menu items for the given menu item
  function get_downstream_permissions(pi_menu_item_id in integer) return varchar2 as
    permissions varchar2(100);
  begin
    -- parse the child menu items for the given menu item and their children
    for d in (select menu_item_id 
                from menu_items 
               start with menu_item_id = pi_menu_item_id 
             connect by prior menu_item_id = menu_parent_id) loop
      permissions := permissions || d.menu_item_id || ',';
    end loop;
    return permissions;
  end;
  
  -- returns a comma separated list of permissions on parent menu items for the given menu item
  function get_upstream_permissions(pi_menu_item_id in integer) return varchar2 as
    permissions varchar2(100);
  begin
    -- parse the parent menu items for the given menu item and their parents
    for u in (select menu_item_id 
                from menu_items 
               start with menu_item_id = pi_menu_item_id 
             connect by prior menu_parent_id = menu_item_id) loop
      permissions := permissions || u.menu_item_id || ',';
    end loop;
    return permissions;
  end;
  
  -- returns a comma separated list of permissions on menu items set per user for the given user
  function get_user_permissions(pi_user_id in integer) return varchar2 as
    permissions varchar2(100);
  begin
    -- parse the permissions on menu items set per user
    for p in (select menu_item_id 
                from menu_users 
               where user_id = pi_user_id) loop
      -- get the permissions on child menu items
      permissions := permissions || get_downstream_permissions(p.menu_item_id);
      -- get the permissions on parent menu items
      permissions := permissions || get_upstream_permissions(p.menu_item_id);
    end loop;  
    return permissions;
  end;
  
  -- returns a comma separated list of permissions on menu items set per role for the given role
  function get_role_permissions(pi_role_id in integer) return varchar2 as
    permissions varchar2(100);
  begin
    -- parse the permissions on menu items set per role
    for p in (select menu_item_id 
                from menu_roles 
               where role_id = pi_role_id) loop
      -- get the permissions on child menu items
      permissions := permissions || get_downstream_permissions(p.menu_item_id);
      -- get the permissions on parent menu items
      permissions := permissions || get_upstream_permissions(p.menu_item_id);
    end loop;  
    return permissions;
  end;
  
  -- returns a comma separated list of permissions on menu items set per role for the roles of the given user
  function get_roles_permissions(pi_user_id in integer) return varchar2 as
    permissions varchar2(100);
  begin
    -- parse the roles set to the user
    for r in (select role_id 
                from users_roles 
               where user_id = pi_user_id) loop
      -- get the permissions on menu items set per role for the given role
      permissions := permissions || get_role_permissions(r.role_id);
    end loop;  
    return permissions;
  end;
  
  -- returns a comma separated list of permissions on menu items for the given user
  function get_menu_permissions(pi_user_id in integer) return varchar2 as
    permissions varchar2(100);
  begin
    -- get the permissions on menu items set per role for the roles of the given user
    permissions := permissions || get_roles_permissions(pi_user_id);
    -- get the permissions on menu items set per user for the given user
    permissions := permissions || get_user_permissions(pi_user_id);
    permissions := rtrim(permissions,',');  
    -- remove duplicates and order the items 
    execute immediate 'select listagg(distinct menu_item_id, '', '') within group (order by menu_item_id) 
                         from menu_items 
                        where menu_item_id in (' || permissions || ')' 
                 into permissions;
    return permissions;
  end;

end;
