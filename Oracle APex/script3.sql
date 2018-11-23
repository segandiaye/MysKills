--------------------------DAGE DAGE DAGE-------------------------------------   
-----------------------------TABLES TABLES-----------------------------------------
CREATE TABLE DAGE_SATISFACTIONS(
  ID_SATISFACTION NUMBER(38) NOT NULL,
  ENQUETE_SATISFACTIONS VARCHAR2(100) NOT NULL,
  DIRECTION  VARCHAR2(100)  NOT NULL,
  CONFORMITE  VARCHAR2(100)  NOT NULL,
  DELAI_TRAITEMENT  VARCHAR2(100)  NOT NULL,
  QUALITE VARCHAR2(100)  NOT NULL,
  DATE_SATISFACTION DATE
);

ALTER TABLE DAGE_SATISFACTIONS ADD (
  CONSTRAINT SATISFACTIONS_pk PRIMARY KEY (ID_SATISFACTION));

CREATE SEQUENCE SATISFACTIONS_seq
	START WITH 1
    INCREMENT BY 1;

CREATE OR REPLACE TRIGGER SATISFACTIONS_bir 
BEFORE INSERT ON DAGE_SATISFACTIONS 
FOR EACH ROW
BEGIN
  SELECT SATISFACTIONS_seq.NEXTVAL
  INTO   :new.ID_SATISFACTION
  FROM   dual;
END;
/
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
---------------SECURITE AUTHENTIFICATION-------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
---------------------------NEW USER------------------------------------------------
-----------------------------------------------------------------------------------
create table   USER_ACCOUNT_D
(
  USER_NAME VARCHAR2(30) not null,
  PASSWORD  VARCHAR2(30) not null,
  USER_TYPE VARCHAR2(30) not null,
  ACTIVE    VARCHAR2(60) not null,
  EMAIL     VARCHAR2(64) not null,
  FULL_NAME VARCHAR2(64) not null
) ;
  
alter table  USER_ACCOUNT_D
  add constraint  USER_ACCOUNT_D_PK primary key (USER_NAME) ;
alter table  USER_ACCOUNT_D
  add constraint  USER_ACCOUNT_D_UK unique (EMAIL) ;
 
insert into  USER_ACCOUNT_D (USER_NAME, PASSWORD, USER_TYPE,
 ACTIVE, EMAIL, FULL_NAME)
values ('admin', 'admin', 'admin', 'ADMIN', 'admin@lonase.sn', 'Admin');

 
Commit;


CREATE OR REPLACE TRIGGER admin_trigger_IUD
BEFORE INSERT OR UPDATE ON  USER_ACCOUNT_D
FOR EACH ROW
DECLARE
BEGIN
  IF :old.USER_NAME = 'admin' and :new.USER_NAME <> 'admin'
   THEN
	RAISE_APPLICATION_ERROR (-20101, 'Vous ne pouvez pas modifier le champ admin.');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER admin_trigger_Da
BEFORE DELETE ON  USER_ACCOUNT_D
FOR EACH ROW
DECLARE
BEGIN
  IF :old.USER_NAME = 'admin'
   THEN
	RAISE_APPLICATION_ERROR (-20102, 'Vous ne pouvez pas supprimer un administrateur.');
  END IF;
END;
/

--------------------------PROCEDURE OF SECURITY----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
Create Or Replace Package Pkg_Security_D Is
 
  Function Authenticate_User(p_User_Name Varchar2
                            ,p_Password  Varchar2) Return Boolean;
 
  Procedure Process_Login(p_User_Name Varchar2
                         ,p_Password  Varchar2
                         ,p_App_Id    Number);
						 
  Function Authenticate_User2(p_User_Name Varchar2
                            ,p_Password  Varchar2) Return Boolean;
 
  Procedure Process_Login2(p_User_Name Varchar2
                         ,p_Password  Varchar2
                         ,p_App_Id    Number);
						 
End Pkg_Security_D;
/

