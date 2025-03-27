unit aEngine;

interface
  uses
    {$ifdef INSPECT}
      siAuto, graphics,
    {$endif}
    kbmMemTable,
    {$ifdef MSQL}
    kbmMemSql,kbmSQLMemTableAPI, kbmSQLStdFunc,kbmSQLElements,
    {$endif}
    DB,sysUtils,variants;

 // vytahni popis cipu
 type ChipType =(chipNone,chipKB,chipGuard,chipEvent);


 type rChip=record
   Id : integer;
   ChipName: string;
   Chip : string;
   ChType: ChipType;
   //FirstPoint : boolean;
 end;

type  rResult=record
   TargetHit: boolean;    // kdyz se mi nepodari umistnit ani jeden bod
   RouteId : integer;
   RouteName : string;
   TotalPoints: integer;
   Shot    : integer;
   Score   : integer;
   Miss    : integer;
   Add     : integer;
   Jak     : integer;   // priznak pro ukladani do stare databaze
end;

 type rRoute=record
     RouteId   : integer;
     RouteName : string;
     List      : string;
 end;

 type TEngine=class
   private
    fkPoint   : TkbmMemTable;
    fkSensor  : TkbmMemTable;
    fkRoute   : TkbmMemTable;
    fkScore   : TkbmMemTable;
    fkSingleRoute : TkbmMemTable;
    fkGuard   : TkbmMemTable;
    fkTapiSer : TkbmMemTable;
    fkFirstPoint: TkbmMemTable;
    fkEvent   : TkbmMemTable;

    fkHole    : TkbmMemTable;

    {$ifdef MSQL}
    fkSql: TkbmMemSQL;
    fkAdd: TkbmMemSQL;
    {$else}
    fkAdd : TkbmMemTable;
    {$endif}

    fSaveTapi  : boolean;
    fWriteAdd: boolean;
    procedure CreateClass;
    procedure SetPoint(const Value: TDataSet);
    procedure SetRoute(const Value: TDataSet);
    procedure SetSensor(const Value: TDataSEt);
    function  GetRoute: TDataSet;
    function  GetRouteIdx: string;
    procedure SetRouteIdx(const Value: string);
    function  GetRouteDef(RouteId: integer): rRoute;
    procedure SetRouteDef(RouteId: integer; const Value: rRoute);
    function  EnterMatId(APointID, AOrder: integer; ASerie: TkbmMemTable): boolean;
    function  GetSingleRoute(RouteId: integer): TkbmMemTable;
    procedure CreateMetaScore(AKt: TkbmMemTable);
    procedure AppendRoute(RouteId: integer; RouteName: string);
    procedure AddScore(RouteId, Score: integer);
    procedure MissAdd(RouteId, Shot,Miss, Add: integer);
    procedure EmptyRouteScore;
    procedure CloneSeries(ARouteId: integer; ARouteName: string; ASerie: TkbmMemTable);
    procedure CreateSerieClone(ASerie: TkbmMemTable);
    procedure AddToSerie(ARouteid, ApointId, AOrder: integer);
    procedure FinishAddPoint;
    procedure SetGuard(const Value: TdataSet);
    function  GetGuard: TDataSet;
    procedure ProcessRemAdd(ARouteId: integer; var Add: integer);
    function  GetPoint: TDataSet;
    procedure SaveTapi(ARouteId: Integer);
    function  GetFirstPoint: TDataSet;
    procedure SetFirstPoint(const Value: TDataSet);
    function  GetEvent: TDataSet;
    procedure SetEvent(const Value: TDataSet);
    procedure SetHole(const Value: TDataSet);
    function GetHole: TDataSet;

   public
    constructor Create;
    destructor  Destroy;

    function   EventName  (aEvent : string) : string;
    function   SensorName (ASensorId: string) : string;
    function   ChipName   (AChipId: string): string;
    function   avtName(ATyp: integer): string;
    function   Chip       (AChip : string) : rChip;
    function   ChipIsFirstPoint(Achip : string) : boolean;
    function   RoutePrep  (ASerie: TKbmMemTable) : rResult;
    procedure  AddPointToRoute(ARoutePoint, APosition: integer);

    property   Point : TDataSet     read  GetPoint      write SetPoint;
    property   Route : TDataSet     read  GetRoute      write SetRoute;
    property   Sensor: TDataSet                         write SetSensor;
    property   Guard : TDataSet     read  GetGuard      write SetGuard;
    property   Event : TDataSet     read  GetEvent      write SetEvent;
    property   Hole  : TDataSet     read GetHole        write SetHole;
    property   FirstPoint: TDataSet read  GetFirstPoint write SetFirstPoint;

    property   RouteIdx: string   read GetRouteIdx write SetRouteIdx;    // nastav index routy

    property   RouteDef [RouteId: integer]: rRoute       read GetRouteDef write SetRouteDef;
    property   kRouteDef[RouteId: integer]: TkbmMemTable read GetSingleRoute;

    property   kSingleRoute : TkbmMemTable read fkSingleRoute ;
    property   kScore       : TkbmMemTable read fkScore;
    property   SaveTps      : boolean      read fSaveTapi write fSaveTapi;
    property   kTapi        : TkbmMemTable read fkTapiSer write fkTapiSer;

    property   WriteAdd     : boolean read fWriteAdd write fWriteAdd;
 end;

