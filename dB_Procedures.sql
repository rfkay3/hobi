/* Create Stored Procedures for HobiDB */

use master
use HobiDB



/*  intialize user info
	intialize table user info with userID
*/
go	
	create procedure spInitUserInfo
	@userID int,
	@email varchar(255),
	@fName varchar(255),
	@lName varchar(255)
	as
	begin
	if(exists (select userID from UserLogin where userID = @userID))
		begin
		insert into UserInfo(email, fName, lName, userID)
		values(@email, @fName, @lName, @userID)
		select 'success'
		end
	else
	begin
		select 'failed: user not found'
	end
	end

/*  add user
	Takes username and password and stores new user in user login
	Additionally calls init user info to add new user id
*/
go
	create procedure spAddUser
		@userName varchar(255),
		@password varchar(255)
	as
	begin
		set nocount on

		begin try
			if (not exists (select top(1) userId from UserLogin where userName = @userName))
			begin
				insert into UserLogin(userName, passHash)
				values(@userName, HASHBYTES('SHA2_512',@password))


				/* init user info*/
				declare @newUserID int = (select top(1) userID from userLogin where userName = @userName)

				exec spInitUserInfo @newUserID ,'','',''

				select 'success'
			end
			else 
				select 'user name already exists'

		end try

		begin catch
			select ERROR_MESSAGE()
		end catch
		set nocount off
	end





	
/*  login existing user
	Takes username and password and verifies credentials
	Returns success for correct credentials
*/

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
					HASHBYTES('SHA2_512', @passHash) = UL.passHash
				)))
		begin
			select 'success'
		end
		else
		begin
			select 'failed'
		end
	end




	
/*  edit username 
    edit username stored in userlogin given userID, current username, and  username to switch to	
*/
go
	create procedure spEditUserName
	@userID int,
	@newUserName varchar(255)
	as
	begin
		if(exists (select top(1) userID from UserLogin where userID = @userID))
		begin
			update UserLogin
			set userName = @newUserName
			where userID = @userID
			select 'success'
		end
		else
		begin
			select 'failed: incorrect userID or username'
		end
	end









/*  Add user interest 
	Add interest tag to user interests
*/
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
		select 'sucess'
		end
		select 'failed: duplicat interest'
	end





/*  remove user interest
	remove interest tag from user interests table
*/

go 
	create procedure spRemoveUserInterest
	@userID int,
	@interestTag varchar(255)
	as
	begin
		
		if(exists (select top(1) interestTag from UserInterests where userID=userID AND interestTag = @interestTag) )
		begin
			delete from UserInterests where userID = @userID AND interestTag = @interestTag
			select 'success'
		end
		select 'failed: no matching interest tag found'

	end




/*  edit username 
	edit username in userLogin table
*/
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



/*  edit users image 
	
*/
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
			select 'edited user photo' 
		end
		else if(exists (select top(1) userID from UserLogin where userID = @userID))
		begin
			insert into UserImage(userID, userImage)
			values(@userID, @userImage)
		end
		else
		begin
			select 'failed: user not found' 
		end
	end


/* edit user info  (fname) */
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
			select 'success'
		end
		else
		begin
			select 'failed: user not found' 
		end
	end


/* edit user info  (lName) */
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
			select 'success' 
		end
		else
		begin
			select 'failed: user not found' 
		end
	end

	
/* edit user info (email) */
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
			select 'success'
		end
		else
		begin
			select 'failed: user not found' 
		end
	end


