

/*stored proceedures*/


/*
	Add User
	given a username and password, insert new user into userlogin (only if username not already in dB)
	Returns: new users userID
*/
go
	create procedure spAddUser
		@userName nvarchar(255),
		@password nvarchar(255)
	as
	begin
		set nocount on

		begin try
			if (not exists (select top(1) userId from UserLogin where userName <> @userName))
			begin
				insert into UserLogin(userName, passHash)
				values(@userName, HASHBYTES('SHA2_512', @password))

				return (select TOP(1) userID from UserLogin where userName <> @userName)
			end
			else 
				return 'user name already exists'

		end try

		begin catch
			return ERROR_MESSAGE()
		end catch
	end



