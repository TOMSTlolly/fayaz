unit MainSrv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  registry, http,
  {$ifdef INSPECT}
    siAuto,
  {$endif}
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs;

type
  TFayService = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceCreate(Sender: TObject);

    procedure ServiceExecute(Sender: TService);  private
    procedure ServiceAfterInstallx(Sender: TService);
  private
    fTh : TTCPHttpDaemon;
    procedure DoLogMsg(Sender: TThread; AMessage: String);
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  FayService: TFayService;

implementation

{$R *.dfm}

procedure TFayService.ServiceAfterInstallx(Sender: TService);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name, false) then
    begin
      Reg.WriteString('Description', 'TOMST LanPoint service');
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TFayService.DoLogMsg(Sender : TThread; AMessage: String);
begin
  //listBox.items.Add(AMessage);
  //listBox.itemIndex:= listBox.items.count-1;
end;



procedure TFayService.ServiceCreate(Sender: TObject);
begin
  // fDBConnected := false;
   {$ifdef INSPECT}
      siMain.ClearLog;
      siMain.LogColored(clMoneyGreen,'FayService Created');
   {$endif}
end;

procedure TFayService.ServiceExecute(Sender: TService);
begin
  {$ifdef INSPECT}
      siMain.LogColored(clMoneyGreen,'Service executed');
  {$endif}

  fTh := TTCPHttpDaemon.create(DoLogMsg);
  while not Terminated do
     ServiceThread.ProcessRequests(True);

  {$ifdef INSPECT}
     siMain.LogColored(clRed,'ServiceExecute-Stop');
  {$endif}
end;

procedure TFayService.ServiceAfterInstall(Sender: TService);
begin
  ServiceAfterInstallx(Sender);
end;


procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  FayService.Controller(CtrlCode);
end;

function TFayService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

end.
