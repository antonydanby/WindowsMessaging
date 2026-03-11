program RxDemo;

uses
  Vcl.Forms,
  RxMain in 'RxMain.pas' {RXForm},
  WMsgCommon in '..\WMsgCommon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TRXForm, RXForm);
  Application.Run;
end.