implementation

{ TEngine }
procedure TEngine.AppendRoute(RouteId : integer; RouteName: string);
begin
  if not fkScore.locate('RouteId',RouteId,[]) then
  begin
    fkScore.Append;
    fkScore.FieldByName('RouteId').asInteger:= RouteId;
    fkScore.FieldByName('RouteName').asString := RouteName;
    fkScore.Post;
  end;
end;

procedure TEngine.AddScore(RouteId,Score: integer);
begin
  if not fkScore.locate('RouteId',RouteId,[]) then
    raise Exception.CreateFmt('RouteId %d doesnt exists',[RouteId]);

  fkScore.Edit;
  fkScore.FieldByName('Score').asInteger := fkScore.FieldByName('Score').asInteger+Score;
  fkScore.FieldByName('TotalPoints').AsInteger:= fkScore.fieldByName('TotalPoints').asInteger+1;
  fkScore.Post;
end;

procedure TEngine.MissAdd(RouteId,Shot,Miss,Add: integer);
begin
  if not fkScore.locate('RouteId',RouteId,[]) then
    raise Exception.CreateFmt('RouteId %d doesnt exists',[RouteId]);

  fkScore.Edit;
  fkScore.FieldByName('Miss').asInteger := Miss;
  fkScore.FieldbyName('add').asInteger  := Add;
  fkScore.FieldByName('shot').asInteger := Shot;
  fkScore.Post;
end;


procedure Tengine.CreateMetaScore(AKt : TkbmMemTable);
begin
   with AkT.FieldDefs do
   begin
     Clear;
     Add('RouteId'    , ftInteger  , 0 , false);
     Add('RouteName'  , ftString   , 20, false);
     Add('iDiff'      , ftInteger  , 0 , false);
     Add('TotalPoints', ftInteger  , 0 , false);
     Add('Shot'       , ftInteger  , 0 , false);
     Add('Score'      , ftInteger  , 0 , false);
     Add('Miss'       , ftInteger  , 0 , false);
     Add('Add'        , ftInteger  , 0 , false);
   end;
   AKt.CreateTable;
   AKt.AddIndex('score_idx','Score;Miss',[ixDescending]);
   AKt.IndexName := 'score_idx';
end;


// metadata pro Additional point dle vzore pro serii
procedure TEngine.CreateSerieClone(ASerie : TkbmMemTable);
var fd : TfieldDef;
    v : variant;
    f  : TField;
    i  : integer;
    s  : string;
begin
 //  fkAdd.Open;
 //  fkAdd.EmptyTable;
   fkAdd.Active:=false;
   fkAdd.IndexName :='';
   fkAdd.Indexes.Clear;
   fkAdd.IndexDefs.Clear;
   fkAdd.Reset;
   fkAdd.FieldDefs.Assign(ASerie.FieldDefs);
   with fkAdd.FieldDefs.AddFieldDef do
   begin
    DataType:=ftInteger; // identifikator poznamky
    Name:='idMat';
   end;

   {$ifdef INSPECT_ROUTE}
    siMain.LogDataSet('Serie',fkAdd);
   {$endif}


   fkAdd.Open;
   f := fkAdd.FindField('ROUTEID');
   if fkAdd.FindField('routeId')=nil then
   with fkAdd.FieldDefs.AddFieldDef do
   begin
    DataType:=ftInteger; // identifikator poznamky
    Name:='routeId';
   end;

   if fkAdd.FindField('routeName')=nil then
   with fkAdd.FieldDefs.AddFieldDef do
   begin
    DataType:=ftString; // identifikator poznamky
    Name:='RouteName';
    Size := 30;
   end;

   if fkAdd.FindField('ord')=nil then
   with fkAdd.FieldDefs.AddFieldDef do
   begin
    DataType:=ftInteger; // identifikator poznamky
    Name:='ord';
   end;

   if fkAdd.FindField('IsP')=nil then
   with fkAdd.FieldDefs.AddFieldDef do
   begin
    DataType:=ftInteger; // identifikator poznamky
    Name:='IsP';
   end;

   fkAdd.CreateTable;
   fkAdd.AddIndex('routeId_idx','routeId',[]);
   fkAdd.AddIndex('ridpid_idx','routeId;ord',[]);
   fkAdd.AddIndex('rpf_idx','routeId;Point;ord',[]);
   fkAdd.AddIndex('idMat_idx','idMat',[]);
   fkAdd.Active:=true;