Create Or Replace Package Body Pkg_Security_D Is
-------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
  Function Authenticate_User(p_User_Name Varchar2
                            ,p_Password  Varchar2) Return Boolean As
     v_Password  USER_ACCOUNT_D.Password%Type;
     v_Active    USER_ACCOUNT_D.Active%Type;
     v_Email     USER_ACCOUNT_D.Email%Type;
  Begin
     If p_User_Name Is Null Or p_Password Is Null Then
  
        -- Write to Session, Notification must enter a username and password
        Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                   ,'Veuillez entrer les bons identifiants.');
        Return False;
     End If;
     ----
     Begin
        Select u.Active
              ,u.Password
              ,u.Email
        Into   v_Active
              ,v_Password
              ,v_Email
        From    USER_ACCOUNT_D u
        Where  u.User_Name = p_User_Name;
     Exception
        When No_Data_Found Then
      
           -- Write to Session, User not found.
           Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                      ,'Utilisateur inconnu.');
           Return False;
     End;
     If v_Password <> p_Password Then
    
        -- Write to Session, Password incorrect.
        Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                   ,'Password incorrect');
        Return False;
     End If;
     ---
     -- Write user information to Session.
     --
     Apex_Util.Set_Session_State('SESSION_USER_NAME'
                                ,p_User_Name);
     Apex_Util.Set_Session_State('SESSION_EMAIL'
                                ,v_Email);
     ---
     ---
     Return True;
  End;
  ------------------------------------------------------------------------------
  Procedure Process_Login(p_User_Name Varchar2
                         ,p_Password  Varchar2
                         ,p_App_Id    Number) As
     v_Result Boolean := False;
  Begin
     v_Result := Authenticate_User(p_User_Name
                                  ,p_Password);
     If v_Result = True Then
        -- Redirect to Page 1 (Home Page).
        Wwv_Flow_Custom_Auth_Std.Post_Login(p_User_Name -- p_User_Name
                                           ,p_Password -- p_Password
                                           ,v('APP_SESSION') -- p_Session_Id
                                           ,p_App_Id || ':1' -- p_Flow_page
                                            );
     Else
        -- Login Failure, redirect to page 101 (Login Page).
        Owa_Util.Redirect_Url('f?p=&APP_ID.:101:&SESSION.');
     End If;
  End;
------------------------------------------------------------------------------------------------------------------------------2
------------------------------------------------------------------------------------------------------------------------------2
------------------------------------------------------------------------------------------------------------------------------2
------------------------------------------------------------------------------------------------------------------------------2
 Function Authenticate_User2(p_User_Name Varchar2
                            ,p_Password  Varchar2) Return Boolean As
     v_Password  USER_ACCOUNT_D.Password%Type;
     v_Active    USER_ACCOUNT_D.Active%Type;
     v_Email     USER_ACCOUNT_D.Email%Type;
     v_Username     USER_ACCOUNT_D.USER_NAME%Type;
  Begin
     If p_User_Name Is Null Or p_Password Is Null Then
  
        -- Write to Session, Notification must enter a username and password
        Apex_Util.Set_Session_State('LOGIN_MESSAGE2'
                                   ,'Veuillez entrer vos identifiants.');
        Return False;
     End If;
     ---------------------------------------------------------------------------
    
     ---------------------------------------------------------------------------
     ----
     Begin
        Select u.Active
              ,u.Password
              ,u.Email
        Into   v_Active
              ,v_Password
              ,v_Email
        From    USER_ACCOUNT_D u
        Where  u.User_Name = p_User_Name;
     Exception
        When No_Data_Found Then
      
           -- Write to Session, User not found.
           Apex_Util.Set_Session_State('LOGIN_MESSAGE2'
                                      ,'Utilisateur inconnu.');
           Return False;
     End;
     If v_Password <> p_Password Then
    
        -- Write to Session, Password incorrect.
        Apex_Util.Set_Session_State('LOGIN_MESSAGE2'
                                   ,'Password incorrect');
        Return False;
     End If;
     ---
     -- Write user information to Session.
     --
     Apex_Util.Set_Session_State('SESSION_USER_NAME2'
                                ,p_User_Name);
     Apex_Util.Set_Session_State('SESSION_EMAIL2'
                                ,v_Email);
     ---
     ---
     Return True;
  End;
  ------------------------------------------------------------------------------
  Procedure Process_Login2(p_User_Name Varchar2
                         ,p_Password  Varchar2
                         ,p_App_Id    Number) As
     v_Result Boolean := False;
  Begin
     v_Result := Authenticate_User2(p_User_Name
                                  ,p_Password);
     If v_Result = True and p_User_Name='admin' then
        -- Redirect to Page 1 (Home Page).
        Wwv_Flow_Custom_Auth_Std.Post_Login(p_User_Name -- p_User_Name
                                           ,p_Password -- p_Password
                                           ,v('APP_SESSION') -- p_Session_Id
                                           ,p_App_Id || ':1' -- p_Flow_page
                                            );
     Else
        -- Login Failure, redirect to page 101 (Login Page).
        Owa_Util.Redirect_Url('f?p=&APP_ID.:101:&SESSION.');
     End If;
     ---------------------------------------------------------------------------
  End;
  
 
End Pkg_Security_D;
/
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------