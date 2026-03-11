object TXForm: TTXForm
  Left = 0
  Top = 0
  ActiveControl = btnSend
  Caption = 'Sender'
  ClientHeight = 93
  ClientWidth = 361
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object lblResult: TLabel
    Left = 168
    Top = 11
    Width = 3
    Height = 13
  end
  object SendEdit: TEdit
    Left = 8
    Top = 62
    Width = 257
    Height = 21
    TabOrder = 2
    Text = 'Hello Receiver!'
  end
  object btnSend: TButton
    Left = 271
    Top = 60
    Width = 75
    Height = 25
    Caption = 'Send'
    TabOrder = 3
    OnClick = btnSendClick
  end
  object EditID: TEdit
    Left = 8
    Top = 35
    Width = 90
    Height = 21
    TabOrder = 1
    Text = '100'
  end
  object ReceiverEdit: TEdit
    Left = 8
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'ReceiverWindow'
  end
  object WMsgSender: TWMsgSender
    WindowName = 'ReceiverWindow'
    OnSendResult = WMsgSenderSendResult
    Left = 296
    Top = 8
  end
end
