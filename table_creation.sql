CREATE TABLE UserLogin (
	userID int NOT NULL,
	userName varchar(255),
	passHash varchar(255),
	PRIMARY KEY (userID)
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

CREATE TABLE GroupInfo (
	groupID int NOT NULL,
	groupName varchar(255),
	groupDescription varchar(255),
	groupLocation varchar(255), 
	isPrivate bit,
	PRIMARY KEY (groupID)
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
    groupPostID int,
	groupID int,
	userID int,
	postTime datetime,
	PRIMARY KEY (groupPostID),
	FOREIGN KEY (groupID) REFERENCES GroupInfo(groupID),
	FOREIGN KEY (userID) REFERENCES UserLogin(userID)
);

CREATE TABLE GroupEvent (
    groupEventID int NOT NULL,
	groupID int,
	creationTimestamp datetime,
	scheduledTimestamp datetime,
	description varchar(max),
	PRIMARY KEY (groupEventID, groupID),
	FOREIGN KEY (groupID) REFERENCES GroupInfo(groupID)
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