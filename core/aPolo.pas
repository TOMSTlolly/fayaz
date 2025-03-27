unit aPolo;

interface


uses
    {$ifdef INSPECT}
      siAuto,
      graphics,
    {$endif}

    pooling,
    {$ifdef MSQL}
    dmdMsql,
    {$else}
    dmd,
    {$endif}
    Synautil, SysUtils,iniFiles ,
    aEngine;

type TPolo=class
    private
      fIdx  : integer;
      fPool : TObjectPool;
      fDataPath : string;
      fTextPath : string;
      fPort     : integer;
      fEngine   : TEngine;

      fServer   : string;
      fLogin    : string;
      fPassword : string;
      fDatabase : string;
      fLoginPrompt : boolean;
      fServerPort : integer;
      fProvider : string;

      fFindRoute  : boolean;
      fSaveToTxt  : boolean;
      fSaveFolder : string;
      fLogFolder  : string;

      procedure   DoCreatePool(Sender : TObject; var AObject: TObject);
      procedure   DoDestroyPool(Sender: TObject; var AObject: TObject);
      function    DescriptBool(AValue: boolean): string;
    public
      function    Acquire : TObject;
      procedure   Release(var Sender : TObject);
      constructor Create;
      destructor  Destroy;


  end;

var fPolo : TPolo;

implementation


(****** POOL INIT ******)
function TPolo.Acquire: TObject;
var tag : integer;
begin
  Result := fPool.Acquire;

  tag := -1;
  if assigned(Result) then
    tag := (Result as Tdmd).Tag;

  {$ifdef INSPECT}
   if tag<0 then
     siMain.LogDebug(format('!!! dmd.%d not acquired',[Tag]))
   else
     siMain.LogDebug(format('...OK dmd.%d acquired',[Tag]))
  {$endif}

end;


procedure TPolo.Release(var Sender : TObject);
var tag : integer;
begin
  if assigned(Sender) then
  begin
    tag := (Sender as Tdmd).Tag   ;
    fPool.Release(Sender);
  end
  else
    tag := -1;

  {$ifdef INSPECT}
   siMain.LogDebug(format('dmd.%d released',[Tag]));
  {$endif}
end;


procedure TPolo.DoCreatePool(Sender : TObject; var Aobject: Tobject) ;
var msg : string;
begin
  fEngine := TEngine.Create;

   Aobject:= TDmd.Create(nil);
  (AObject as Tdmd).Tag        := fIdx;
  (AObject as Tdmd).Engine     := fEngine;
  (AObject as Tdmd).TextPath   := fTextPath;

  {$ifdef MSQL}
   // inicializace SQL serveru
  (AObject as Tdmd).Server   :=  fServer ;
  (AObject as Tdmd).Login    :=  fLogin  ;
  (AObject as Tdmd).Password :=  fPassword;
  (AObject as Tdmd).DataBase :=  fDatabase ;
  (AObject as Tdmd).LoginPrompt:=  fLoginPrompt;
  (AObject as Tdmd).ServerPort := fServerPort;
  (AObject as Tdmd).Provider   := fProvider;
  {$endif}

  (AObject as Tdmd).FindRoute := fFindRoute;
  (AObject as Tdmd).SaveToTxt := fSaveToTxt;
  (AObject as Tdmd).SaveFolder:= fSaveFolder;

   // Connect k databazi a load potrebnych tabulek
  (AObject as Tdmd).DataPath   := fDataPath;  // tady zaroven startuju databazi

  msg := format('.. dmd %d created ok',[fIdx]);
  Inc(fIdx);
  {$ifdef INSPECT}
   siMain.LogColored(clMoneyGreen,msg);
  {$endif}
  // fMain.LogMsg(msg);
end;

procedure TPolo.DoDestroyPool(Sender : TObject; var AObject : TObject);
var msg: string;
begin
  msg := format('.. dmd %d released ok',[(AObject as Tdmd).Tag]);
  FreeAndNil(AObject);

  fEngine.Destroy;
//  FreeAndNil(fEngine);
  {$ifdef INSPECT}
   siMain.LogColored(clMoneyGreen,msg);
  {$endif}
  //fMain.LogMsg(msg);
end;


function  TPolo.DescriptBool(AValue : boolean) : string;
begin
  if AValue then Result := 'ENABLED'
  else           Result := 'OFF';
end;


destructor TPolo.Destroy;
begin
  fPool.Stop;
  FreeAndNil(fPool);

 // inherited;
end;

constructor  TPolo.Create;
var msg,Path : string;
    AppIni : TIniFile;
    PoolSize : integer;
    AutoGrow : boolean;
begin
  fIdx :=1;
  Path :=  ExtractFilePath(ParamStr(0))+'mz.ini';
   AppIni        := TIniFile.Create(Path);
   with AppIni do begin
     PoolSize := ReadInteger('POOL', 'PoolSize', 2);
     AutoGrow := ReadBool('POOL','AutoGrow',false);

     fDataPath:= ReadString('DB','Path','localpath');
     fTextPath:= ReadString('DB','OutFolder','localpath');
     fPort    := ReadInteger('DB','Port',5001);

     fProvider := ReadString('PROVIDER','Provider','MSSQL');
     if UpperCase(fProvider)='ORACLE' then
     begin
        fServer   := ReadString('ORACLE','Server','127.0.0.1');
        fLogin    := ReadString('ORACLE','Login' ,'KRATA');
        fPassword := ReadString('ORACLE','Password' ,'tomstr26');
        fDatabase := ReadString('ORACLE','Database' ,'KRATA');
        fLoginPrompt:= ReadBool('ORACLE','LoginPrompt',false);
        fServerPort := ReadInteger('ORACLE','ServerPort',1521);
     end
     else if UpperCase(fProvider)='MSSQL' then
     begin
       fServer      := ReadString('MSSQL','Server','DPOINT-SERVER\NTAUTHORITY');
       fLogin       := ReadString('MSSQL','Login' ,'sa');
       fPassword    := ReadString('MSSQL','Password' ,'123456789');
       fDatabase    := ReadString('MSSQL','Database' ,'dpoint');
       fLoginPrompt := ReadBool('MSSQL','LoginPrompt',false);
       fServerPort  := ReadInteger('MSSQL','ServerPort',1433);
     end;

     // sekce function
     fFindRoute  := ReadBool('FUNCTION','FindRoute',false);   // hledej trasu
     fSaveToTxt  := ReadBool('FUNCTION','SaveToTxt',false);   // data uloz do txt souboru
     fSaveFolder := ReadString('FUNCTION','SaveFolder','');   // uloz do adresare
   end;
   FreeAndNil(appIni);

  fPool                 := TObjectPool.Create;
  fPool.PoolSize        := PoolSize;//ReadInteger('POOL', 'SIZE', 20);
  fPool.AutoGrow        := AutoGrow; //ReadBool('POOL', 'AUTOGROW', false);
  fPool.OnCreateObject  := DoCreatePool;
  fPool.OnDestroyObject := DoDestroyPool;
  fPool.RaiseExceptions := true;  // POZOR NA THREADY

  msg := Format('Initializing  pool with %d objects',[fPool.PoolSize]);
  {$ifdef INSPECT}
   siMain.LogColored(clMoneyGreen,msg);
  {$endif}
  fPool.Start;

  msg :=Format('Inicializing pool is OK, AutoGrow: %s',[DescriptBool(AutoGrow)]);
  {$ifdef INSPECT}
   siMain.LogColored(clMoneyGreen,msg);
  {$endif}
end;

end.
