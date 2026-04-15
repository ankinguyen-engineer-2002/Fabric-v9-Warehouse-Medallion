CREATE   PROC Performance_Logs.usp_EmailQueue_MarkSent
   @EmailId    BIGINT,
   @Status     NVARCHAR(100) = N'Success',
   @ErrorText  NVARCHAR(MAX) = NULL
AS
BEGIN
   UPDATE Performance_Logs.EmailQueue
   SET SentAt = SYSUTCDATETIME(),
       SentStatus = @Status,
       ErrorText = @ErrorText
   WHERE EmailId = @EmailId;
END;