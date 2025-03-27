object Form1: TForm1
  Left = 0
  Top = 0
  Anchors = [akLeft, akTop, akBottom]
  Caption = 'test'
  ClientHeight = 447
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    497
    447)
  PixelsPerInch = 96
  TextHeight = 13
  object Mem: TMemo
    Left = 8
    Top = 8
    Width = 461
    Height = 407
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Rusty communication tester')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object idTcpSrv: TIdTCPServer
    Active = True
    Bindings = <
      item
        IP = '0.0.0.0'
        Port = 5000
      end>
    DefaultPort = 5000
    OnExecute = idTcpSrvExecute
    Left = 168
    Top = 160
  end
end
