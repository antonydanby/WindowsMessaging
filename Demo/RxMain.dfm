object RXForm: TRXForm
  Left = 0
  Top = 0
  BorderWidth = 4
  Caption = 'Receiver'
  ClientHeight = 347
  ClientWidth = 440
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 64
    Width = 440
    Height = 283
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitTop = 32
    ExplicitHeight = 315
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 440
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    DesignSize = (
      440
      32)
    object ReceiverEdit: TEdit
      Left = 4
      Top = 4
      Width = 121
      Height = 24
      Align = alLeft
      TabOrder = 0
      Text = 'ReceiverWindow'
      OnChange = ReceiverEditChange
      ExplicitHeight = 21
    end
    object btnStart: TButton
      Left = 284
      Top = 2
      Width = 75
      Height = 24
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Start'
      TabOrder = 1
      OnClick = btnStartClick
    end
    object btnStop: TButton
      Left = 365
      Top = 2
      Width = 75
      Height = 24
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Stop'
      Enabled = False
      TabOrder = 2
      OnClick = btnStopClick
    end
  end
  object SubPanel: TPanel
    Left = 0
    Top = 32
    Width = 440
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 2
    ExplicitTop = 8
    DesignSize = (
      440
      32)
    object chkUIPI: TCheckBox
      Left = 4
      Top = 6
      Width = 436
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Enable messages from processes with lower user execution level'
      TabOrder = 0
      OnClick = chkUIPIClick
    end
  end
  object WMsgReceiver: TWMsgReceiver
    Active = False
    LowProcessMessages = False
    WindowName = 'DefaultWindow'
    OnMessageReceived = WMsgReceiverMessageReceived
    Left = 312
    Top = 184
  end
end
