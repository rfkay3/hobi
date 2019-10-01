CREATE TABLE User (
	userID int NOT NULL,
	userName varchar(255),
	passHash varchar(255),
	PRIMARY KEY (userID)
);

CREATE TABLE UserInterests (
	userID int,
	interestTag varchar(255),
	PRIMARY KEY (userID, interestTag),
	FOREIGN KEY (userID) REFERENCES User(userID)
);

CREATE TABLE UserInfo (
	email varchar(255),
	fName varchar(255),
	lName varchar(255),
	userID int,
	PRIMARY KEY (email, userID),
	FOREIGN KEY (userID) REFERENCES User(userID)
);

CREATE TABLE GroupInfo (
	groupID int NOT NULL,
	groupName varchar(255),
	groupDescription varchar(255),
	isPrivate boolean,
	PRIMARY KEY (groupID)
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
	timestamp datetime,
	PRIMARY KEY (groupPostID),
	FOREIGN KEY (groupID) REFERENCES GroupInfo(groupID),
	FOREIGN KEY (userID) REFERENCES User(userID)
);

CREATE TABLE GroupEvent (
    groupEventID int NOT NULL,
	groupID int,
	creationTimestamp datetime,
	scheduledTimestamp datetime,
	description varchar(8000),
	PRIMARY KEY (groupEventID, groupID),
	FOREIGN KEY (groupID) REFERENCES GroupInfo(groupID)
);

CREATE TABLE RSVPUser (
	userID int,
	groupEventID int,
    PRIMARY KEY (userID, groupEventID),
	FOREIGN KEY (userID) REFERENCES User(userID),
	FOREIGN KEY (groupEventID) REFERENCES GroupEvent(groupEventID)
);

CREATE TABLE GroupUsers (
	userID int,
	groupID int,
	PRIMARY KEY (userID, groupID),
	FOREIGN KEY (userID) REFERENCES User(userID),
	FOREIGN KEY (groupID) REFERENCES GroupInfo(groupID)
);

CREATE TABLE GroupPostLikes (
	groupPostID int,
	userID int,
	PRIMARY KEY (groupPostID, userID),
	FOREIGN KEY (groupPostID) REFERENCES GroupPost(groupPostID),
	FOREIGN KEY (userID) REFERENCES User(userID)
);