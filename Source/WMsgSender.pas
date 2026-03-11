(*-----------------------------------------------------------------------------
  Unit: WMsgSender
  Purpose: Windows messaging sender unit

  Useage:

  uses
    WMsgCommon;

  procedure TTXForm.SendWindowsMessage(const aWindowName: string; const aID: cardinal; const aMsg: string);
  begin
    WMsgSender.WindowName := aWindowName;
    WMsgSender.SendMessage(aID,aMsg);
  end;

  procedure TTXForm.WMsgSenderSendResult(aID: Cardinal; aResult: TWMsgSendResult);
  begin
    case aResult of
      TWMsgSendResult.Success:
        begin
          lblResult.font.Color := clGreen;
          lblResult.Caption := 'Success!';
        end;
      TWMsgSendResult.Unknown:
        begin
          lblResult.font.Color := clRed;
          lblResult.Caption := 'Failed!';
          ShowMessage(Format('Unknown failure for ID=%d',[aID]));
        end;
      TWMsgSendResult.FailedHandle:
        begin
          lblResult.font.Color := clRed;
          lblResult.Caption := 'Failed!';
          ShowMessage('Receiver not running.');
        end;
      TWMsgSendResult.FailedSend:
        begin
          lblResult.font.Color := clRed;
          lblResult.Caption := 'Failed!';
          ShowMessage(Format('Message send failed for ID=%d.',[aID]));
        end;
    end;
  end;

  // Please see the demo

------------------------------------------------------------------------------*)

unit WMsgSender;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils,

  WMsgCommon;

type
  TSendResult = procedure(aID: cardinal; aResult: TWMsgSendResult) of object;

  TWMsgSender = class(TComponent)
  private
    fWindowName: string;
    fOnSendResult: TSendResult;
  strict protected
    fWndHandle: HWND;

    function Send(const aID: cardinal; const aMsg: string): Boolean;

    class function SendWindowsMessage(
        const aWindowName: string;
        const aID: cardinal; const aMsg: string): TWMsgSendResult;
  public
    procedure SendMessage(const aID: cardinal; const aMsg: string);
  published
    property WindowName: string read fWindowName write fWindowName;
    property OnSendResult: TSendResult read fOnSendResult write fOnSendResult;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('l53n',[TWMsgSender]);
end;

function TWMsgSender.Send(const aID: cardinal; const aMsg: string): Boolean;
var
  CopyData: TCopyDataStruct;
begin
  Result := False;
  CopyData.dwData := aID; // Custom identifier
  CopyData.cbData := (Length(aMsg) + 1) * SizeOf(Char);
  CopyData.lpData := PChar(aMsg); // The message
  if WinAPI.Windows.SendMessage(fWndHandle, WM_COPYDATA, 0, LPARAM(@CopyData)) <> 0 then Result := True;
end;

class function TWMsgSender.SendWindowsMessage(const aWindowName: string; const aID: cardinal; const aMsg: string): TWMsgSendResult;
var
  TX: TWMsgSender;
begin
  TX := TWMsgSender.Create(nil);
  try
    TX.fWndHandle := FindWindow(nil, pWideChar(aWindowName));
    if TX.fWndHandle <> 0 then
    begin
      if TX.Send(aID,aMsg)
        then Result := TWMsgSendResult.Success
        else Result := TWMsgSendResult.FailedSend;
    end
    else Result := TWMsgSendResult.FailedHandle;
  finally
    if TX.fWndHandle <> 0 then DestroyWindow(TX.fWndHandle);
    TX.Free;
  end;
end;

procedure TWMsgSender.SendMessage(const aID: cardinal; const aMsg: string);
var
  aResult: TWMsgSendResult;
begin
  aResult := TWMsgSender.SendWindowsMessage(fWindowName,aID,aMsg);
  if Assigned(fOnSendResult) then fOnSendResult(aID,aResult);
end;


end.


