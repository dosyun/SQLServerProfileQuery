--	sys.dm_db_missing_index_group_stats	��ԃC���f�b�N�X�������A�����C���f�b�N�X�O���[�v�Ɋւ���T�v��Ԃ��܂��B]
--		group_handle			�����C���f�b�N�X�O���[�v�̎��ʎq�B���̎��ʎq�̓T�[�o�[���ň�ӂł��B���̗�ł́A�O���[�v���̃C���f�b�N�X���������Ă���ƍl������A���ׂẴN�G���Ɋւ����񂪒񋟂���܂��B�C���f�b�N�X�O���[�v�ɂ́A�C���f�b�N�X��1�����܂܂�܂��B
--		unique_compiles			���̌����C���f�b�N�X�O���[�v�ɂ���ĉe�����󂯂�R���p�C������эăR���p�C���̐��B �����̈قȂ�N�G���ŃR���p�C������эăR���p�C�����s����قǁA���̗�̒l�͑傫���Ȃ�܂��B
--		user_seeks				�O���[�v���̐����C���f�b�N�X���g�p�ł������[�U�[�N�G���ɂ���Ĕ��������V�[�N���B
--		user_scans				�O���[�v���̐����C���f�b�N�X���g�p�ł������[�U�[�N�G���ɂ���Ĕ��������X�L�������B
--		last_user_seek			�O���[�v���̐����C���f�b�N�X���g�p�ł������[�U�[�N�G���ɂ���Ĕ��������O��̃V�[�N�̓����B
--		last_user_scan			�O���[�v���̐����C���f�b�N�X���g�p�ł������[�U�[�N�G���ɂ���Ĕ��������O��̃X�L�����̓����B
--		avg_total_user_cost		�O���[�v���̃C���f�b�N�X�ɂ���č팸�ł������[�U�[�N�G���̕��σR�X�g�B
--		avg_user_impact			���̌����C���f�b�N�X �O���[�v����������Ă����ꍇ�̃��[�U�[�N�G���ւ̌��ʂ̕��σp�[�Z���e�[�W (%)�B���̒l�́A���̌����C���f�b�N�X�O���[�v����������Ă����ꍇ�Ɍ��������N�G���R�X�g�̕��σp�[�Z���e�[�W�������܂��B
--		system_seeks			�O���[�v���̐����C���f�b�N�X���g�p�ł����V�X�e���N�G��(AutoStats�N�G���Ȃ�)�ɂ���Ĕ��������V�[�N���B�ڍׂɂ��ẮA�uAutoStats�C�x���g �N���X�v���Q�Ƃ��Ă��������B
--		system_scans			�O���[�v���̐����C���f�b�N�X���g�p�ł����V�X�e���N�G���ɂ���Ĕ��������X�L�������B
--		last_system_seek		�O���[�v���̐����C���f�b�N�X���g�p�ł����V�X�e���N�G���ɂ���Ĕ��������O��̃V�X�e���V�[�N�̓����B
--		last_system_scan		�O���[�v���̐����C���f�b�N�X���g�p�ł����V�X�e���N�G���ɂ���Ĕ��������O��̃V�X�e���X�L�����̓����B
--		avg_total_system_cost	�O���[�v���̃C���f�b�N�X�ɂ���č팸�ł����V�X�e���N�G���̕��σR�X�g�B
--		avg_system_impact		���̌����C���f�b�N�X�O���[�v����������Ă����ꍇ�̃V�X�e���N�G���ւ̌��ʂ̕��σp�[�Z���e�[�W(%)�B���̒l�́A���̌����C���f�b�N�X�O���[�v����������Ă����ꍇ�Ɍ��������N�G���R�X�g�̕��σp�[�Z���e�[�W�������܂��B	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	sys.dm_db_missing_index_groups	��ԃC���f�b�N�X�������A����̌����C���f�b�N�X�O���[�v�Ɋ܂܂�Ă��錇���C���f�b�N�X�Ɋւ������Ԃ��܂��B
--		index_group_handle		�����C���f�b�N�X�O���[�v�̎��ʎq
--		index_handle			index_group_handle�Ŏ����ꂽ�O���[�v�ɑ�����A�����C���f�b�N�X�̎��ʎq�B�C���f�b�N�X�O���[�v�ɂ́A�C���f�b�N�X��1�����܂܂�܂��B
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	sys.dm_db_missing_index_details	��ԃC���f�b�N�X�������A�����C���f�b�N�X�Ɋւ���ڍ׏���Ԃ��܂��B
--		index_handle			����̌����C���f�b�N�X�̎��ʎq�B���ʎq�̓T�[�o�[���ň�ӂł��Bindex_handle�͂��̃e�[�u���̃L�[�ł��B
--		database_id				�����C���f�b�N�X���܂ރe�[�u��������f�[�^�x�[�X�̎��ʎq�B
--		object_id				�C���f�b�N�X���������Ă���e�[�u���̎��ʎq�B
--		equality_columns		���̌`���̓��l�q��Ɏg�p�ł����̃R���}��؂�ꗗ�Btable.column=constant_value
--		inequality_columns		���̌`���̂悤�ȕs���l�q��Ɏg�p�ł����̃R���}��؂�ꗗ�Btable.column > constant_value�B"=" �ȊO�̔�r���Z�q�͂��ׂāA�s���l��\���܂��B
--		included_columns		�N�G���̕��Ƃ��ĕK�v�ȗ�̃R���}��؂�ꗗ�B���܂��͕t����̏ڍׂɂ��ẮA�u�t����C���f�b�N�X�̍쐬�v���Q�Ƃ��Ă��������B
--		statement				�C���f�b�N�X���������Ă���e�[�u���̖��O�B
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--�������ق����悢�C���f�b�N�X�ꗗ------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	���߈�T�ԕ��𒊏o
--	Index_advantage�����Ⴂ�Ȃ��̂��`�F�b�N���Č�����
--	Equality, inequality columns �� �C���f�b�N�X�L�[��Ɏw��
--		�t���� (included_columns) �̎g�������ɒ���	�� �e�[�u���̕����R�s�[������Ă���̂ƕς��Ȃ��Ȃ�
--		addtime ���悭�o�Ă���H						�� �K�v�Ȃ��̂� addtime ���₢���킹�Ă��Ȃ�������
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)	AS [index_advantage],			--seek���~�팸�\�R�X�g�~���Ғl �� ���������Ⴂ�̂��̂�ΏۂɌ�����
	migs.last_user_seek											AS [Last User Seek],			--�O��seek�̃^�C���X�^���v
	mid.[statement]												AS [Database.Schema.Table],		--�Ώۃe�[�u��
	mid.equality_columns										AS [Equality Columns],			--�K�v�ȃC���f�b�N�X�L�[(������p)
	mid.inequality_columns										AS [Inequality Columns],		--�K�v�ȃC���f�b�N�X�L�[(������p)
	mid.included_columns										AS [Included Columns],			--�K�v�ȕt����
	migs.unique_compiles										AS [Unique Compiles],			--�C���f�b�N�X�𒣂����Ƃ��ɔ�������R���p�C����
	migs.user_seeks												AS [User Seeks],				--�C���f�b�N�X�𒣂����ꍇ�̃V�[�N��
	migs.avg_total_user_cost									AS [Average Toral User Cost],	--�C���f�b�N�X�𒣂����ꍇ�ɂǂꂾ���R�X�g�팸�ł��邩
	migs.avg_user_impact										AS [Average User Impact]		--�C���f�b�N�X�𒣂����ꍇ�̌���
FROM sys.dm_db_missing_index_group_stats	AS migs WITH (NOLOCK)
INNER JOIN sys.dm_db_missing_index_groups	AS mig  WITH (NOLOCK)
   ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details  AS mid  WITH (NOLOCK)
   ON mig.index_handle = mid.index_handle
WHERE last_user_seek > GETDATE() - 7
ORDER BY index_advantage DESC OPTION (RECOMPILE);
