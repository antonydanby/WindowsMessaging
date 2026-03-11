unit RxMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,Vcl.ExtCtrls,

  WMsgReceiver;

type
  TRXForm = class(TForm)
    Memo: TMemo;
    TopPanel: TPanel;
    ReceiverEdit: TEdit;
    btnStart: TButton;
    btnStop: TButton;
    WMsgReceiver: TWMsgReceiver;

    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure WMsgReceiverMessageReceived(aID: Cardinal; aMsg: string);
  private
    { Private declarations }
    procedure StopTheReceiver;
  public
    { Public declarations }
  end;

var
  RXForm: TRXForm;

implementation

{$R *.dfm}

uses
  WMsgCommon;

procedure TRXForm.btnStartClick(Sender: TObject);
begin
  StopTheReceiver;

  WMsgReceiver.OnMessageReceived := WMsgReceiverMessageReceived;
  if not (Trim(ReceiverEdit.Text) = '')
    then
    begin
      WMsgReceiver.WindowName := ReceiverEdit.Text
    end
    else
    begin
      WMsgReceiver.WindowName := WMSG_DEFAULT_WINDOW;
      ReceiverEdit.Text := WMsgReceiver.WindowName;
    end;
  WMsgReceiver.Start;
end;

procedure TRXForm.btnStopClick(Sender: TObject);
begin
  StopTheReceiver;
end;

procedure TRXForm.FormDestroy(Sender: TObject);
begin
  StopTheReceiver;
end;

procedure TRXForm.StopTheReceiver;
begin
  WMsgReceiver.OnMessageReceived := nil;
  WMsgReceiver.Stop;
end;

procedure TRXForm.WMsgReceiverMessageReceived(aID: Cardinal; aMsg: string);
begin
  Memo.Lines.Add(aID.ToString +', '+ aMsg);
end;

end.
