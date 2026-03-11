program TxDemo;

uses
  Vcl.Forms,
  TxMain in 'TxMain.pas' {TXForm},
  WMsgCommon in '..\WMsgCommon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTXForm, TXForm);
  Application.Run;
end.
