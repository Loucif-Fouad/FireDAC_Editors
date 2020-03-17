unit uFDDatabaseEditor;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Vcl.Dialogs,
  DesignIntf,
  DesignEditors,
  DB,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type

  TFDDatabaseEditor = class(TComponentEditor)
  private
    FOldEditor: TComponentEditor;
  protected
    function Connection: TFDConnection;
  public
    constructor Create(
      AComponent: TComponent;
      ADesigner: IDesigner); override;
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;

    procedure GetFieldsProperties;
  end;

procedure Register;

implementation

uses
  System.UITypes,
  uFieldsDef;

var
  PrevEditorClass: TComponentEditorClass = nil;

constructor TFDDatabaseEditor.Create(
  AComponent: TComponent;
  ADesigner: IDesigner);
begin
  inherited Create(AComponent, ADesigner);
  if Assigned(PrevEditorClass) then
  begin
    FOldEditor := TComponentEditor(PrevEditorClass.Create(AComponent,
      ADesigner));
  end;
end;

function TFDDatabaseEditor.Connection: TFDConnection;
begin
  Result := GetComponent as TFDConnection;
end;

procedure TFDDatabaseEditor.ExecuteVerb(Index: Integer);
begin
  IF (Index = 0) THEN
  BEGIN
    GetFieldsProperties
  END
  ELSE
  BEGIN
    IF Assigned(FOldEditor) THEN
    BEGIN
      FOldEditor.ExecuteVerb(Index - 1);
    END;
  END;
end;

function TFDDatabaseEditor.GetVerb(Index: Integer): string;
begin
  if (Index = 0) then
  begin
    Result := '&Set Fields Properties...'
  end
  else
  begin
    if Assigned(FOldEditor) then
    begin
      Result := FOldEditor.GetVerb(Index - 1);
    end;
  end;
end;

function TFDDatabaseEditor.GetVerbCount: Integer;
begin
  Result := 1;
  if Assigned(FOldEditor) then
  begin
    Inc(
      Result,
      FOldEditor.GetVerbCount);
  end;
end;

Procedure Register;
var
  FDConn: TFDConnection;
  Editor: IComponentEditor;
begin
  FDConn := TFDConnection.Create(nil);
  Try
    Editor := GetComponentEditor(
      FDConn,
      nil);
    if Assigned(Editor) then
    begin
      PrevEditorClass := TComponentEditorClass((Editor as TObject).ClassType);
    end;
  finally
    Editor := nil;
    FDConn.Free;
  end;
  RegisterComponentEditor(
    TFDConnection,
    TFDDatabaseEditor);
end;

procedure TFDDatabaseEditor.GetFieldsProperties;
const
  R = 'CREATE TABLE FD$FIELD_DEFS ( ' +
    'TABLE_NAME      VARCHAR(32) NOT NULL, ' +
    'FIELD_NAME      VARCHAR(32) NOT NULL, ' + 'DISPLAY_LABEL   VARCHAR(40), ' +
    'DISPLAY_FORMAT  VARCHAR(40), ' + 'EDIT_FORMAT     VARCHAR(40), ' +
    'VISIBLE         SMALLINT DEFAULT 1 NOT NULL, ' +
    'CONSTRAINT PK_FD$FIELD_DEFS PRIMARY KEY (TABLE_NAME, FIELD_NAME));';
var
  SL: TStrings;
begin
  try
    Connection.Connected := True;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Exit;
    end;
  end;
  SL := TStringList.Create;
  try

    Connection.GetTableNames(
      '',
      '',
      '',
      SL);
    if SL.IndexOf('FD$FIELD_DEFS') < 0 then
    begin
      if MessageDlg
        ('Table of the fields defs not found do you like to create it',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        Connection.ExecSQL(R);
        Connection.Commit;
        Connection.Close;
      end
      else
      begin
        SL.Free;
        Exit;
      end;
    end;

  finally
    SL.Free;
  end;
  TfrmFieldsDef.ShowFieldsDef(Connection);

end;

end.
