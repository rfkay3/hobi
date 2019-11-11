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
			select 'success' as [Success], userID as [userID] from UserLogin where userName = @userName
		end
		else
		begin
			select 'failed'
		end
	end

	drop procedure spLoginUser
	
/*  edit username 
    edit username stored in userlogin given userID, current username, and  username to switch to	
	Takes a username and password and changes username if password is correct
*/
go
	create procedure spEditUserName
	@username varchar(255),
	@password varchar(255),
	@newUserName varchar(255)
	as
	begin
		if(exists (select top(1) userID from UserLogin as UL
			where
				(
					@userName = UL.userName

					AND
					HASHBYTES('SHA2_512', @password) = UL.passHash
				)))
			begin
				if(not exists (select userName from UserLogin where userName = @newUserName))
				begin
				update UserLogin
				set userName = @newUserName
				where userName = @username
				select 'success'
				end
				else
				begin
					select 'failed: that user name already exists'
				end
			end
			else
			begin
				select 'failed: incorrect password'
			end
	end


/* edit user password */
go
create procedure spEditUserPassword
@userID int,
@password varchar(255),
@newPassword varchar(255)
as
begin
	if( exists (select top(1) userID from UserLogin where userID = @userID
		and
		passHash = HASHBYTES('SHA2_512', @password)))
	begin
		update UserLogin
		set passHash = HASHBYTES('SHA2_512', @password)
		where userID = @userID
		select 'success'
	end
	else
	begin
		select 'failed: Incorrect Password'
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



/* Admin only - edit group name*/
go
	create procedure spEditGroupName
	@groupID int,
	@userID int,
	@newGroupName varchar(255)
	as
	begin
		if(exists(select top(1) adminUserID from GroupInfo where @userID = adminUserID and @groupID = groupID))
		begin
			update GroupInfo
			set groupName = @newGroupName
			where groupID = @groupID
			select 'success'
		end
		else
		begin
			select 'failed'
		end

	end


/* Admin only - edit group privacy*/
go
	create procedure spEditGroupPrivacy
	@groupID int,
	@userID int,
	@privacy bit
	as
	begin
		if(exists(select top(1) adminUserID from GroupInfo where @userID = adminUserID and @groupID = groupID))
		begin
			update GroupInfo
			set isPrivate = @privacy
			where groupID = @groupID
			select 'success'
		end
		else
		begin
			select 'failed'
		end
	end


/* Admin only - add group moderator*/
go
create procedure spAddGroupModerator
@userID int,
@newModID int,
@groupID int
as
begin
	if(exists(select top(1) adminUserID from GroupInfo where @userID = adminUserID and @groupID = groupID))
	begin
	if(not exists(select top(1) userID from GroupModerators where userID = @newModID and groupID = @groupID))
		begin
		insert into GroupModerators (userID, groupID)
		values(@newModID, @groupID)
		select 'success'
		end
		else
		begin
			select 'failed: user is already a mod'
		end
	end
	else
	begin
		select 'failed'
	end
end



/* Admin only - remove group moderator*/
go
create procedure spRemoveGroupModerator
@userID int,
@modID int,
@groupID int
as
begin
	if(exists(select top(1) adminUserID from GroupInfo where @userID = adminUserID and @groupID = groupID))
	begin
	if(exists(select top(1) userID from GroupModerators where userID = @modID and groupID = @groupID))
		begin
		delete from GroupModerators where groupID = @groupID and userID = @modID
		select 'success'
		end
		else
		begin
			select 'failed: user is not a mod'
		end
	end
	else
	begin
		select 'failed'
	end
end



/* Admin Only - edit group icon */
go
create procedure spEditGroupIcon
@userID int,
@groupID int,
@groupImage varbinary(max)
as
begin
	if(exists(select top(1) adminUserID from GroupInfo where @userID = adminUserID and @groupID = groupID))
	begin
		if(exists (select top(1) groupID from GroupImage where groupID = @groupID))
		begin
			update GroupImage
			set groupImage = @groupImage
			where groupID = @groupID
			select 'success'
		end
		else
		begin
			insert into GroupImage(groupImage, groupID)
			values(@groupImage, @groupID)
			select 'sucess'
		end
	end
	else
	begin
		select 'failed'
	end
end



