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
  private
    fActive: boolean;
    fLowProcessMessages: boolean;
    fWindowName: string;
    fWndHandle: HWND;
    fOnMessageReceived: TReceivedMessage;
    class function StaticWndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; static;
    procedure WndProc(var aMsg: TMessage);

    procedure CreateTheWindow(const aWindowName: string); overload;
    procedure DestroyWindowAndDeRegister;

    function GetActive: boolean;
    function GetWindowName: string;
    procedure SetActive(const Value: boolean);
    procedure SetWindowName(const Value: string);
    procedure SetLowProcessMessages(const Value: boolean);
  protected
    procedure Restart;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetHandle: HWND;

    procedure Start;
    procedure Stop;
  published
    property Active: boolean read GetActive write SetActive;
    property LowProcessMessages: boolean read fLowProcessMessages write SetLowProcessMessages;
    property WindowName: string read GetWindowName write SetWindowName;
    property OnMessageReceived: TReceivedMessage read fOnMessageReceived write fOnMessageReceived;
  end;

procedure Register;

implementation

uses
  WMsgCommon;

const
  MSGFLT_ADD = 1;
  MSGFLT_REMOVE = 2;

var
  ChangeWindowMessageFilter: function(message: UINT; dwFlag: DWORD): BOOL; stdcall;
  ChangeWindowMessageFilterEx: function(hWnd: HWND; message: UINT; action: DWORD; pChangeFilterStruct: Pointer): BOOL; stdcall;

function EnableLowProcessMessages(hWnd: HWND; Enable: Boolean): Boolean;
var
  hUser32: HMODULE;
  dwMode: Cardinal;
begin
  Result := False;
  hUser32 := GetModuleHandle(user32);

  dwMode := MSGFLT_ADD;
  if not Enable then
    dwMode := MSGFLT_REMOVE;

  // 7+ setting is per-window
  if not Assigned(ChangeWindowMessageFilterEx) then
    ChangeWindowMessageFilterEx := GetProcAddress(hUser32, 'ChangeWindowMessageFilterEx');

  if Assigned(ChangeWindowMessageFilterEx) then
  begin

    Result := ChangeWindowMessageFilterEx(hWnd, WM_COPYDATA, dwMode, nil);
  end;

  if Result then
    Exit;

  // Vista+ setting is per process
  if not Assigned(ChangeWindowMessageFilter) then
    ChangeWindowMessageFilter := GetProcAddress(hUser32, 'ChangeWindowMessageFilter');

  if Assigned(ChangeWindowMessageFilter) then
    Result := ChangeWindowMessageFilter(WM_COPYDATA, dwMode)
end;

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
  // Make sure to clear the variables.
  fActive := false;
  fWndHandle := 0;
end;

destructor TWMsgReceiver.Destroy;
begin
  DestroyWindowAndDeRegister;
  inherited Destroy;
end;

procedure TWMsgReceiver.DestroyWindowAndDeRegister;
begin
  if fWndHandle <> 0 then DestroyWindow(fWndHandle);
  // Ensure to reset the handle to zero.
  fWndHandle := 0;
  Winapi.Windows.UnregisterClass(WINDOWS_MESSAGING_CLASS_NAME, HInstance);
end;

procedure TWMsgReceiver.Start;
begin
  // Avoid creating the window multiple times.
  if Active then
    Exit;

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

  // If necessary, enable messages through UIPI.
  if LowProcessMessages then
    EnableLowProcessMessages(fWndHandle, True)
end;

class function TWMsgReceiver.StaticWndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
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

function TWMsgReceiver.GetActive: boolean;
begin
  Result := fWndHandle > 0
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

procedure TWMsgReceiver.Restart;
var
  Running: boolean;
begin
  // If not active does nothing.
  if not Active then
    Exit;

  // Store current status.
  Running := Active;

  // Stop everything.
  Active := False;

  // If it was running, restart it.
  if Running then
    Active := True
end;

procedure TWMsgReceiver.SetActive(const Value: boolean);
begin
  // Don't do this while in Delphi IDE, runtime only.
  if (Value <> Active) and not(csDesigning in ComponentState) then
    if Value then
      Start
    else
      Stop
end;

procedure TWMsgReceiver.SetLowProcessMessages(const Value: boolean);
begin
  // Only act if changing it.
  if Value = fLowProcessMessages then
    Exit;

  // Changes the value.
  fLowProcessMessages := Value;

  // Only applies it effectively on
  if not (csDesigning in ComponentState) then
    Restart
end;

procedure TWMsgReceiver.SetWindowName(const Value: string);
begin
  // Setters are perfect for validation or side effects
  if fWindowName <> Value then fWindowName := Value;
end;

end.
