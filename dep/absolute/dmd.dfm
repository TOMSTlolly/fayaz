object Dmd: TDmd
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 185
  Width = 271
  object absMain: TABSDatabase
    CurrentVersion = '7.61 '
    DatabaseFileName = 'C:\krata\db\dedek\WinKontrol.abs'
    DatabaseName = 'Winkontrol'
    Exclusive = False
    Password = 'tmMm2005!'
    MaxConnections = 500
    MultiUser = True
    SessionName = 'Default'
    Left = 40
    Top = 32
  end
  object absQuery: TABSQuery
    CurrentVersion = '7.61 '
    DatabaseName = 'Winkontrol'
    InMemory = False
    ReadOnly = False
    Left = 128
    Top = 32
  end
  object absPOINT: TABSTable
    CurrentVersion = '7.61 '
    InMemory = False
    ReadOnly = False
    Exclusive = False
    Left = 40
    Top = 96
  end
end