end;


// naklonuje seriii pro trasu=RouteID
procedure TEngine.CloneSeries(ARouteId : integer; ARouteName : string; ASerie : TkbmMemTable);
var bm : TBookMark;
    i  : integer;
begin
   // uz mam Serii zalozenou ?
   if fkAdd.Locate('RouteId',ARouteId,[]) then
     exit;

   i := 0;
   bm:= ASerie.GetBookmark;
   // do fkAdd pridej serii s popiskem ARouteId, ARouteName
   ASerie.First;
   while not ASerie.Eof do
   begin
     fkAdd.Append;
     fkAdd.CopyFields(ASerie);
     fkAdd.FieldByName('RouteId').AsInteger   := ARouteId;
     fkAdd.FieldByName('RouteName').AsString  := ARouteName;
     fkAdd.FieldByName('ord').AsInteger       := i;
     fkAdd.Post;
     Inc(i);

     ASerie.Next;
   end;
   ASerie.GotoBookmark(bm);
   ASerie.FreeBookmark(bm);
end;

procedure TEngine.AddToSerie(ARouteid,ApointId,AOrder: integer);
var v: variant;
   i : Integer;
   s : string;
begin
  //fkAdd.AddIndex('rpf_idx','routeId;Point;ord',[]);
  fkAdd.IndexName := 'rpf_idx';
  {$ifdef INSPECT_ROUTE}
    if (APointId=3) and (ARouteId=6) then
      siMain.LogDataSet('--AddToSerie',fkAdd);
  {$endif}

  if not fkAdd.locate('RouteId;Point;idMat',VarArrayOf([ARouteId,APointId,NULL]),[]) then
    raise Exception.CreateFmt('RouteId=%d,Point=%d',[ARouteId,APointId]);

  i := 0;
  while  (fkAdd.FieldByName('RouteId').asInteger=ARouteId) and
         (fkAdd.FieldByName('Point').asInteger=APointId) and
         (not fkAdd.Eof) do
  begin
    v := fkAdd.FieldByName('idMat').AsVariant;
    if VarIsNull(v) then
    begin
      if i<1 then
      begin
        fkAdd.Edit;
        fkAdd.FieldByName('idMat').asInteger:= AOrder;
        // fkAdd.FieldByName('ord').AsInteger  := 0;
        fkAdd.Post;
      end;
    end;
    Inc(i);
    fkAdd.Next;
  end;
  fkAdd.IndexName :='';
  {$ifdef INSPECT_ROUTE}
    if (ARouteId=6) then
    begin
      s := Format('--AddToSerie2.RouteIdx=%d,Point=%d,AOrd=%d',[ARouteid,ApointId,AOrder]);
      siMain.LogDataSet(s,fkAdd);
    end;
  {$endif}
end;


function TEngine.EnterMatId(APointID,AOrder : integer; ASerie : TkbmMemTable): boolean;
var idRoute,idRouteLast,idOrd,iDiff,i :integer;
    RouteName,s : string;
    idMat,idMatLast     : integer;
    AllowWrite : boolean;
    v : Variant;
    FirstPoint,Write : boolean;
begin
  // existuje definovany prvni bod ?
  FirstPoint := ASerie.FieldByName('FirstPoint').AsBoolean;

  Result := false;
  if not fkRoute.locate('POINT;idMat',VarArrayOf([APointId,null]),[]) then
    exit;

  Result:= true;

  idRouteLast := -1;
  idMatLast   := -1;
  idMat       := -1;
  iDiff       := -1;

  while not fkRoute.Eof and (fkRoute.FieldByName('POINT').AsInteger=APointId) do
  begin
    Write := false;
    if FirstPoint then
      if not boolean(fkRoute.FieldByName('settings').asInteger and 32) then
        Write := false
      else
        Write := true;


    idRoute   := fkRoute.FieldByName('RouteID').asInteger;
    RouteName := fkRoute.FieldByName('RouteName').AsString;

    fkRoute.Edit;
    fkRoute.FieldbyName('Touch').asDateTime  := ASerie.FieldbyName('touch').asDateTime;
    fkRoute.FieldByName('idOri').asInteger   := ASerie.FieldByName('Pit').AsInteger;
    fkRoute.FieldByName('idWrite').AsBoolean := Write;
    fkRoute.Post;
    
    {$ifdef INSPECT_ROUTE}
     s := format('Clone Serie Route:%d, Point:%d, Ord:%d',[idRoute,APointId,AOrder]);
     siMain.LogDataSet(s,fkAdd);
     if not fkRoute.locate('POINT;idMat',VarArrayOf([APointId,null]),[]) then
       exit;
    {$ENDIF}

    // ted seekujeme pred duplicitni cipy
    i := 0;
    while not fkRoute.Eof
      and (fkRoute.FieldByName('POINT').AsInteger=APointID)
      and (fkRoute.FieldByName('RouteId').AsInteger=idRoute) do
    begin
      idMat := fkRoute.FieldByName('idMat').AsInteger;  // testuj, jestli nejde o duplicitni chip
      v     := fkRoute.FieldByName('idMat').AsVariant;
      if VarIsNull(v) and (i<1) then
      begin
        CloneSeries(idRoute,RouteName,ASerie);   // zalozim serii pro RouteId, pokud neexistuje
        AddToSerie (idRoute,APointId,AOrder);    // pridej zaznam do serie

        fkRoute.Edit;
        fkRoute.FieldByName('idMat').AsInteger := AOrder;
        fkRoute.Post;
        Inc(i);
      end;

      fkRoute.Next;
    end;


  end;

