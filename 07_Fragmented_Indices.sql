--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	sys.dm_db_index_physical_stats
--		�w�肵���e�[�u���܂��̓r���[�̃f�[�^�ƃC���f�b�N�X�Ɋւ���A�T�C�Y����ђf�Љ�����Ԃ��܂��B
--		�C���f�b�N�X�̏ꍇ�A�e�p�[�e�B�V������ B �c���[�̃��x�����Ƃ� 1 �s�̃f�[�^���Ԃ���܂��B
--		�q�[�v(�C���f�b�N�X����)�̏ꍇ�A�e�p�[�e�B�V������ IN_ROW_DATA �A���P�[�V���� ���j�b�g���Ƃ� 1 �s�̃f�[�^���Ԃ���܂��B
--		���[�W�I�u�W�F�N�g(LOB)�f�[�^�̏ꍇ�A�e�p�[�e�B�V������ LOB_DATA �A���P�[�V���� ���j�b�g���Ƃ� 1 �s�̃f�[�^���Ԃ���܂��B
--		�e�[�u���ɍs�I�[�o�[�t���[�f�[�^�����݂���ꍇ�A�e�p�[�e�B�V������ ROW_OVERFLOW_DATA �A���P�[�V�������j�b�g���Ƃ� 1 �s�̃f�[�^���Ԃ���܂��B
--		xVelocity �������œK����X�g�A �C���f�b�N�X�Ɋւ�����͕Ԃ���܂���B
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--�f�Љ��̂Ђǂ��C���f�b�N�X�A�N���X�^���C���f�b�N�X�̈ꗗ--------------------------------------------------------------------------------------------------------------------------------------------
--	avg_fragmentation_in_percent��50%�ȉ������z�B�����Ă���č\�z����Ɨǂ��B���A����͂قƂ�ǂ�98%...
--	�Ȃ̂�avg_fragmentation_in_percent�́A���󂠂܂��莋���Ă��Ȃ��BIoDrive�����[
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC sys.sp_MSforeachdb   'IF ''?''  NOT IN (''master'', ''tempDB'',''model'',''msdb'')
BEGIN
USE [?];

SELECT
    DB_NAME(database_id) AS [Database Name],
	OBJECT_NAME(ps.OBJECT_ID) AS [Object Name],
	i.name AS [Index Name],
	ps.index_id,
	index_type_desc,				--�C���f�b�N�X�̎��(Heap/ClusteredIndex/NonclusteredIndex/PrimaryXmlIndex/SpatialIndex/XmlIndex)
	avg_fragmentation_in_percent,	--�_���I�Ȓf�Љ��̊���(������50%�ȉ��ł��邱�Ƃ����z)
	fragment_count,					--�C���f�b�N�X���̒f�Љ�(�����I�ɘA���������[�t�y�[�W)�̐�
	page_count						--�C���f�b�N�X�y�[�W�܂��̓f�[�^�y�[�W�̍��v��
FROM       sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL ,''LIMITED'') AS ps 
INNER JOIN sys.indexes                                                           AS i WITH (NOLOCK)
   ON ps.[object_id] = i.[object_id] 
  AND ps.index_id = i.index_id
WHERE database_id = DB_ID()
  AND page_count > 1500
ORDER BY avg_fragmentation_in_percent DESC OPTION (RECOMPILE);
END'
