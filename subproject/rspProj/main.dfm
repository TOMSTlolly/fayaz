object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'LAN Dpoint test'
  ClientHeight = 472
  ClientWidth = 639
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    639
    472)
  PixelsPerInch = 96
  TextHeight = 13
  object mem: TMemo
    Left = 8
    Top = 8
    Width = 619
    Height = 305
    Anchors = [akLeft, akTop, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object botPANEL: TPanel
    Left = 8
    Top = 319
    Width = 619
    Height = 145
    Anchors = [akLeft, akBottom]
    TabOrder = 1
    object Label1: TLabel
      Left = 151
      Top = 5
      Width = 27
      Height = 13
      Caption = 'PORT'
    end
    object SRV: TLabel
      Left = 11
      Top = 5
      Width = 19
      Height = 13
      Caption = 'SRV'
    end
    object edPORT: TEdit
      Left = 147
      Top = 21
      Width = 46
      Height = 21
      TabOrder = 0
      Text = '5001'
    end
    object listBox: TListBox
      Left = 352
      Top = 8
      Width = 257
      Height = 129
      ItemHeight = 13
      TabOrder = 1
      OnClick = listBoxClick
    end
    object btPUT: TButton
      Left = 199
      Top = 17
      Width = 79
      Height = 25
      Caption = 'Put test file'
      TabOrder = 2
      OnClick = btPUTClick
    end
    object btTimer: TButton
      Left = 147
      Top = 48
      Width = 131
      Height = 25
      Caption = 'Tim Disabled'
      TabOrder = 3
      OnClick = btTimerClick
    end
    object btChk: TButton
      Left = 7
      Top = 48
      Width = 66
      Height = 25
      Caption = 'CHK'
      TabOrder = 4
      OnClick = btChkClick
    end
    object btChk2: TButton
      Left = 79
      Top = 48
      Width = 62
      Height = 25
      Hint = 'Lepsi verze CHK'
      Caption = 'CHK2'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = btChk2Click
    end
    object edServer: TEdit
      Left = 7
      Top = 21
      Width = 134
      Height = 21
      TabOrder = 6
      Text = '5001'
    end
    object btStart: TButton
      Left = 7
      Top = 79
      Width = 134
      Height = 25
      Caption = 'Start TEST !!!'
      TabOrder = 7
      OnClick = btStartClick
    end
    object datePick: TDatePicker
      Left = 147
      Top = 77
      Date = 43335.000000000000000000
      DateFormat = 'dd/MM/yyyy'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      TabOrder = 8
    end
  end
  object idTcpClient: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 8080
    ReadTimeout = -1
    Left = 40
    Top = 120
  end
  object tim: TTimer
    Interval = 10000
    OnTimer = timTimer
    Left = 464
    Top = 48
  end
end