end;


// v ASerie ocekavam seznam vyctenych bodu, jejich casy, pripadne typy
// ASerie.PointId
// ASerie.Chip
// ASerie.DownloadTime
function TEngine.RoutePrep(ASerie : TKbmMemTable) : rResult;
var i : integer;
    PointId : integer;
    s,saveIndex : string;
    bm : TBookMark;

    // vyhodnoceni trasy
    RouteId,RouteCnt : integer;
    RouteName: string;
    v : Variant;
    sco : integer;
    miss,add : integer;
    iShot: integer;
    idMat: integer;
    ord  : integer;
    //
    TargetHit : Boolean;
begin
  try
   fkRoute.DisableControls;
   ASerie.DisableControls;
   saveIndex := fkRoute.IndexName;
   fkRoute.IndexName := 'search_idx';
   bm := fkRoute.GetBookmark;

   EmptyRouteScore;
   CreateSerieClone(ASerie);

   ASerie.Open;
   {$ifdef INSPECT_ROUTE}
     siMain.LogColored(clGreen,'--- Search route---');
     siMain.logDataSet('Input Serie walk-> ',ASerie);
     SiMain.logDataSet('Input fkRoute indexed->',fkRoute);
   {$endif}

   ASerie.First;
   i := 0;
   TargetHit := false;
   repeat
     PointId := ASerie.FieldByName('Point').asInteger;
     if EnterMatId(PointId,i,ASerie) then
       TargetHit := true;
     {$ifdef INSPECT_ROUTE}
       s := format('RoutePrep.fkRoute.PointId=%d, i=%d',[PointId,i]);
       siMain.LogDataSet(s,fkRoute);
     {$endif}

     ASerie.Next;
     Inc(i);
   until ASerie.Eof ;

   Result.TargetHit := TargetHit;
   if not Result.TargetHit then
     exit;


   fkAdd.IndexName := 'ridpid_idx';

   {$ifdef INSPECT_ROUTE}
     siMain.logDataSet('--fkRoute-po zapisu serie',fkRoute);
     siMain.logDataSet('--kAdditional',fkAdd);
   {$endif}
    FinishAddPoint;  // ve fkAdd nechej jenom body navic
   {$ifdef INSPECT_ROUTE}
     siMain.logDataSet('--kAdditional-Finished',fkAdd);
   {$endif}

   // oboduju trasy a zapisu celkova score
   fkScore.Open;
   fkScore.EmptyTable;

   RouteCnt := 0;
   fkRoute.IndexName := '';

   {$ifdef INSPECT_ROUTE}
     siMain.logDataSet('--fkRoute.idx=0',fkRoute);
   {$endif}


   fkRoute.First;
   while not fkRoute.Eof do
   begin
     RouteId   := fkRoute.FieldByName('routeID').AsInteger;
     RouteName := fkRoute.FieldByName('RouteName').AsString;
     AppendRoute(RouteId,RouteName);
     miss :=0;
     iShot:=0;
     idMat := 0;
     add :=0;
     i   := 0;
     while not fkRoute.Eof and (RouteId = fkRoute.FieldByName('routeId').AsInteger) do
     begin
       // body v tabulce score
       v     := fkRoute.FieldByName('idMat').AsVariant;
       //ord   := fkRoute.FieldByName('ord').asInteger;
       fkRoute.Edit;
       fkRoute.fieldbyName('ord').asInteger:= i;
       fkRoute.Post;
       ord := i;

       idMat := fkRoute.FieldByName('idMat').AsInteger;

       // je to bod, ktery je v trase navic ?
       pointId := fkRoute.FieldByName('POINT').AsInteger;
       if fkAdd.locate('RouteId;Ord',VarArrayOf([RouteId,i]),[]) then
       begin
        fkAdd.Edit;
        fkAdd.FieldByName('IsP').AsInteger:=1;
        Inc(add);
       end;

       if VarIsNull(v) then
       begin
         sco := -1;
         Inc(miss);
       end
       else
       begin
         idMat := idMat + miss - add;
         if (Ord=idMat) then
         begin
           sco := 2;
           Inc(iShot);
         end
         else
         begin
           sco := 1;
           Inc(iShot);
         end;
       end;

       fkRoute.Edit;
       if not VarIsNull(v) then
       begin
         fkRoute.FieldByName('idMat').AsInteger:=idMat;
         fkRoute.FieldByName('iDiff').AsInteger := ord-idMat;
         fkRoute.FieldByName('SCO').AsInteger:= sco;
       end
       else
        fkRoute.FieldByName('sco').asInteger:= sco;
       fkRoute.Post;

       // celkove score do tabulky
       AddScore(RouteId,sco);
       fkRoute.Next;
       Inc(i);
     end;

     // dopocitej Additional points na konci
     ProcessRemAdd(RouteId,Add);

     MissAdd(RouteId,iShot,Miss,add);
   end;

  {$ifdef INSPECT_ROUTE}
   siMain.logDataSet('--kAdditional-IsP',fkAdd);
  {$endif}

   fkRoute.IndexName := '';
   {$ifdef INSPECT}
     //siMain.LogColored(clGreen,'----- RESULTS -----');
     siMain.LogMessage('----RESULTS----');
     siMain.logDataSet('--kRoute',fkRoute);
     siMain.logDataSet('--kScore',fkScore);
   {$endif}


   // v prvnim radku je eventuelne vysledek
   fkScore.First;
   Result.RouteId     := fkScore.FieldByName('RouteId').AsInteger;
   Result.RouteName   := fkScore.FieldByName('RouteName').AsString;
   Result.Miss        := fkScore.FieldByName('miss').AsInteger;
   Result.Add         := fkScore.FieldByName('ADD').AsInteger;
   Result.TotalPoints := fkScore.FieldByName('TotalPoints').AsInteger;
   Result.Score       := fkScore.FieldByName('Score').asInteger;
   Result.Shot        := fkScore.FieldByName('Shot').AsInteger;

   Result.jak := 0;
   if Result.Miss >0 then
     Result.jak := 4;

   if Result.Add>0 then
     Result.jak := Result.jak + 8;

   if Result.jak=0 then
     Result.Jak := 1;

   if fSaveTapi then
     SaveTapi(Result.RouteId);

  finally
   fkRoute.EnableControls;
   ASerie.EnableControls;
   fkRoute.IndexName := saveIndex;
   fkRoute.GotoBookmark(bm);
   fkRoute.FreeBookMark(bm);
  end;
