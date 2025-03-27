object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'LAN-POINT MSQL Writer'
  ClientHeight = 604
  ClientWidth = 816
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = pMain
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  TextHeight = 13
  object mainPanel: TPanel
    Left = 0
    Top = 0
    Width = 816
    Height = 604
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 812
    ExplicitHeight = 603
    object pgMain: TPageControl
      Left = 1
      Top = 1
      Width = 814
      Height = 602
      ActivePage = tbLog
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 810
      ExplicitHeight = 601
      object tbLog: TTabSheet
        Caption = 'Log'
        object Splitter2: TSplitter
          Left = 0
          Top = 395
          Width = 806
          Height = 3
          Cursor = crVSplit
          Align = alBottom
          ExplicitTop = 0
          ExplicitWidth = 149
        end
        object ListBox: TListBox
          Left = 0
          Top = 0
          Width = 806
          Height = 395
          Align = alClient
          ItemHeight = 13
          TabOrder = 0
        end
        object Panel1: TPanel
          Left = 0
          Top = 398
          Width = 806
          Height = 176
          Align = alBottom
          BorderWidth = 1
          Caption = 'Panel1'
          Color = clMoneyGreen
          ParentBackground = False
          TabOrder = 1
          object Splitter1: TSplitter
            Left = 2
            Top = 99
            Width = 802
            Height = 3
            Cursor = crVSplit
            Align = alBottom
            ExplicitWidth = 75
          end
          object lview: TListView
            Left = 2
            Top = 2
            Width = 802
            Height = 97
            Align = alClient
            Columns = <
              item
                Caption = '-'
                MaxWidth = 20
                Width = 20
              end
              item
                Caption = 'ip'
                MinWidth = 100
                Width = 100
              end
              item
                Caption = 'Local IP'
                Width = 100
              end
              item
                Caption = 'mac'
                MinWidth = 100
                Width = 100
              end
              item
                Caption = 'user'
                MaxWidth = 80
                Width = 80
              end
              item
                Caption = 'stat'
              end
              item
                Caption = 'Hbt'
              end
              item
                Caption = 'Tran'
                Width = 40
              end
              item
                Caption = 'Diff'
                MaxWidth = 200
                Width = 80
              end
              item
                Caption = 'Last Transfer'
                Width = 120
              end>
            SmallImages = imgList
            TabOrder = 0
            ViewStyle = vsReport
          end
          object lbLive: TListBox
            Left = 2
            Top = 102
            Width = 802
            Height = 72
            Align = alBottom
            ItemHeight = 13
            TabOrder = 1
          end
        end
      end
      object tbRoute: TTabSheet
        Caption = 'Route'
        ImageIndex = 1
        object labRouteName: TLabel
          Left = 3
          Top = 526
          Width = 70
          Height = 13
          Caption = 'labRouteName'
        end
        object btSaveLog: TButton
          Left = 0
          Top = 545
          Width = 145
          Height = 25
          Caption = 'Save Log'
          TabOrder = 0
          Visible = False
          OnClick = btSaveLogClick
        end
        object btParse: TButton
          Left = 100
          Top = 446
          Width = 89
          Height = 25
          Caption = 'Prep idx.'
          TabOrder = 1
          OnClick = btParseClick
        end
        object btRoutes: TButton
          Left = 3
          Top = 446
          Width = 91
          Height = 25
          Caption = 'Routes'
          TabOrder = 2
          OnClick = btRoutesClick
        end
        object edRoute: TEdit
          Left = 4
          Top = 499
          Width = 185
          Height = 21
          TabOrder = 3
          Text = 'edRoute'
        end
        object edTest: TEdit
          Left = 3
          Top = 477
          Width = 186
          Height = 21
          TabOrder = 4
          Text = 'edTest'
        end
        object btCopy: TButton
          Left = 195
          Top = 475
          Width = 75
          Height = 25
          Caption = 'Copy'
          TabOrder = 5
          OnClick = btCopyClick
        end
        object bSearch: TButton
          Left = 195
          Top = 446
          Width = 75
          Height = 25
          Caption = 'Search'
          TabOrder = 6
          OnClick = bSearchClick
        end
        object PageControl1: TPageControl
          Left = 0
          Top = 7
          Width = 681
          Height = 433
          ActivePage = tabMiss
          Align = alCustom
          TabOrder = 7
          object tabGrid: TTabSheet
            Caption = 'tabGrid'
            DesignSize = (
              673
              405)
            object dgPoints: TDBGrid
              Left = 3
              Top = 3
              Width = 658
              Height = 399
              Anchors = [akLeft, akTop, akRight, akBottom]
              DataSource = dsGRID
              TabOrder = 0
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              OnCellClick = dgPointsCellClick
              Columns = <
                item
                  Expanded = False
                  FieldName = 'RouteId'
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'RouteName'
                  Title.Caption = 'Name'
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'Settings'
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'NamePoint'
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'Chip'
                  Width = 50
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'Ord'
                  Width = 24
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'Point'
                  Width = 36
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'idMat'
                  Width = 30
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'iDiff'
                  Width = 23
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'Sco'
                  Width = 25
                  Visible = True
                end>
            end
          end
          object tabRoute: TTabSheet
            Caption = 'tabRoute'
            ImageIndex = 1
            DesignSize = (
              673
              405)
            object dgSeq: TDBGrid
              Left = 3
              Top = 0
              Width = 667
              Height = 371
              Anchors = [akLeft, akTop, akRight, akBottom]
              DataSource = dsSq
              TabOrder = 0
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
            end
            object DBNavigator1: TDBNavigator
              Left = 3
              Top = 377
              Width = 240
              Height = 25
              DataSource = dsSq
              Anchors = [akLeft, akBottom]
              TabOrder = 1
            end
          end
          object tabScore: TTabSheet
            Caption = 'tabScore'
            ImageIndex = 2
            DesignSize = (
              673
              405)
            object DBGrid2: TDBGrid
              Left = 3
              Top = 3
              Width = 667
              Height = 399
              Anchors = [akLeft, akTop, akRight, akBottom]
              DataSource = dsScore
              TabOrder = 0
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
            end
          end
          object tabREPX: TTabSheet
            Caption = 'tabREPX'
            ImageIndex = 3
          end
          object tabMiss: TTabSheet
            Caption = 'tabMiss'
            ImageIndex = 4
          end
        end
        object btMissing: TButton
          Left = 312
          Top = 446
          Width = 97
          Height = 25
          Caption = 'Missing'
          TabOrder = 8
          OnClick = btMissingClick
        end
      end
    end
  end
  object dsGRID: TDataSource
    Left = 36
    Top = 136
  end
  object kbSeq: TkbmMemTable
    DesignActivation = True
    AttachedAutoRefresh = True
    AttachMaxCount = 1
    FieldDefs = <>
    IndexDefs = <>
    SortOptions = []
    PersistentBackup = False
    ProgressFlags = [mtpcLoad, mtpcSave, mtpcCopy]
    LoadedCompletely = True
    SavedCompletely = False
    FilterOptions = []
    Version = '7.98.00 Standard Edition'
    LanguageID = 0
    SortID = 0
    SubLanguageID = 1
    LocaleID = 1024
    AutoUpdateFieldVariables = False
    Left = 84
    Top = 168
    object kbSeqpit: TAutoIncField
      FieldName = 'pit'
    end
    object kbSeqPointId: TIntegerField
      FieldName = 'PointId'
    end
  end
  object dsSq: TDataSource
    DataSet = kbSeq
    Left = 132
    Top = 168
  end
  object dsScore: TDataSource
    Left = 240
    Top = 136
  end
  object tim: TTimer
    Left = 240
    Top = 192
  end
  object dsStatus: TDataSource
    Left = 189
    Top = 105
  end
  object imgList: TImageList
    Left = 149
    Top = 97
    Bitmap = {
      494C010103000500040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF00008400000084000000840000008400FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000A5000000AD000008
      AD000000A50000009400FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000A5000000
      9C000000AD00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      8400C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C6000000
      8400FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000AD001842F700184A
      FF001031D6000000AD000000BD00FFFFFFFF000000000000B5000829D6000829
      D6000010B5000000AD00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00008400C6C6
      C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF0094000000840000008C0000008C0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000B5002152FF001852
      FF00184AFF001042EF000008B5000000AD000000AD000829DE001042FF000839
      F7000839F7000018BD000000A500FFFFFFFFFFFFFFFF00008400C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF009C
      0000008C000010AD210010B529000094080000940000FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000AD001831DE00295A
      FF002152FF002152FF00184AF7000008B5000831DE00104AFF001042FF001042
      F7000839F7000839F70000009C00FFFFFFFFFFFFFFFFC6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60000008400FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFF00AD00000094
      000010AD290010B5310010AD290010B529000094080000940000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000BD001831DE00396B
      FF00295AFF00295AFF002152FF002152FF00184AFF00184AFF001042FF001042
      FF000839F7000008B5000000A500FFFFFFFF00008400C6C6C60000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C60000000000C6C6C600FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFF00B50000009C000018B5
      310018B5390018B5310031BD4A0010B5310010B529000094080000940000FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000CE001018
      C600396BFF003163FF00295AFF00295AFF002152FF00184AFF00184AFF001039
      EF000000AD000000BD00FFFFFFFFFFFFFFFFC6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600000084000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFF08A5100018B5390021BD
      420018BD420010AD2100008C000063C6730018B5310010B52900009408000094
      0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      CE000000B500294AE700316BFF00295AFF00295AFF002152FF001039EF000000
      A5000000A500FFFFFFFFFFFFFFFFFFFFFFFFC6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60000008400C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600000084000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFF29B5310042CE630018BD
      420010B5290000A50000009C00000094000063CE730018B5310010B52900008C
      080000940000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF0000C6002139DE00396BFF003163FF00295AFF00215AFF001842EF000000
      AD0000009C00FFFFFFFFFFFFFFFFFFFFFFFFC6C6C60000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600000000000000840000000000000000000000
      0000C6C6C600C6C6C60000000000000084000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFF08BD210042C6520031BD
      4A0000AD080000000000FFFFFFFF00AD00000094000063CE730010B5310010B5
      290000940800009C0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF0000C6004A7BFF004273FF00396BFF00396BFF00295AFF00215AFF001031
      D6000000B500FFFFFFFFFFFFFFFFFFFFFFFFC6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600000084000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFF10D6210008BD
      2100007B0000FFFFFFFFFFFFFFFFFFFFFFFF00AD00000094000063CE730010B5
      310010B5290000940800008C0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      D6002139DE005284FF004273FF003163FF000810C600396BFF00295AFF002152
      FF000818C6000000BD00FFFFFFFFFFFFFFFF00008400C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00AD00000094000063CE
      730010B5310010B53100008C0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      CE00527BFF005284FF004A7BFF000810CE000000BD000810C600396BFF002152
      FF00184AF7000000B5000000BD00FFFFFFFF00008400C6C6C60000000000C6C6
      C600C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C60000000000C6C6C600FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00A500000094
      000063CE7B0029BD4200008C0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1018
      DE006B9CFF00528CFF002942E7000000CE00FFFFFFFF0000CE000818CE003163
      FF001852FF001039DE000000B500FFFFFFFFFFFFFFFFC6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60000008400FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0094
      0000009400000094000000840000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      DE003952E7005284FF000000CE00FFFFFFFFFFFFFFFFFFFFFFFF0000CE001021
      D600215AFF000829E7000000B500FFFFFFFFFFFFFFFFFFFFFFFFC6C6C600C6C6
      C60000000000C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C6000000
      0000C6C6C60000008400FFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF0000D6000000BD000000CE00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      C6000000BD000000B50000007B00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC6C6
      C600C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6
      C60000008400FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF0000840000008400C6C6C600C6C6C600C6C6C600C6C6C60000008400FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object pMain: TMainMenu
    Left = 413
    Top = 121
    object pfile: TMenuItem
      Caption = 'File'
      object pSaveLog: TMenuItem
        Action = acSaveLog
      end
      object pClear: TMenuItem
        Action = acClear
      end
    end
  end
  object acList: TActionList
    Left = 485
    Top = 129
    object acSaveLog: TAction
      Caption = 'Save Log'
      OnExecute = acSaveLogExecute
    end
    object acClear: TAction
      Caption = 'Clear Log'
      OnExecute = acClearExecute
    end
  end
end
