DROP TABLE IF EXISTS mp3song;

CREATE TABLE mp3song (
		id serial primary key,
		path varchar(2000) not null,
		artist varchar(255) null,
		title varchar(500) null,
		secs smallint not null default -1
		last_updated timestamp not null default now()
);
