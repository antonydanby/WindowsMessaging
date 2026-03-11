unit TxMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,

  WMsgSender, WMsgCommon;

type
  TTXForm = class(TForm)
    SendEdit: TEdit;
    btnSend: TButton;
    EditID: TEdit;
    ReceiverEdit: TEdit;
    WMsgSender: TWMsgSender;
    lblResult: TLabel;
    procedure btnSendClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure WMsgSenderSendResult(aID: Cardinal; aResult: TWMsgSendResult);
  private
    { Private declarations }
    fIncValue: integer;
    procedure SendWindowsMessage(const aWindowName: string; const aID: cardinal; const aMsg: string);
  public
    { Public declarations }
  end;

var
  TXForm: TTXForm;

implementation

{$R *.dfm}

procedure TTXForm.btnSendClick(Sender: TObject);
var
  aID: cardinal;
  aWindow: string;
  aMsg: string;
begin
  aID := StrToIntDef(EditID.text,0);
  aWindow := ReceiverEdit.Text;
  Inc(fIncValue);
  aMsg := SendEdit.Text + ';' + fIncValue.ToString;
  SendWindowsMessage(aWindow,aID,aMsg);
end;

procedure TTXForm.FormShow(Sender: TObject);
begin
  fIncValue := 0;
end;

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

end.
