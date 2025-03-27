object dmd: Tdmd
  OnCreate = DataModuleCreate
  Height = 224
  Width = 384
  object fTimer: TTimer
    Enabled = False
    Interval = 8000
    OnTimer = fTimerTimer
    Left = 288
    Top = 40
  end
  object uniConn: TUniConnection
    AutoCommit = False
    DataTypeMap = <
      item
        DBType = 105
        DBLengthMin = 0
        DBLengthMax = 38
        DBScaleMin = 0
        DBScaleMax = 0
        FieldType = ftInteger
      end
      item
        FieldName = 'maxpk'
        FieldType = ftInteger
      end>
    ProviderName = 'SQL Server'
    Port = 1433
    Database = 'drevo'
    SpecificOptions.Strings = (
      'Oracle.Schema=KRATA'
      'Oracle.Direct=True')
    Debug = True
    Username = 'sa'
    Server = 'LAPTOP-0IFCDLRJ\SQLEXPRESS'
    ConnectDialog = uniDialog
    LoginPrompt = False
    Left = 16
    Top = 110
    EncryptedPassword = '8CFF97FF96FF8BFF96FF94FF'
  end
  object uniQuery: TUniQuery
    Connection = uniConn
    Left = 80
    Top = 110
  end
  object uniDialog: TUniConnectDialog
    DatabaseLabel = 'Database'
    PortLabel = 'Port'
    ProviderLabel = 'Provider'
    SavePassword = True
    Caption = 'Connect'
    UsernameLabel = 'User Name'
    PasswordLabel = 'Password'
    ServerLabel = 'Server'
    ConnectButton = 'Connect'
    CancelButton = 'Cancel'
    Left = 144
    Top = 110
  end
  object sqlMicrosoft: TSQLServerUniProvider
    Left = 216
    Top = 110
  end
  object sqlOracle: TOracleUniProvider
    Left = 288
    Top = 112
  end
end