end;


// prekopiruje vysledek do fkRoute
procedure Tengine.SaveTapi(ARouteId : Integer) ;
var i: integer;
    fname : string;
    field : TField;
begin
  if fkRoute.IsEmpty then
    exit;

  FreeAndNil(fkTapiSer);
  fkTapiSer := TkbmMemTable.Create(nil);
  fkTapiSer.CreateTableAs(fkRoute,[mtcpoStructure,mtcpoProperties]);

  if not fkRoute.Locate('RouteID',ARouteId,[]) then
    raise Exception.CreateFmt('Required routeid %d doesnt exists',[ARouteId]);

  //{$ifdef INSPECT}
  //  SiMain.LogDataSet('kRoute.Route.ARouteId '+intToStr(ARouteID),fkTapiSer);
  //{$endif}   

  fkTapiSer.Open;
  while not fkRoute.Eof and (fkRoute.FieldByName('RouteId').AsInteger=ARouteId) do
  begin
    fkTapiSer.Append;
    fkTapiSer.CopyFields(fkRoute);
    fkTapiSer.Post;
    fkRoute.Next;
  end;

  if not fWriteAdd then
    exit;

  // mam v trase body, ktere do ni nepatri ?
  if not fkAdd.Locate('RouteId',ARouteId,[]) then
    exit;

  // pridat additional points ?
  while not fkAdd.Eof and (fkAdd.FieldByName('RouteId').asInteger=ARouteId) do
  begin
    fkTapiSer.Append;

    // zkopiruj sloupce se stejnym jmenem
    for I := 0 to fkRoute.FieldCount-1 do
    begin
      // shoduji se nazvy fieldu ?
      fName := fkTapiSer.Fields[i].FieldName;
      if fkAdd.FieldList.IndexOf(fname) > -1 then
         fkTapiSer.FieldByName(fname).Value := fkAdd.FieldByName(fname).Value
    end;

    fkTapiSer.FieldByName('NAMEPOINT').AsString := fkAdd.FieldByName('ChipName').AsString;
    fkTapiSer.FieldByName('idMat').AsInteger    := -1;
    fkTapiSer.Post;

    fkAdd.Next;
  end;
  