/*
* Admin only - edit group location
*/
go
create procedure spEditGroupLocation
@userID int,
@groupID int,
@country varchar(255),
@state varchar(255),
@city varchar(255),
@latitude float,
@longitude float
as
begin
	if(exists(select top(1) adminUserID from GroupInfo where @userID = adminUserID and @groupID = groupID))
	begin
		update Locations
		set country = @country,
		state = @state,
		city = @city,
		latitude = @latitude,
		longitude = @longitude
		where locationID = (select top(1) locationID from GroupInfo where groupID = @groupID)
		select 'success'
	end
	else
	begin
		select 'failed'
	end
end


/* Admin only - edit group description */
go
create procedure spEditGroupDescription
@userID int,
@groupID int,
@description varchar(255)
as
begin
	if( (select top(1) adminUserID from GroupInfo where groupID = @groupID) = @userID)
	begin
		if(exists (select top(1) groupID from GroupInfo where groupID = @groupID ))
		begin
			update GroupInfo
			set groupDescription = @description
			where groupID = @groupID
			select 'success'
		end
		else
		begin
			select 'failed: group not found'
		end
	end
	else
	begin
		select 'failed: user is not admin'
	end
end



/* send direct message - user to user*/
go
create procedure spSendDM
@senderID int,
@receiverID int,
@content varchar(255)
as
begin
	insert into DirectMessages(senderID, receiverID, postTime, postContent)
	values(@senderID, @receiverID, CURRENT_TIMESTAMP, @content)
	select 'success'
end



/* get direct messages list - returns list of users a given user has sent dms to  */
go
create procedure spGetDMsList
@userID int
as
begin
	select senderID from DirectMessages where receiverID = @userID
	union
	select receiverID from DirectMessages where senderID = @userID
end



/* get direct messages - single convo */
go
create procedure spGetDMsConvo
@userID int,
@otherUserID int
as
begin
	select * from DirectMessages where (senderID = @userID or receiverID = @userID) and (senderID = @otherUserID or receiverID = @otherUserID)
end



/* get direct message by id */
go
create procedure spGetDirectMessageByID
@directMessageID int
as
begin
	select senderID, receiverID, postTime, postContent from DirectMessages where directMessageID = @directMessageID
end



/* get group message by id*/
go
create procedure spGetGroupPostByID
@groupPostID int
as
begin
	
	select userID, postTime, postContent from GroupPost where groupPostID = @groupPostID

end



/* get user by id*/
go
create procedure spGetUserByID
@userID int
as
begin
	select userName from UserLogin where userID = @userID
end


/* get location info by id*/
go
create procedure spGetLocationByID
@locationID int
as
begin
	select country, state, city, latitude, longitude from Locations where locationID = @locationID
end



/* get events a user has RSVPed to */
go
create procedure spGetUserRSVPEvents
@userID int
as
begin

	select RSVP.groupEventID from RSVPUser as RSVP
	left join GroupEvent as GE on RSVP.groupEventID = GE.groupEventID
	where RSVP.userID = @userID
	order by GE.creationTimestamp

end



/* search group messages

for a given group, find messages and events containg a keyword or phrase
*/
go
create procedure spSearchGroupMessages
@groupID int,
@phrase varchar(255)
as
begin


	/*get group posts IDs with matching post content*/
	select 'postID', groupPostID from GroupPost
	where groupID = @groupID
	and
	postContent like '%' + @phrase +  '%'

	union

	/* get group event ids with matching description*/
	select 'eventID', groupEventID from GroupEvent
	where groupID = @groupID
	and
	description like '%' + @phrase +  '%'


end



/*search direct messages
for a given two users,
get messages containing a keyword or phrase
*/
go
create procedure spSearchDirectMessages
@userID1 int,
@userID2 int,
@phrase varchar(255)
as
begin

	select directMessageID from DirectMessages
	where ((senderID = @userID1 or senderID = @userID2) and (receiverID = @userID1 or receiverID = @userID2))
	and
	postContent like '%' + @phrase +  '%'

end




/* admin or mod only - add group member (Private group)*/
go
create procedure spAcceptGroupMember
@userID int,
@newUserID int,
@groupID int
as
begin
	
	/*must be mod or admin*/
	if( ((select top(1) adminUserID from GroupInfo where groupID = @groupID) = @userID) or  
		(exists (select userID from GroupModerators where userID = @userID and groupID = @groupID))
	)
	begin

		/* user not in group already*/
		if(not exists (select top(1) userID from GroupUsers where groupID = @groupID and userID = @newUserID))
		begin
			insert into GroupUsers(userID, groupID)
			values(@newUserID, @groupID)

			/* also remove user from join requests table*/

			delete from JoinRequests
			where userID = @newUserID and groupID = @groupID

			select 'success'
		end
	end

end


