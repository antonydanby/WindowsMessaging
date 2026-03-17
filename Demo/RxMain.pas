unit RxMain;

interface

uses
  Forms, Classes, Controls, StdCtrls, ExtCtrls, WMsgReceiver;

type
  TRXForm = class(TForm)
    Memo: TMemo;
    TopPanel: TPanel;
    ReceiverEdit: TEdit;
    btnStart: TButton;
    btnStop: TButton;
    WMsgReceiver: TWMsgReceiver;
    SubPanel: TPanel;
    chkUIPI: TCheckBox;

    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure WMsgReceiverMessageReceived(aID: Cardinal; aMsg: string);
    procedure ReceiverEditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chkUIPIClick(Sender: TObject);
  private
    procedure UpdateUI;
  end;

var
  RXForm: TRXForm;

implementation

{$R *.dfm}

uses
  SysUtils, Windows, WMsgCommon;

function IsRunAsAdministrator: Boolean;
const
  ELEVATION_FULL = 2;
var
  hToken: THandle;
  dwElevation, dwSize: Cardinal;
begin
  Result := False;
  if OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hToken) then try
    dwElevation := 0;
    Result := (GetTokenInformation(hToken, TokenElevationType, @dwElevation, SizeOf(Cardinal), dwSize)) and (dwElevation = ELEVATION_FULL);
    dwElevation := 0;
    Result := Result or (((GetTokenInformation(hToken, TokenElevation, @dwElevation, SizeOf(Cardinal), dwSize))) and (dwElevation > 0))
  finally
    CloseHandle(hToken)
  end
end;

procedure TRXForm.btnStartClick(Sender: TObject);
begin
  if Length(Trim(ReceiverEdit.Text)) = 0 then
    ReceiverEdit.Text := WMSG_DEFAULT_WINDOW;

  WMsgReceiver.WindowName := ReceiverEdit.Text;
  WMsgReceiver.Start;
  UpdateUI
end;

procedure TRXForm.btnStopClick(Sender: TObject);
begin
  WMsgReceiver.Stop;
  UpdateUI
end;

procedure TRXForm.chkUIPIClick(Sender: TObject);
begin
  WMsgReceiver.LowProcessMessages := chkUIPI.Checked
end;

procedure TRXForm.FormCreate(Sender: TObject);
begin
  chkUIPI.Enabled := IsRunAsAdministrator
end;

procedure TRXForm.FormDestroy(Sender: TObject);
begin
  WMsgReceiver.Stop
end;

procedure TRXForm.ReceiverEditChange(Sender: TObject);
begin
  UpdateUI
end;

procedure TRXForm.UpdateUI;
begin
  ReceiverEdit.Enabled := not WMsgReceiver.Active;
  btnStart.Enabled := not WMsgReceiver.Active and (Length(Trim(ReceiverEdit.Text)) > 0);
  btnStop.Enabled := WMsgReceiver.Active
end;

procedure TRXForm.WMsgReceiverMessageReceived(aID: Cardinal; aMsg: string);
begin
  Memo.Lines.Add(aID.ToString +', '+ aMsg);
end;

end.
