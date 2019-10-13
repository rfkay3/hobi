

/*stored proceedures*/
use HobiDB

/*
	Add User
	given a username and password, insert new user into userlogin (only if username not already in dB)
*/


go
	create procedure spAddUser
		@userName nvarchar(255),
		@password nvarchar(255)
	as
	begin
		set nocount on

		begin try
			if (not exists (select top(1) userId from UserLogin where userName = @userName))
			begin
				insert into UserLogin(userName, passHash)
				values(@userName, HASHBYTES('SHA2_512', @password))

				select ('success')
			end
			else 
				select 'user name already exists'

		end try

		begin catch
			return ERROR_MESSAGE()
		end catch
	end

/* Test add user */
exec spAddUser
	@userName = 'test2', @password = 'test'

/* reomve user? */



/* login user 
	Return sucessfully logged in or failed to login: ERROR  -  cannot compare input password with enrcypted passHash
*/


drop procedure spLoginUser

go 
	create procedure spLoginUser
	@userName varchar(255),
	@passHash varchar(255)
	as
	begin
		if(exists (select top(1) userID from UserLogin as UL
			where
				(
					@userName = UL.userName

					AND
					HASHBYTES('SHA2_512', @passHash) = HASHBYTES('SHA2_512', passHash)
					
				)))


				/*
				(userName = @userName or 
				(select top(1) UI.email from UserInfo as UI where userID = UI.userID) = @userName) 
				and passHash = HASHBYTES('SHA2_512', @passHash)
				)))
				*/
		begin
		select 'success'
		end
		else
		begin
			select 'failed'
		end
	end

/* test login */
exec spLoginUser 'test2', 'test'



select userID from UserLogin where passHash = HASHBYTES('SHA2_512', 'test')
select userID from UserLogin where passHash = 'test'



/* Add user interest */
go 
	create procedure spAddUserInterests
	@userID int,
	@interestTag varchar(255)
	as
	begin

		if(not exists (select top(1) interestTag from UserInterests where userID=userID AND interestTag = @interestTag))
		begin
		insert into UserInterests(userID, interestTag)
		values(@userID, @interestTag)
		return 'sucess'
		end
		return 'failed: duplicat interest'
	end

/* edit username from tbl userLogin */
go
	create procedure spEditUserName
	@userID int,
	@newUserName varchar(255)
	as
	begin
		if(exists (select userID from UserLogin where userID = @userID))
		begin
			update UserLogin
			set userName = @newUserName
			where userID = @userID
			select 'success'
		end
		else
		begin
			select 'failed: userID not found'
		end
	end

/* test edit user name */
exec spEditUserName 1, 'testChangeUserName'
select * from UserLogin


/* test add user interest */
exec spAddUserInterests
1, 
'my interest'


/* remove user interest */
go 
	create procedure spRemoveUserInterest
	@userID int,
	@interestTag varchar(255)
	as
	begin
		
		if(exists (select top(1) interestTag from UserInterests where userID=userID AND interestTag = @interestTag) )
		begin
			delete from UserInterests where userID = @userID AND interestTag = @interestTag
			return 'success'
		end
		return 'failed: no matching interest tag found'

	end

/* test remove user interest */
select * from UserInterests
exec spRemoveUserInterest
1,
'my interest'


/* edit user info (email)   automatically inits userInfo table */
go	
	create procedure spEditUserInfoEmail
	@userID int,
	@email varchar(255)
	as
	begin
		if(exists (select top(1) userID from UserInfo where userID = @userID))
		begin
			update UserInfo
			set email = @email
			where userID = @userID
		end
		else
		begin
			insert into UserInfo(email, fName, lName, userID)
			values(@email,'','',@userID)
		end
	end

/* testing edit email */
exec spEditUserInfoEmail 3, 'test@test.com' 

select * from UserInfo



/* edit user info  (fname)  automatically inits userInfo table*/
go
	create procedure spEditUserInfoFName
	@userID int,
	@fName varchar(255)
	as
	begin
		if(exists (select top(1) userID from UserInfo where userID = @userID))
		begin
			update UserInfo
			set fName = @fName
			where userID = @userID
		end
		else
		begin
			insert into UserInfo(email, fName, lName, userID)
			values('',@fName,'',@userID)
		end
	end

	
/* testing edit fName */
exec spEditUserInfoFName 2, 'Peggy' 

select * from UserInfo