end;

procedure TEngine.ProcessRemAdd(ARouteId: integer; var Add : integer);
begin
  if not fkAdd.Locate('RouteId',ARouteId,[]) then
     exit;

  while (fkAdd.FieldByName('RouteId').asInteger=ARouteId) and not fkAdd.Eof do
  begin
    if fkAdd.FieldByName('IsP').asInteger<1 then
    begin
      fkAdd.Edit;
      fkAdd.FieldByName('IsP').asInteger:=2;
      fkAdd.Post;
      Inc(add);
    end;

    fkAdd.Next;

  end;

end;


procedure TEngine.EmptyRouteScore;
var ASql : string;
begin
    {$IFDEF MSQL}
      FkSQL.Tables.Clear;
      FkSQL.Tables.Add('kRoute',fkRoute);

      ASql := 'update kRoute set idMat=null, Sco=null, iDiff=null';
      FkSQL.ExecSQL(ASQL);
    {$else}
      fkRoute.First;
      while not fkRoute.Eof do
      begin
        fkRoute.Edit;
        fkRoute.FieldByName('idMat').AsVariant := null;
        fkRoute.FieldByName('Sco').AsVariant   := null;
        fkRoute.FieldByName('iDiff').AsVariant := null;
        fkRoute.Post;

        fkRoute.Next;
      end;
    {$endif}
end;

procedure TEngine.FinishAddPoint;
var ASql : string;
    konec : boolean;
    saveIdx : string;
label
   gotoLabel;
begin
  saveIdx := fkAdd.IndexName;
  fkAdd.IndexName := 'idMat_idx';

  {$ifdef MSQL}
  FKSQL.Tables.Clear;
  FKSQL.Tables.Add('kAdd',fkAdd);
  ASql :='delete from kAdd where idMat<>null';
  fKSQL.ExecSql(ASql);
  {$else}
  {$IFDEF INSPECT}
      SiMain.LogDataSet('FinishAddPont.fkAdd',fkAdd);
  {$endif}

  fkAdd.First;
  // if not fkAdd.Locate('idMat',null,[]) then
  //   goto gotoLabel;

  while not fkAdd.Eof  do
  begin
      if (fkAdd.FieldByName('idMat').AsVariant<>null) then
      begin
        fkAdd.Delete;
        fkAdd.First;
      end
      else
        fkAdd.Next;
  end;

  {$IFDEF INSPECT}
      SiMain.LogDataSet('FinishAddPont.fkAdd2',fkAdd);
  {$endif}

gotoLabel:
    fkAdd.IndexName := saveIdx;
  {$endif}
end;



procedure TEngine.SetRoute(const Value: TDataSet);
begin
 // fkRoute.LoadFromDataSet(Value,[mtCpoStructure,mtCpoProperties]);

  // dotahni si sloupec s poradim pro cipy
  fkRoute.Indexes.Clear;
  fkRoute.IndexDefs.Clear;
  fkRoute.Reset;
  fkRoute.FieldDefs.Assign(Value.FieldDefs);
  with fkRoute.FieldDefs.AddFieldDef do
  begin
    DataType:=ftInteger; // identifikator poznamky
    Name:='idMat';
  end;
  with fkRoute.FieldDefs.AddFieldDef do
  begin
    DataType:=ftInteger; // identifikator poznamky
    Name:='iDiff';
  end;
  with fkRoute.FieldDefs.AddFieldDef do
  begin
    DataType:=ftInteger; // identifikator poznamky
    Name:='Sco';
  end;
  with fkRoute.FieldDefs.AddFieldDef do
  begin
    DataType:=ftInteger; // identifikator poznamky
    Name:='idOri';
  end;
  with fkRoute.FieldDefs.AddFieldDef do
  begin
    DataType:=ftDateTime; // identifikator poznamky
    Name:='Touch';
  end;
  with fkRoute.FieldDefs.AddFieldDef do
  begin
    DataType:=ftBoolean; // identifikator poznamky
    Name:='idWrite';
  end;
  fkRoute.CreateTable;

  // metadata do tabulky definice trasy
  fkSingleRoute.FieldDefs.Assign(Value.FieldDefs);
  fkSingleRoute.CreateTable;

  // dotahni si data
  fkRoute.LoadFromDataSet(Value,[]);
  fkRoute.AddIndex('search_idx','POINT;ROUTEID',[]);

  (*
  {$ifdef INSPECT}
   fkRoute.IndexName := '';
   siMain.LogDataSet('SetRoute:',fkRoute);
  {$endif}
  *)

  fkRoute.IndexName := 'search_idx';