/* create new group - init group info*/
go
	create procedure spAddGroup
	@groupName varchar(255),
	@userID int,
	@groupDescription varchar(255),
	@groupCountry varchar(255),
	@groupState varchar(255),
	@groupCity varchar(255),
	@latitude float,
	@longitude float,
	@isPrivate bit
	as
	begin
		
		insert into Locations (country, state, city, latitude, longitude)
		values (@groupCountry, @groupState, @groupCity, @latitude, @longitude)

		declare @locationID int
		set @locationID = (select top(1) locationID from Locations where ((country = @groupCountry and state=@groupState and city = @groupCity) or (latitude = @latitude and longitude = @longitude)))



		if(not exists (select top(1) groupID from GroupInfo where groupName = @groupName and (select top(1) city from Locations where locationID = @locationID)= @groupCity))
		begin
			insert into GroupInfo(groupName, groupDescription, locationID, adminUserID ,isPrivate)
			values (@groupName, @groupDescription, @locationID, @userID , @isPrivate)
			select 'success'
		end
		else
		begin
			select 'Group already exists' 
		end
	end




/* add group interest */
go
	create procedure spAddGroupInterest
	@groupID int,
	@groupInterestTag varchar(255)
	as
	begin
		if(exists (select top(1) groupID from GroupInfo where groupID = @groupID))
		begin
			if(not exists (select top(1) groupInterestTag from GroupInterests where groupID = @groupID and groupInterestTag = @groupInterestTag))
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
			select 'failed: interest not found'
		end
	end




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



/* add group event*/
go
	create procedure spAddGroupEvent
	@groupID int,
	@userID int,
	@scheduledTimestamp DATETIME,
	@country varchar(255),
	@state varchar(255),
	@city varchar(255),
	@latitude float,
	@longitude float,
	@description varchar(max)
	as
	begin

		/*insert into locations and store location id*/
		insert into Locations (country, state, city, latitude, longitude)
		values (@country, @state, @city, @latitude, @longitude)

		declare @locationID int
		set @locationID = (select top(1) locationID from Locations where ((country = @country and state=@state and city = @city) or (latitude = @latitude and longitude = @longitude)))



		if(exists (select groupID from GroupInfo where groupID = @groupID))
		begin
			insert into GroupEvent(groupID, userID,creationTimestamp, scheduledTimestamp, description, locationID)
			values(@groupID, @userID, CURRENT_TIMESTAMP, @scheduledTimestamp, @description, @locationID)
			select 'success'
		end
		else
		begin
			select 'failed: cannot find group'
		end
	end



/*  get group messages from a given group - include group events
	order by date published most recent

	also supply number of messages to return

	for each message, return userID, time, and content
	for each event, return username, creation time, schedualed time, location ,and content
*/
go
	create procedure spGetGroupMessages
	@groupID int,
	@messageCount int
	as
	begin

	((select top(@messageCount) UL.userName [userName], GP.postTime as [PostTime] , Null, Null [country] ,Null [state], Null [city], Null [latitude], Null [longitude], GP.postContent [Content] from UserLogin UL, GroupPost GP
		where GP.groupID = @groupID and GP.userID = UL.userID
	)
	union
	(select  top(@messageCount) UL.userName [userName], GE.creationTimestamp as [PostTime], GE.scheduledTimestamp, L.country [country] ,L.state [state], L.city [city], L.latitude [latitude], L.longitude [longitude], GE.description [Content] from UserLogin UL, GroupEvent GE, Locations L
		where GE.groupID = @groupID and GE.userID = UL.userID and GE.locationID = L.locationID
	)) order by postTime desc 


	end



/* user rsvp to event  -add user to event rsvp list*/
go
	create procedure spRsvpToEvent
	@userID int,
	@groupEventID int,
	@groupID int
	as
	begin
		if(exists (select groupEventID from GroupEvent where groupEventID = @groupEventID and groupID = @groupID))
		begin
			insert into RSVPUser(userID, groupEventID, groupID)
			values(@userID, @groupEventID, @groupID)
			select 'success'
		end
		else
		begin
			select 'failed: could not find group event'  
		end
	end



/* set group admin */
go
	create procedure spSetGroupAdmin
	@userID int,
	@groupID int
	as
	begin
		if(exists(select groupID from GroupInfo where groupID = @groupID))
		begin
			update GroupInfo
			set adminUserID = @userID
			where groupID = @groupID
			select 'success'
		end
		else
		begin
			select 'failed'
		end
	end

