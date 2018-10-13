%==========================================================================================================================
function WarnUser(warningMessage)
	uiwait(warndlg(warningMessage));
	return; % from WarnUser()
