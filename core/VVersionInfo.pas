unit VVersionInfo;
{---------------------------------------------------------------------------}
{  Author  : Michael John Phillips                                          }
{  Address : 5/5 Waddell Place                                              }
{            Curtin ACT 2605                                                }
{  Tel     : +61 (2) 6281-1980                                              }
{  Fax     : +61 (2) 6281-1980                                              }
{  Email   : mphillip@pcug.org.au                                           }
{---------------------------------------------------------------------------}
{  v1.00  03 Jul 2000  Initial version                                      }
{  v1.01  21 Jul 2000  Modified GetLanguageStr to use the VerLanguageName   }
{                      routine.                                             }
{  v1.02  22 Jul 2000  Modified to call ReadFixedFileInfo when we change    }
{                      the FileName property.                               }
{  v1.03  23 Jul 2000  Removed excess call to ReadFixedFileInfo from        }
{                      Create routine. The call is not necessary anymore    }
{                      as ReadFixedFileInfo is now triggered as part of     }
{                      the SetFileName routine.                             }
{---------------------------------------------------------------------------}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;
{$R-} //Range checking off

type
  TVVersionInfo = class(TComponent)
  private
    { Private declarations }
    FFVIBuff: Pointer;
    FFVISize: DWord;
    FHandle: DWord;
    FFileName: String;
    FLanguage: integer;
    FCodePage: Word;
    FLanguageCodePage: String;
    FCompanyName: String;
    FFileDescription: String;
    FFileVersion: String;
    FInternalName: String;
    FLegalCopyright: String;
    FLegalTradeMarks: String;
    FOriginalFileName: String;
    FProductName: String;
    FProductVersion: String;
    FComments: String;
    procedure ReadFixedFileInfo;
    function GetLangCPage: String;
    function GetStringFileInfo(S: String): String;
    procedure SetFileName(const Value: String);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function LanguageStr(Language: Word): String;
    property FileName: String read FFileName write SetFileName;
    property Language: integer read FLanguage;
    property CodePage: Word read FCodePage;
    property LanguageCodePage: String read FLanguageCodePage;
    property CompanyName: String read FCompanyName;
    property FileDescription: String read FFileDescription;
    property FileVersion: String read FFileVersion;
    property InternalName: String read FInternalName;
    property LegalCopyright: String read FLegalCopyright;
    property LegalTradeMarks: String read FLegalTradeMarks;
    property OriginalFileName: String read FOriginalFileName;
    property ProductName: String read FProductName;
    property ProductVersion: String read FProductVersion;
    property Comments: String read FComments;
  published
    { Published declarations }
  end;

implementation

{ TVVersionInfo }

constructor TVVersionInfo.Create(AOwner: TComponent);
begin  { of TVVersionInfo.Create }
  inherited Create(AOwner);

  { build current EXE filename }
  FileName := ParamStr(0);
end;   { of TVVersionInfo.Create }


procedure   TVVersionInfo.ReadFixedFileInfo;
begin  { of TVVersionInfo.ReadFixedFileInfo }
  { determine size of buffer required }
  FFVISize := GetFileVersionInfoSize(PChar(FileName), FHandle);


  { create buffer }
  GetMem(FFVIBuff, FFVISize);
  try

    { load buffer }
    GetFileVersionInfo(PChar(FileName), FHandle, FFVISize, FFVIBuff);

    { extract the language/codepage info }
    FLanguageCodePage := GetLangCPage;

    { extract the other info }
    FCompanyName := GetStringFileInfo('CompanyName');
    FFileDescription := GetStringFileInfo('FileDescription');
    FFileVersion := GetStringFileInfo('FileVersion');
    FInternalName := GetStringFileInfo('InternalName');
    FLegalCopyright := GetStringFileInfo('LegalCopyright');
    FLegalTradeMarks := GetStringFileInfo('LegalTradeMarks');
    FOriginalFileName := GetStringFileInfo('OriginalFileName');
    FProductName := GetStringFileInfo('ProductName');
    FProductVersion := GetStringFileInfo('ProductVersion');
    FComments := GetStringFileInfo('Comments');

  finally
    { dispose buffer }
    FreeMem(FFVIBuff, FFVISize);
  end;
end;   { of TVVersionInfo.ReadFixedFileInfo }

function    TVVersionInfo.LanguageStr(Language: Word): String;
var
  P: array[0..255] of Char;
  Len: Word;
begin  { of TVVersionInfo.LanguageStr }
  Len := VerLanguageName(Language, P, SizeOf(P));
  if (Len > SizeOf(P)) then
    begin
      { if this occurs then the P buffer is too small }
      { so we will truncate the returned string }
      Len := SizeOf(P);
    end;
  SetString(Result, P, Len);
end;   { of TVVersionInfo.LanguageStr }

function    TVVersionInfo.GetLangCPage: String;
var
  SearchString: String;
  FVILang: array of Byte;
  FVILANG2 : array [0..3] of Byte;
  Len: DWORD;
begin  { of TVVersionInfo.GetLangCPage }


  Result := '00000000';
  if (FFVIBuff <> NIL) then
    begin
      SearchString := '\VarFileInfo\Translation';
      if VerQueryValue(FFVIBuff, PChar(SearchString),
         Pointer(FVILang), Len) then
        begin


          //fVILANG2[0] :=
          //FLanguage := 1002;
          FLanguage := FVILang[0] + FVILang[1]*$100;
          FCodePage := FVILang[2] + FVILang[3]*$100;
          Result := IntToHex(FLanguage, 4) + IntToHex(FCodePage, 4);
        end;
    end;
end;   { of TVVersionInfo.GetLangCPage }


function    TVVersionInfo.GetStringFileInfo(S: String): String;
var
  SearchString: String;
  P: PChar;
  Len: DWORD;
begin  { of TVVersionInfo.GetStringFileInfo }
  Result := '';
  if (FFVIBuff <> NIL) then
    begin
      SearchString := '\StringFileInfo\'+FLanguageCodePage+'\'+S;
      if VerQueryValue(FFVIBuff, PChar(SearchString), Pointer(P), Len) then
        begin
          { coded with StrLen to ditch the trailing #0 character }
          SetString(Result, P, StrLen(P));
        end;
    end;
end;   { of TVVersionInfo.GetStringFileInfo }

procedure   TVVersionInfo.SetFileName(const Value: String);
begin  { of TVVersionInfo.SetFileName }
  FFileName := ExpandUNCFileName(Value);

  { read fileinfo from this new file }
  ReadFixedFileInfo;

end;   { of TVVersionInfo.SetFileName }

end.

