unit uFieldsDef;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Data.DB,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.StdCtrls,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Phys.Intf,
  FireDAC.DApt, Vcl.ExtCtrls;

type
  TfrmFieldsDef = class(TForm)
    dbgrdFields: TDBGrid;
    lstTables: TListBox;
    d_FieldDefs: TDataSource;
    dsFieldDefs: TFDQuery;
    FDTransaction: TFDTransaction;
    spl1: TSplitter;
    procedure lstTablesDblClick(Sender: TObject);
  private
    { Déclarations privées }
    FConnection: TFDConnection;
  public
    { Déclarations publiques }
    procedure CopyFields(
      aTableName: string;
      aFieldList: TStrings);
    class procedure ShowFieldsDef(aConnection: TFDConnection);
  end;

var
  frmFieldsDef: TfrmFieldsDef;

implementation

{$R *.dfm}

procedure TfrmFieldsDef.CopyFields(
  aTableName: string;
  aFieldList: TStrings);
var
  I: Integer;
begin
  dsFieldDefs.DisableControls;
  try
    for I := 0 to aFieldList.Count - 1 do
    begin
      if not dsFieldDefs.Locate('TABLE_NAME;FIELD_NAME',
        VarArrayOf([aTableName, Trim(aFieldList[I])]), [loCaseInsensitive]) then
      begin
        dsFieldDefs.Insert;
        dsFieldDefs.FieldByName('TABLE_NAME').asString := aTableName;
        dsFieldDefs.FieldByName('FIELD_NAME').asString := Trim(aFieldList[I]);
        dsFieldDefs.FieldByName('VISIBLE').asInteger := 1;
        dsFieldDefs.Post;
      end;
    end;
  finally
    dsFieldDefs.EnableControls;
  end;
end;

procedure TfrmFieldsDef.lstTablesDblClick(Sender: TObject);
var
  SelectedTable: string;
  aFieldList: TStrings;
begin
  if lstTables.ItemIndex < 0 then
    Exit;
  aFieldList := TStringList.Create;

  SelectedTable := lstTables.Items[lstTables.ItemIndex];
  FConnection.GetFieldNames(
    '',
    '',
    SelectedTable,
    '',
    aFieldList);
  CopyFields(
    SelectedTable,
    aFieldList);
end;

{ TfrmFieldsDef }

class procedure TfrmFieldsDef.ShowFieldsDef(aConnection: TFDConnection);
var
  lForm: TfrmFieldsDef;
  aConnected: Boolean;
begin
  lForm := TfrmFieldsDef.Create(nil);
  try
    lForm.FDTransaction.Connection := aConnection;
    lForm.dsFieldDefs.Connection := aConnection;
    aConnected := aConnection.Connected;

    aConnection.Connected := True;
//aConnection.AutoCommit := True;

    aConnection.GetTableNames(
      '',
      '',
      '',
      lForm.lstTables.Items);
    lForm.FConnection := aConnection;
    lForm.dsFieldDefs.Open;
    lForm.ShowModal;
  finally
    lForm.dsFieldDefs.Close;
    aConnection.Connected := aConnected;

    lForm.Free;
  end;

end;

end.