/* admin or mod - decline member - private groups*/
go
create procedure spDeclineGroupMember
@userID int,
@newUserID int,
@groupID int
as
begin
	/*must be mod or admin*/
	if( ((select top(1) adminUserID from GroupInfo where groupID = @groupID) = @userID) or  
		(exists (select userID from GroupModerators where userID = @userID and groupID = @groupID))
	)
	begin
		delete from JoinRequests
		where userID = @newUserID and groupID = @groupID
		select 'success'
	end
	else
	begin
		select 'failed'
	end
end



/* join a group - request to join if group is private 
	add user to group
*/
go
create procedure spJoinGroup
@userID int,
@groupID int
as
begin
	
	/*user not already in group*/
	if(not exists (select top(1) userID from GroupUsers where groupID = @groupID and userID = @userID))
	begin
		/* for public group... */
		if( (select isPrivate from GroupInfo where groupID = @groupID) = 0 )
		begin
			insert into GroupUsers(userID, groupID)
			values(@userID, @groupID)
			select 'success'
		end
		else /* for private group - make request to join*/
		begin
			if(not exists (select userID from JoinRequests where userID = @userID and groupID = @groupID) )
			begin
				insert into JoinRequests(userID, groupID)
				values(@userID, @groupID)
				select 'success'
			end
			else
			begin
				select 'failed: Join request already made'
			end
		end
	end
	else
	begin
		select 'failed: user already in group'
	end
end


/* Admin or mod - kick member*/
/* conditions
		- admins can kick anyone but themself 
		- mods can kick anyone other than admin, other mods, and themself
*/
go
create procedure spRemoveGroupMember
@userID int,
@userToRemoveID int,
@groupID int
as
begin
	/* for admin...*/
	if( ((select top(1) adminUserID from GroupInfo where groupID = @groupID) = @userID))
	begin
		
		if(not (@userID = @userToRemoveID))
		begin
			delete from GroupUsers where @userToRemoveID = userID and @groupID = groupID
			delete from GroupModerators where userID = @userToRemoveID and @groupID = groupID
			select 'success'
		end

	end
	/* for moderators */
	if ( exists (select top(1) userID from GroupModerators where userID = @userID and groupID = @groupID) )
	begin
		if( (@userToRemoveID not in (select userID from GroupModerators where groupID = @groupID)) and not @userID = @userToRemoveID)
		begin
			delete from GroupUsers where @userToRemoveID = userID and @groupID = groupID
			select 'success'
		end
	end
end



/* leave group */
go
create procedure spLeaveGroup
@userID int,
@groupID int
as
begin
	if(exists ( select top(1) userID from GroupUsers where userID = @userID and groupID = @groupID ))
	begin
		delete from GroupUsers where groupID = @groupID and userID = @userID
		delete from GroupModerators where groupID = @groupID and userID = @userID
		select 'success'
	end
	else
	begin
		select 'failed'
	end
end	



/* get group moderators list - include admin*/
go
create procedure spGetGroupMods
@groupID int
as
begin
	select userID from GroupModerators where groupID = @groupID
	union
	select adminUserID from GroupInfo where groupID = @groupID
end




/* like/unlike a post - group posts only*/
go
create procedure spLikeGroupPostStatus
@groupPostID int,
@userID int
as
begin
	
	if(exists (select userID from GroupPostLikes where groupPostID = @groupPostID))
	begin
		delete from GroupPostLikes where groupPostID = @groupPostID and userID = @userID
		select 'success: unliked '
	end
	else
	begin
		insert into GroupPostLikes(groupPostID, userID)
		values(@groupPostID, @userID)
		select 'success: liked'
	end

end


/* get post likes count*/
go
create procedure spGetGroupPostLikes
@groupPostID int
as
begin
	select count(*) from GroupPostLikes where groupPostID = @groupPostID
end

/* get group post likers (users) */
go
create procedure spGetGroupPostLikers
@groupPostID int
as
begin
	select userName from UserLogin where userID in (select userID from GroupPostLikes where groupPostID = @groupPostID)
end


/* get rsvped users list */
go
create procedure spGetRSVPUsers
@groupID int,
@groupEventID int
as
begin
	select userName from UserLogin where userID in (select userID from RSVPUser where groupEventID = @groupEventID and groupID = @groupID)
end


/* get group event by id */
go 
create procedure spGetGroupEventByID
@groupEventID int
as
begin
	select userID, creationTimestamp, scheduledTimestamp, description, locationID from GroupEvent
	where groupEventID = @groupEventID
end