/* edit user info  (lName)  automatically inits userInfo table*/
go
	create procedure spEditUserInfoLName
	@userID int,
	@lName varchar(255)
	as
	begin
		if(exists (select top(1) userID from UserInfo where userID = @userID))
		begin
			update UserInfo
			set lName = @lName
			where userID = @userID
		end
		else
		begin
			insert into UserInfo(email, fName, lName, userID)
			values('','',@lName,@userID)
		end
	end

	
/* testing edit lName */
exec spEditUserInfoLName 4, 'The Pirate' 

select * from UserInfo



/* edit users image */
go
	create procedure spEditUserImage
	@userID int,
	@userImage varbinary(max)
	as
	begin
		if(exists (select top(1) userID from UserImage where userID = @userID))
		begin
		update UserImage
		set userImage = @userImage
		where userID  = @userID
		end
		else
		begin
			insert into UserImage(userImage, userID)
			values(@userImage, @userID)
		end
	end


/* test edit image */
declare @testImg varbinary(max)
set @testImg = CAST('xyz' as varbinary)
exec spEditUserImage 1, @testImg

select * from UserImage


/* create new group - init group info*/
go
	create procedure spAddGroup
	@groupName varchar(255),
	@groupDescription varchar(255),
	@groupLocation varchar(255),
	@isPrivate bit
	as
	begin
		if(not exists (select top(1) groupID from GroupInfo where groupName = @groupName))
		begin
			insert into GroupInfo(groupName, groupDescription, groupLocation, isPrivate)
			values (@groupName, @groupDescription, @groupLocation, @isPrivate)
			select 'success'
		end
		else
		begin
			select 'Group already exists' 
		end
	end

/* Test add group */
exec spAddGroup 'test', 'lorum testium description', 'Oxford', 0 

select * from GroupInfo


/* add group interest */
go
	create procedure spAddGroupInterest
	@groupID int,
	@groupInterestTag varchar(255)
	as
	begin
		if(exists (select top(1) groupID from GroupInfo where groupID = @groupID))
		begin
			if(not exists (select top(1) groupInterestTag from GroupInterests where groupInterestTag = @groupInterestTag))
			begin
				insert into GroupInterests(groupID, groupInterestTag)
				values(@groupID, @groupInterestTag)
				select 'sucess'
			end
			else
			begin
				select 'failed: Group interest already exists'
			end
		end
		else
		begin
			select 'falied: group not found'
		end
	end

/* test add group interest */
exec spAddGroupInterest 1, 'test interest'
select * from GroupInterests

/* remove group interest */ 
go 
	create procedure spRemoveGroupInterest
	@groupID int,
	@groupInterestTag varchar(255)
	as
	begin
		if(exists (select groupInterestTag from GroupInterests where groupID = @groupID AND groupInterestTag = @groupInterestTag))
		begin
			delete from GroupInterests where groupID = @groupID and groupInterestTag = @groupInterestTag
			select 'success'
		end
		else
		begin
			select 'failed'
		end
	end

/* test remove group interest */
exec spRemoveGroupInterest 1, 'test interest'

select groupInterestTag from GroupInterests


/* add group post info

should this take a time as a param or just insert current timestamp?'

*/

go
	create procedure spAddGroupPost
	@groupID int,
	@userID int,
	@postContent varchar(255)
	as
	begin
		insert into GroupPost(groupID, userID, postTime, postContent)
		values(@groupID, @userID, CURRENT_TIMESTAMP, @postContent)
		select 'success'
	end

/* Test add group post info */
exec spAddGroupPost 1, 1, 'test content'

select * from GroupPost


/* add group event*/
go
	create procedure spAddGroupEvent
	@groupID int,
	@userID int,
	@creationTimestamp DATETIME,
	@scheduledTimestamp DATETIME,
	@description varchar(max)
	as
	begin
		if(exists (select groupID from GroupInfo where groupID = @groupID))
		begin
			insert into GroupEvent(groupID, creationTimestamp, scheduledTimestamp, description, userID)
			values(@groupID, @creationTimestamp, @scheduledTimestamp, @description, @userID)
			select 'success'
		end
		else
		begin
			select 'failed: cannot find group'
		end
	end

/* test add group event */

exec spAddGroupEvent 1, 1, '2019-10-13 16:24:25.910', '2019-10-13 16:24:25.910', 'test'

select * from GroupEvent

