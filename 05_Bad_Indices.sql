--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	sys.indexes					�e�[�u���A�r���[�A�e�[�u���l�֐��ȂǁA�e�[�u�� �I�u�W�F�N�g�̃C���f�b�N�X�܂��̓q�[�v���Ƃ� 1 �s�̃f�[�^���i�[���܂�
--		object_id				�e�[�u��ID
--		name					�e�[�u����
--		index_id				�C���f�b�N�XID(0:�q�[�v, 1:�N���X�^�[���C���f�b�N�X, 1:��N���X�^�[���C���f�b�N�X)
--		Type					�C���f�b�N�X���(0:�q�[�v, 1:�N���X�^�[��, 2:��N���X�^�[��, 3:XML, 4:���, 5:�������œK����X�g�A�C���f�b�N�X, 6:��N���X�^�[����X�g�A�C���f�b�N�X
--		type_desc				�C���f�b�N�X��ނ̐���(HEAP, CLUSTERED, NONCLUSTERED, XML, SPATIAL, CLUSTERED COLUMNSTORE, NONCLUSTERED COLUMNSTORE)
--		is_unique				1:��ӂȃC���f�b�N�X, 0:���ӂȃC���f�b�N�X
--		data_space_id			�C���f�b�N�X�̃f�[�^�̈�ID�B�f�[�^�̈�̓t�@�C���O���[�v�܂��̓p�[�e�B�V�����\���B0:object_id�̓e�[�u���l�֐��B
--		ignore_dup_key			1:IGNORE_DUP_KEY�I��, 0:IGNORE_DUP_KEY�I�t
--		is_primary_key			1:�C���f�b�N�X��PRIMARY KEY����̈ꕔ�ł��B
--		is_unique_constraint	1:�C���f�b�N�X��UNIQUE����̈ꕔ�ł��B
--		fill_factor				0:�C���f�b�N�X���쐬�܂��͍č\�z���ꂽ�ꍇ�Ɏg�p�����FILLFACTOR�̃p�[�Z���e�[�W
--		is_padded				1:PADINDEX�I��, 0:PADINDEX�I�t
--		is_disabled				1:�C���f�b�N�X������, 0:�C���f�b�N�X���L��
--		is_hypothetical			1:���z�I�C���f�b�N�X(�f�[�^�ւ̃A�N�Z�X�p�X�Ƃ��Ē��ڎg�p�͂ł��܂���B�񃌃x���̓��v��ێ����Ă��܂�), 0:�񉼑z�I�C���f�b�N�X
--		allow_row_locks			1:�s���b�N������, 0:�s���b�N�������Ȃ�
--		allow_page_locks		1:�y�[�W ���b�N�������܂�, 0:�y�[�W ���b�N�������Ȃ�
--		has_filter				1:�t�B���^�t�C���f�b�N�X(�t�B���^�[��`�𖞂����s�������܂܂��), 0:�t�B���^�Ȃ��C���f�b�N�X
--		filter_definition		�t�B���^�[�I�����ꂽ�C���f�b�N�X�Ɋ܂܂��s�̃T�u�Z�b�g�̎��B�q�[�v�܂��̓t�B���^�[�I�����ꂽ�C���f�b�N�X�ȊO�̃C���f�b�N�X�̏ꍇ��NULL
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	sys.dm_db_index_usage_stats	���܂��܂Ȏ�ނ̃C���f�b�N�X����̐��ƁA�e��̑��삪�O����s���ꂽ������Ԃ��܂��B
--		database_id				�f�[�^�x�[�X��ID�B
--		object_id				�e�[�u���܂��̓r���[��ID�B
--		index_id				ID�B
--		user_seeks				���[�U�N�G���ɂ��V�[�N���B
--		user_scans				���[�U�N�G���ɂ��X�L�������B
--		user_lookups			���[�U�N�G���ɂ��u�b�N�}�[�N�Q�Ɛ��B
--		user_updates			���[�U�N�G���ɂ��X�V���B
--		last_user_seek			�O��̃��[�U�V�[�N�̎����B
--		last_user_scan			�O��̃��[�U�X�L�����̎����B
--		last_user_lookup		�O��̃��[�U�Q�Ƃ̎����B
--		last_user_update		�O��̃��[�U�X�V�̎����B
--		system_seeks			�V�X�e���N�G���ɂ��V�[�N���B
--		system_scans			�V�X�e���N�G���ɂ��X�L�������B
--		system_lookups			�V�X�e���N�G���ɂ��Q�Ɛ��B
--		system_updates			�V�X�e���N�G���ɂ��X�V���B
--		last_system_seek		�O��̃V�X�e���V�[�N�̎����B
--		last_system_scan		�O��̃V�X�e���X�L�����̎����B
--		last_system_lookup		�O��̃V�X�e���Q�Ƃ̎����B
--		last_system_update		�O��̃V�X�e���X�V�̎����B
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--�������̂ɑS���g���Ă��Ȃ��\���̂���C���f�b�N�X��T��------------------------------------------------------------------------------------------------------------------------------------------
--	������ >> �Ǎ��񐔂ȃC���f�b�N�X���`�F�b�N���Č�����
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EXECUTE sys.sp_MSforeachdb 'IF ''?''  NOT IN (''master'', ''tempDB'',''model'',''msdb'')
BEGIN
USE [?];

SELECT
    OBJECT_NAME(s.[object_id])                              AS [Table Name],
	i.name                                                  AS [Index Name],
	i.index_id                                              AS [Index Id],
	i.is_disabled                                           AS [Is Disabled],	--1:����/0:�L��
	user_updates                                            AS [Total Writes],	--������(update)
	user_seeks + user_scans + user_lookups                  AS [Total Reads],	--�Ǎ���(seek/scan/lookup)
    user_updates - (user_seeks + user_scans + user_lookups) AS [Difference]		--������-�Ǎ���
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
   ON s.[object_id] = i.[object_id]
   AND i.index_id = s.index_id
WHERE OBJECTPROPERTY(s.[object_id],''IsUserTable'') = 1
  AND s.database_id = DB_ID()
  AND user_updates > (user_seeks + user_scans + user_lookups)
  AND i.index_id > 1
ORDER BY
    [Difference]   DESC,
	[Total Writes] DESC,
	[Total Reads]  ASC
OPTION (RECOMPILE);

END'
