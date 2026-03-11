(*-----------------------------------------------------------------------------
  Unit: WMsgReceiver
  Purpose: Windows messaging receiver unit

  Useage:

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

  procedure TRXForm.StopTheReceiver;
  begin
    WMsgReceiver.OnMessageReceived := nil;
    WMsgReceiver.Stop;
  end;

  procedure TRXForm.WMsgReceiverMessageReceived(aID: Cardinal; aMsg: string);
  begin
    Memo.Lines.Add(aID.ToString +', '+ aMsg);
  end;

  // Please see the demo

------------------------------------------------------------------------------*)

unit WMsgReceiver;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes;

type
  TReceivedMessage = procedure(aID: cardinal; aMsg: string) of object;

  TWMsgReceiver = class(TComponent)
  protected
    fWindowName: string;
    fWndHandle: HWND;
    fOnMessageReceived: TReceivedMessage;
    class function StaticWndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; static;
    procedure WndProc(var aMsg: TMessage);

    procedure CreateTheWindow(const aWindowName: string); overload;
    procedure DestroyWindowAndDeRegister;

    function GetWindowName: string;
    procedure SetWindowName(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetHandle: HWND;

    procedure Start;
    procedure Stop;
 published
    property WindowName: string read GetWindowName write SetWindowName;
    property OnMessageReceived: TReceivedMessage read fOnMessageReceived write fOnMessageReceived;
  end;

procedure Register;

implementation

uses
  WMsgCommon;

{ TReceiver }

procedure Register;
begin
  RegisterComponents('l53n',[TWMsgReceiver]);
end;

constructor TWMsgReceiver.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Initializing the field to ensure we have a window name at construction
  fWindowName := WMSG_DEFAULT_WINDOW;
end;

destructor TWMsgReceiver.Destroy;
begin
  DestroyWindowAndDeRegister;
  inherited Destroy;
end;

procedure TWMsgReceiver.DestroyWindowAndDeRegister;
begin
  if fWndHandle <> 0 then DestroyWindow(fWndHandle);
  Winapi.Windows.UnregisterClass(WINDOWS_MESSAGING_CLASS_NAME, HInstance);
end;

procedure TWMsgReceiver.Start;
begin
  if fWindowName.IsEmpty then fWindowName := WMSG_DEFAULT_WINDOW;
  CreateTheWindow(fWindowName);
end;

procedure TWMsgReceiver.Stop;
begin
  DestroyWindowAndDeRegister;
end;

procedure TWMsgReceiver.CreateTheWindow(const aWindowName: string);
var
  WndClassEx: TWndClassEx;
begin
  FillChar(WndClassEx, SizeOf(WndClassEx), 0);
  WndClassEx.cbSize := SizeOf(WndClassEx);
  WndClassEx.lpfnWndProc := @StaticWndProc;
  WndClassEx.hInstance := HInstance;
  WndClassEx.lpszClassName := WINDOWS_MESSAGING_CLASS_NAME;

  if Winapi.Windows.RegisterClassEx(WndClassEx) = 0 then
    raise Exception.Create('Failed to register window class');

  // Define a unique window name ( passed in as aWindowName ) to find this window
  fWndHandle := CreateWindowEx(0, WINDOWS_MESSAGING_CLASS_NAME, pWideChar(aWindowName), 0, 0, 0, 0, 0, 0, 0, HInstance, nil);

  if fWndHandle = 0 then
    raise Exception.Create('Failed to create message window');

  SetWindowLongPtr(fWndHandle, GWLP_USERDATA, LONG_PTR(Self));
end;

class function TWMsgReceiver.StaticWndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  Receiver: TWMsgReceiver;
  Msg: TMessage;
begin
  Receiver := TWMsgReceiver(GetWindowLongPtr(hWnd, GWLP_USERDATA));
  if Assigned(Receiver) then
  begin
    Msg.Msg := uMsg;
    Msg.WParam := wParam;
    Msg.LParam := lParam;
    Msg.Result := 0;
    Receiver.WndProc(Msg);
    Result := Msg.Result;
  end
  else Result := DefWindowProc(hWnd, uMsg, wParam, lParam);
end;

procedure TWMsgReceiver.WndProc(var aMsg: TMessage);
var
  CopyData: PCopyDataStruct;
  ReceivedStr: string;
begin
  if aMsg.Msg = WM_COPYDATA then
  begin
    CopyData := PCopyDataStruct(aMsg.LParam);
    SetString(ReceivedStr, PChar(CopyData.lpData), CopyData.cbData div SizeOf(Char));
    if Assigned(fOnMessageReceived) then fOnMessageReceived(CopyData.dwData,ReceivedStr);
    aMsg.Result := 1;
  end
  else aMsg.Result := DefWindowProc(fWndHandle, aMsg.Msg, aMsg.WParam, aMsg.LParam);
end;

function TWMsgReceiver.GetHandle: HWND;
begin
  Result := fWndHandle;
end;

function TWMsgReceiver.GetWindowName: string;
begin
  // You can perform logic here, like formatting the string
  Result := fWindowName;
end;

procedure TWMsgReceiver.SetWindowName(const Value: string);
begin
  // Setters are perfect for validation or side effects
  if fWindowName <> Value then fWindowName := Value;
end;

end.