end;


procedure TEngine.SetRouteDef(RouteId: integer; const Value: rRoute);
begin

end;

procedure   TEngine.CreateClass;

begin
 // inherited;
  fkPoint       := TkbmMemTable.Create(nil);
  fkSensor      := TkbmMemTable.Create(nil);
  fkRoute       := TkbmMemTable.Create(nil);
  fkSingleRoute := TkbmMemTable.Create(nil);
  fkFirstPoint  := TkbmMemTable.Create(nil);
  fkEvent       := TkbmMemTable.Create(nil);
  fkHole        := TkbmMemTable.Create(nil);

  {$ifdef MSQL}
  fkSql    := TkbmMemSql.Create(niL);
  fkAdd    := TkbmMemSql.Create(nil);
  {$else}
  fkAdd    := TkbmMemTable.Create(nil);
  {$endif}
  fkGuard  := TkbmMemTable.Create(nil);

  fkScore       := TkbmMemTable.Create(nil);
  CreateMetaScore(fkScore);
  fkTapiSer := TkbmMemTable.Create(nil);
end;



destructor TEngine.Destroy;
begin
  freeAndNil(fkPoint);
  FreeAndNil(fkSensor);
  FreeAndNil(fkRoute);
  FreeAndNil(fkSingleRoute);
  FreeAndNil(fkScore);
  FreeAndNil(fkFirstPoint) ;
  FreeAndNil(fkEvent);
  FreeAndNil(fkHole);


  {$IFDEF  MSQL}
    FreeAndNil(fkSql);
    FreeAndNil(fkAdd);
  {$endif}

  FreeAndNil(fkGuard);

  FreeAndNil(fkTapiSer);

//  inherited Destroy;
end;

function TEngine.Chip(AChip: string): rChip;
begin
  Result.Id :=-1;
  Result.Chip := Achip;
  Result.ChipName := '';
  Result.ChType   := chipNone;
  if fkPoint.Locate('CHIP',AChip,[]) then
  begin
    Result.ChipName := fkPoint.FieldByName('NAME').AsString;
    Result.Chip     := AChip;
    Result.Id       := fkPoint.FieldByName('id').AsInteger;
    Result.ChType   := chipKB;
    exit;
  end;

  if fkGuard.Locate('CHIP',AChip,[]) then
  begin
    Result.ChipName := fkGuard.FieldByName('NAME').AsString;
    Result.Chip     := AChip;
    Result.Id       := fkGuard.FieldByName('id').AsInteger;
    Result.ChType   := chipGuard;
    exit;
  end;
end;

function TEngine.ChipIsFirstPoint(Achip: string): boolean;
begin
    Result := fkFirstPoint.Locate('CHIP',AChip,[]);
    if Result then
      Result:=(fkFirstPoint.FieldByName('SETTINGS').AsInteger and 32)=32 ;
end;


function TEngine.ChipName(AChipId : string) : string;
begin
  Result := '';
  if fkPoint.Locate('CHIP',AChipId,[]) then
    Result := fkPoint.FieldByName('NAME').AsString;
end;


function TEngine.EventName(aEvent: string)  : string;
begin
  Result := '';
  if fkEvent.Locate('KEYPAD',aEvent,[]) then
    Result := fkEvent.FieldByName('NAME').AsString;
end;

function TEngine.SensorName(ASensorId: string): string;
begin
  if fkSensor.Locate('serial',ASensorId,[]) then
    Result := fkSensor.FieldByName('name').AsString
  else
    Result := '';
end;

function TEngine.avtName(ATyp : integer) : string;
begin
  case ATyp of
    100 : Result := 'Minivandal';
    101 : Result := 'Crash small';
    102 : Result := 'Crash medium';
    103 : Result := 'Crash big';
    104 : Result := 'Overvoltage';
    105 : Result := 'Temperature';
    106 : Result := 'Microwave';
    107 : Result := 'Temp. info';
  end;
end;


procedure TEngine.SetEvent(const Value: TDataSet);
begin
  fkEvent.LoadFromDataSet(Value,[mtcpoStructure,mtcpoProperties]);
end;


function TEngine.GetEvent: TDataSet;
begin
  Result := fkEvent;
end;

procedure TEngine.SetFirstPoint(const Value: TDataSet);
begin
  fkFirstPoint.LoadFromDataSet(VAlue,[mtcpoStructure,mtcpoProperties]);
end;


function TEngine.GetFirstPoint: TDataSet;
begin
  Result := fkFirstPoint;
end;


procedure TEngine.SetGuard(const Value: TDataSet);
begin
  fkGuard.LoadFromDataSet(Value,[mtCpoStructure,mtCpoProperties]);
