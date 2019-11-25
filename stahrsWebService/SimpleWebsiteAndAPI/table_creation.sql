/* Hobi Schema Generation Script
	Generates all tables
*/


/* Prompt... select sql server to connect to - use local for testing*/
use master

/* Create hobiDB if none exists*/
create database [HobiDB]

use HobiDB

 



CREATE TABLE UserLogin (
userID int PRIMARY KEY IDENTITY,
userName varchar(255),
passHash varbinary(max)
);

CREATE TABLE UserInterests (
userID int,
interestTag varchar(255),
PRIMARY KEY (userID, interestTag),
FOREIGN KEY (userID) REFERENCES UserLogin(userID)
);

CREATE TABLE UserInfo (
email varchar(255),
fName varchar(255),
lName varchar(255),
userID int,
PRIMARY KEY (email, userID),
FOREIGN KEY (userID) REFERENCES UserLogin(userID)
);

CREATE TABLE UserImage (
userImage varbinary(max),
userID int,
PRIMARY KEY (userID),
FOREIGN KEY (userID) REFERENCES UserLogin(userID)
);


CREATE TABLE Locations (
	locationID int PRIMARY KEY IDENTITY,
	country varchar(255),
	state varchar(255),
	city varchar(255),
	latitude float,
	longitude float
)

CREATE TABLE GroupInfo (
groupID int NOT NULL Identity,
groupName varchar(255),
groupDescription varchar(255),
locationID int foreign key references Locations(locationID),
adminUserID int foreign key references UserLogin(userID),
isPrivate bit,
PRIMARY KEY (groupID),
);


CREATE TABLE GroupModerators(
	gmID int primary key Identity,
	userID int foreign key references UserLogin(userID),
	groupID int foreign key references GroupInfo(groupID)
);

CREATE TABLE GroupImage (
groupImage varbinary(max),
groupID int,
PRIMARY KEY (groupID),
FOREIGN KEY (groupID) REFERENCES GroupInfo(groupID)
);

CREATE TABLE GroupInterests (
groupID int,
groupInterestTag varchar(255),
PRIMARY KEY (groupID, groupInterestTag),
FOREIGN KEY (groupID) REFERENCES GroupInfo(groupID)
);


CREATE TABLE GroupPost (
groupPostID int IDENTITY,
groupID int,
userID int,
postTime datetime,
postContent varchar(255),
PRIMARY KEY (groupPostID),
FOREIGN KEY (groupID) REFERENCES GroupInfo(groupID),
FOREIGN KEY (userID) REFERENCES UserLogin(userID)
);




CREATE TABLE GroupEvent (
groupEventID int NOT NULL IDENTITY,
groupID int,
userID int,
creationTimestamp datetime,
scheduledTimestamp datetime,
description varchar(max),
locationID int
PRIMARY KEY (groupEventID, groupID),
FOREIGN KEY (groupID) REFERENCES GroupInfo(groupID),
FOREIGN KEY (locationID) REFERENCES Locations(locationID),
foreign key (userID) REFERENCES UserLogin(userID)
);





CREATE TABLE RSVPUser (
userID int,
groupEventID int,
groupID int,
PRIMARY KEY (userID, groupEventID, groupID),
FOREIGN KEY (userID) REFERENCES UserLogin(userID),
FOREIGN KEY (groupEventID, groupID) REFERENCES GroupEvent(groupEventID, groupID)
);

CREATE TABLE GroupUsers (
userID int,
groupID int,
PRIMARY KEY (userID, groupID),
FOREIGN KEY (userID) REFERENCES UserLogin(userID),
FOREIGN KEY (groupID) REFERENCES GroupInfo(groupID)
);

CREATE TABLE GroupPostLikes (
groupPostID int,
userID int,
PRIMARY KEY (groupPostID, userID),
FOREIGN KEY (groupPostID) REFERENCES GroupPost(groupPostID),
FOREIGN KEY (userID) REFERENCES UserLogin(userID)
);


CREATE TABLE DirectMessages(
directMessageID int primary key identity,
senderID int foreign key references UserLogin(userID),
receiverID int foreign key references UserLogin(userID),
postTime datetime,
postContent varchar(255)
)



CREATE TABLE JoinRequests(
userID int foreign key references UserLogin(userID),
groupID int foreign key references GroupInfo(groupID)
)