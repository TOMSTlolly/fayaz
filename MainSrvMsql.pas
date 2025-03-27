unit MainSrvMsql;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  registry, http,
  {$ifdef INSPECT}
    siAuto,
  {$endif}
   Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs;

type
  TfFazSrvMs = class(TService)
    procedure ServiceCreate(Sender: TObject);

    procedure ServiceExecute(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);  private

  private
    fTh : TTCPHttpDaemon;
    procedure ServiceAfterInstallx(Sender: TService);
    procedure DoLogMsg(Sender: TThread; AMessage: String);
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  fFazSrvMs: TfFazSrvMs;

implementation

{$R *.dfm}

procedure TfFazSrvMs.DoLogMsg(Sender : TThread; AMessage: String);
begin
  {$ifdef INSPECT}
      siMain.LogColored(clMoneyGreen,AMessage);
  {$endif}
end;

procedure TfFazSrvMs.ServiceAfterInstall(Sender: TService);
begin
  ServiceAfterInstallx(Sender);
end;

procedure TfFazSrvMs.ServiceAfterInstallx(Sender: TService);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name, false) then
    begin
      Reg.WriteString('Description', 'TOMST MSql LanPoint service');
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TfFazSrvMs.ServiceCreate(Sender: TObject);
begin
   {$ifdef INSPECT}
      //siMain.ClearLog;
      siMain.LogColored(clMoneyGreen,'FayService Created: Name '+Name);
   {$endif}
end;

procedure TfFazSrvMs.ServiceExecute(Sender: TService);
begin
  {$ifdef INSPECT}
      siMain.LogColored(clMoneyGreen,'Service executed');
  {$endif}

  fTh := TTCPHttpDaemon.create;
  while not Terminated do
     ServiceThread.ProcessRequests(True);

  {$ifdef INSPECT}
     siMain.LogColored(clRed,'ServiceExecute-Stop');
  {$endif}
end;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  fFazSrvMs.Controller(CtrlCode);
end;

function TfFazSrvMs.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

end.
