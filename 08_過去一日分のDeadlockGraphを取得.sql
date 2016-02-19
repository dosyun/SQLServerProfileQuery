WITH deadlocks(DeadLockGraph)
AS
(
  SELECT
    CAST(XEventData.XEvent.value(N'(data/value)[1]', N'nvarchar(max)') AS XML) AS DeadlockGraph
  FROM
  (
	SELECT
	  CAST(st.target_data AS XML) as TargetData, *
	FROM
	  sys.dm_xe_session_targets st JOIN sys.dm_xe_sessions s
	ON
	  s.address = st.event_session_address
	WHERE
	  s.name = N'system_health'
  ) AS Data CROSS APPLY TargetData.nodes (N'//RingBufferTarget/event') AS XEventData (XEvent)
  WHERE
	XEventData.XEvent.value(N'(data/value)[1]', N'nvarchar(max)') LIKE N'<deadlock>%'
)
SELECT DeadLockGraph.query('data(deadlock/process-list/process[1]/@lasttranstarted)').value('.', 'datetime') as DDate
    , DeadLockGraph.query('data(deadlock/victim-list/victimProcess/@id)').value('.', 'varchar(128)') VictimPID
    , DeadLockGraph.query('data(deadlock/process-list/process/@id)').value('.', 'varchar(128)') as PIDS
    , DeadLockGraph.query('data(deadlock/process-list/process/@waitresource)').value('.', 'varchar(128)') as Waits
    , DeadLockGraph.query('data(deadlock/process-list/process/@lockMode)').value('.', 'varchar(128)') as Mode
    , DeadLockGraph.query('data(deadlock/process-list/process/@loginname)').value('.', 'varchar(128)') as Logins
    , DeadLockGraph.query('count(deadlock/process-list/process)').value('.','int') as ProcNum
    , DeadLockGraph.query('deadlock/resource-list/child::node()') as ResourceList
    ,DeadLockGraph
FROM deadlocks  
WHERE DeadLockGraph.query('data(deadlock/process-list/process[1]/@lasttranstarted)').value('.', 'datetime') > GETDATE() - 1
