CREATE TABLE [wholesale_productsourcing_afi].[spscomments] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[id] int NULL, 
	[parent_id] int NULL, 
	[discussion_id] int NULL, 
	[auth_id] int NULL, 
	[auth_name] varchar(8000) NULL, 
	[comment] varchar(8000) NULL, 
	[created] datetime2(6) NULL, 
	[upload_file] varchar(8000) NULL, 
	[old_id] int NULL, 
	[high_priority] smallint NULL, 
	[status] smallint NULL, 
	[top_comment_id] int NULL, 
	[discussion_type] smallint NULL, 
	[update_time] datetime2(6) NULL, 
	[auto_generate] smallint NULL, 
	[deleted] smallint NULL, 
	[created_on] datetime2(6) NULL, 
	[created_by] int NULL, 
	[last_modified_on] datetime2(6) NULL, 
	[last_modified_by] int NULL
);