end;

procedure TEngine.SetPoint(const Value: TDataSet);
begin
  fkPoint.LoadFromDataSet(Value,[mtCpoStructure,mtCpoProperties]);
end;


procedure TEngine.SetSensor(const Value: TDataSEt);
begin
  fkSensor.LoadFromDataSet(Value,[mtCpoStructure,mtCpoProperties]);
end;

constructor TEngine.Create;
begin
 // inherited;
  CreateClass;
end;


procedure TEngine.SetHole(const Value: TDataSet);
begin
  fkPoint.LoadFromDataSet(Value,[mtCpoStructure,mtCpoProperties]);
end;


function TEngine.GetRouteIdx: string;
begin
 Result := fkRoute.IndexName;
end;


procedure TEngine.SetRouteIdx(const Value: string);
begin
  fkRoute.IndexName := Value;
end;


function TEngine.GetGuard: TDataSet;
begin
  Result:= fkGuard as TDataSet;
end;

function TEngine.GetHole: TDataSet;
begin
  Result := fkHole as TDataSet;
end;

function TEngine.GetPoint: TDataSet;
begin
  Result := fkPoint as TDataSet;
end;

function TEngine.GetRoute: TDataSet;
begin
  Result := fkRoute as TDataSet;
end;

function TEngine.GetRouteDef(RouteId: integer): rRoute;
var svIdx : string;
    s     : string;
    i    : integer;
    bm  : Tbookmark;
begin
  // spravny index
  try
    fkRoute.DisableControls;
    bm := fkRoute.GetBookmark;
    svIdx := fkRoute.IndexName;
    fkRoute.indexName := '';

    if not fkRoute.Locate('RouteID',RouteId,[]) then
      raise Exception.CreateFmt('RouteiD %d doesnt exists',[RouteId]);

    Result.RouteName := fkRoute.FieldByName('ROUTENAME').AsString;
    i := 0;
    s := '';
    fkSingleRoute.Open;
    fkSingleRoute.EmptyTable;
    while not (fkRoute.Eof) and (fkRoute.FieldByName('RouteId').AsInteger=RouteId) do
    begin
      if i>0 then
        s:=s+',';

      fkSingleRoute.Append;
      fkSingleRoute.CopyFields(fkRoute);
      fkSingleRoute.Post;

      s := s+fkRoute.FieldByName('POINT').AsString;
      Inc(i);
      fkRoute.Next;
    end;
    Result.List := s;
    Result.RouteId := RouteId;
  finally
    fkRoute.IndexName := svIdx;
    fkRoute.GotoBookmark(bm);
    fkRoute.FreeBookmark(bm);
    fkRoute.EnableControls;
  end;
  {$ifdef INSPECT}
  siMain.LogDataSet('fkSingleRoute '+Result.RouteName,fkSingleRoute);
  {$endif}
end;

// pro testovani algoritmu
// umele pridam bod k trase popsane ARouteId
procedure TEngine.AddPointToRoute(ARoutePoint,APosition : integer);
var i : integer;
    RouteId,Settings : integer;
    RouteName : string;
    //konec: boolean;
begin
  // pridam bod na pozici APosition
  RouteId  := fkSingleRoute.FieldByName('RouteId').AsInteger;
  Settings := fkSingleRoute.FieldByName('Settings').AsInteger;
  RouteName:= fkSingleRoute.FieldByName('RouteName').AsString;;
  i := 0;
  fkSingleRoute.First;
  while not fkSingleRoute.Eof and  (i<APosition) do
  begin
    Inc(i);
    fkSingleRoute.Next;
  end;

  // najdi zbyle info ke kontrolnimu bodu
  if not fkPoint.Locate('ID',ARoutePoint,[]) then
    raise Exception.CreateFmt('Point %d doesnt exists',[ARoutePoint]);

  if fkSingleRoute.Eof then
    fkSingleRoute.Append
  else
    fkSingleRoute.Insert;

  fkSingleRoute.FieldByName('RouteName').AsString := RouteName;
  fkSingleRoute.FieldByName('Settings').AsInteger := Settings;
  fkSingleRoute.FieldByName('RouteId').AsInteger  := RouteId;
  fkSingleRoute.FieldByName('POINT').asInteger    := ARoutePoint;
  fkSingleRoute.FieldByName('CHIP').AsString      := fkPoint.FieldByname('CHIP').AsString;
  fkSingleRoute.FieldByName('NAMEPOINT').AsString := fkPoint.FieldByName('NAME').AsString;
  fkSingleRoute.Post;
end;

function TEngine.GetSingleRoute(RouteId: integer): TkbmMemTable;
begin
  getRouteDef(RouteId);
  Result := fkSingleRoute;
end;




end.

