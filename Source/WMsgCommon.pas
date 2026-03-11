(*-----------------------------------------------------------------------------
  Unit: WMsgCommon
  Purpose: Windows messaging common unit used by :
               WMsgReceiver, WMsgSender
------------------------------------------------------------------------------*)

unit WMsgCommon;

interface

uses
  System.SysUtils, System.Classes,
  Winapi.Messages;

type
  {$SCOPEDENUMS ON}
  TWMsgSendResult = (Unknown,Success,FailedHandle,FailedSend);
  {$SCOPEDENUMS OFF}

const
  WINDOWS_MESSAGING_CLASS_NAME = 'TWMsgReceiver';

  WMSG_DEFAULT_WINDOW = 'DefaultWindow';


implementation

end.
