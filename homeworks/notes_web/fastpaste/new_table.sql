CREATE TABLE paste (id bigint not null primary_key, create_time timestamp not null, 
	expire_time timestamp, title varchar(255), user_id bigint not null, friends varchar(511), 
	index create_time_idx (create_time), index expire_time_idx (expire_time)) charset utf8;

CREATE TABLE user (id bigint auto_increment primary key, login varchar(255) not null, 
	pass varchar(255) not null, index login_idx (login), index id_idx (id)) charset utf8;